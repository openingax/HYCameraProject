//
//  HYRootViewController.m
//  HYCamera
//
//  Created by 谢立颖 on 2018/12/7.
//  Copyright © 2018 Viomi. All rights reserved.
//

#import <MBProgressHUD.h>

#import "HYRootViewController.h"
#import "KYLDeviceInfo.h"
#import "SEP2P_Define.h"
#import "KYLWifiObject.h"
#import "HYCameraManager.h"
#import "UIDevice+Orientation.h"
#import "HYCameraHelper.h"

#define KYL_CAMERA_DID @"KYL_CAMERA_DID"
#define kButtonSize 24

@interface HYRootViewController ()
{
    CGRect oldMonitorRect;
}

@end

@implementation HYRootViewController
@synthesize m_pCamera;
@synthesize selectedWifiObject;
@synthesize imgViewShowVideo;

- (void)dealloc {
    
    self.selectedWifiObject = nil;
    self.m_pCamera = nil;
    self.imgViewShowVideo = nil;
    
    [super dealloc];
}

// 把设备ID保存起来
- (void)setStrDID:(NSString *)strDID
{
    [[NSUserDefaults standardUserDefaults] setObject:strDID forKey:KYL_CAMERA_DID];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)strDID
{
    return [[NSUserDefaults standardUserDefaults] valueForKey:KYL_CAMERA_DID];
}


#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    self.navigationController.navigationBar.hidden = YES;
    
    [self initTheData];
    [self initTheUI];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(changeFrames:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setHidden:YES];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kHYCameraOrientationEvent object:nil userInfo:@{kHYCameraOrientationKey: @(YES)}];
    [UIDevice switchNewOrientation:UIInterfaceOrientationLandscapeRight];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self connectCamera];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.navigationController.navigationBar setHidden:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

// 当 VC 在 NavigationController 里时，下面这个设置导航栏的方法不起作用
//- (BOOL)prefersStatusBarHidden {
//    return YES;
//}

- (void) initTheData
{
    self.selectedWifiObject = nil;
    self.m_pCamera = nil;
    if (nil == m_pCamera) {
        self.m_pCamera = [[[KYLCamera alloc] init] autorelease];
        self.m_pCamera.delegate = self;
    }
}

- (void)initTheUI {
    CGRect rect;
    
    CGFloat height = MIN(kScreenWidth, kScreenHeight);
    CGFloat width = kIsiPhoneX ? floor(16*height/9) : MAX(kScreenWidth, kScreenHeight);
    if (kIsiPhoneX) {
        rect = CGRectMake((MAX(kScreenWidth, kScreenHeight) - width) / 2, 0, width, height);
    } else {
        rect = [UIScreen mainScreen].bounds;
    }
    self.imgViewShowVideo = [[[UIImageView alloc] initWithFrame:rect] autorelease];
    self.imgViewShowVideo.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.imgViewShowVideo];
    [self.imgViewShowVideo mas_makeConstraints:^(MASConstraintMaker *make) {
        if (kIsiPhoneX) {
            make.width.mas_equalTo(width);
            make.height.mas_equalTo(height);
            make.center.equalTo(self.view);
        } else {
            make.edges.equalTo(self.view);
        }
    }];
    
    self.pCameraMonitor = [[[KYLCameraMonitor alloc] initWithFrame:rect] autorelease];
    self.pCameraMonitor.m_pCameraObj = self.m_pCamera;
    oldMonitorRect = self.pCameraMonitor.frame;
    [self.view addSubview:_pCameraMonitor];
    self.pCameraMonitor.delegate = self;
    self.pCameraMonitor.userInteractionEnabled = YES;
    [self.view addSubview:self.pCameraMonitor];
    [self.pCameraMonitor mas_makeConstraints:^(MASConstraintMaker *make) {
        if (kIsiPhoneX) {
            make.width.mas_equalTo(width);
            make.height.mas_equalTo(height);
            make.center.equalTo(self.view);
        } else {
            make.edges.equalTo(self.view);
        }
    }];
    
    self.titleLabel = [[[UILabel alloc] init] autorelease];
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.font = [UIFont systemFontOfSize:17];
    self.titleLabel.text = @"云米摄像头（云台版）";
    [self.view addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.view).with.offset(30);
    }];
    
    /* 按钮 */
    UIButton *backBtn = [[UIButton buttonWithType:UIButtonTypeCustom] autorelease];
    [backBtn setImage:[UIImage imageWithBundleAsset:@"ym_nav_back"] forState:UIControlStateNormal];
    backBtn.bounds = CGRectMake(0, 0, kButtonSize, kButtonSize);
    [backBtn addTarget:self action:@selector(exitAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBtn];
    [backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.titleLabel.mas_centerY);
        make.left.equalTo(self.view).with.offset(kIsiPhoneX ? 54 : 20);
    }];
    
    UIButton *moreBtn = [[UIButton buttonWithType:UIButtonTypeCustom] autorelease];
    [moreBtn setImage:[UIImage imageWithBundleAsset:@"ym_nav_back"] forState:UIControlStateNormal];
    moreBtn.bounds = CGRectMake(0, 0, kButtonSize, kButtonSize);
    [moreBtn addTarget:self action:@selector(moreAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:moreBtn];
    [moreBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.titleLabel.mas_centerY);
        make.right.equalTo(self.view).with.offset(kIsiPhoneX ? -54 : -20);
    }];
}

- (void)showConnFailedView {
    
}

- (void)changeFrames:(NSNotification *)noti {
//    self.pCameraMonitor.frame = [UIScreen mainScreen].bounds;
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    if (size.width > size.height) {
        // 横屏设置
        
    } else {
        // 竖屏设置
    }
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    if ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationMaskPortrait) {
        // 竖屏布局
//        [self.pCameraMonitor.layer setAffineTransform:CGAffineTransformMakeRotation(-M_PI/2.f)];
    } else {
        // 横屏布局
        [self.pCameraMonitor.layer setAffineTransform:CGAffineTransformMakeRotation(0)];
    }
}

- (void)connectCamera {
    
    if (nil == self.deviceID
        || [self.deviceID length] < 10
        || nil == self.account
        || [self.account length] < 1
        || nil == self.password
        || [self.password length]< 1
        ) {
        NSLog(@"The userinfo error!");
        UIAlertView *alertView =  [[UIAlertView alloc] initWithTitle:@"Tips" message:@"Please input the valid Information" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:@"Cancel", nil];
        [alertView show];
        [alertView release];
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        return;
    }
    
    self.m_pCamera.m_sDID = self.deviceID;
    self.strDID = self.deviceID;
    self.m_pCamera.m_sUsername = self.account;
    self.m_pCamera.m_sPassword = self.password;
    
    NSLog(@"begin connecting!");
    int ret = [self.m_pCamera connect];
    
    if (ret == 0) {
        NSLog(@"connected success!");
    } else {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }
}

- (void)startVideo {
    if (nil == self.m_pCamera) return;
    
    int nRet = -1;
    
    if ([self.m_pCamera getCameraStatus] != CONNECT_STATUS_CONNECTED) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Tips" message:@"You should make sure connected to device first!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
        [alertView release];
        return;
    }
    
    nRet = [self.pCameraMonitor startVideo];
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    if (nRet == 0) {
        
    } else {
        
    }
}

- (void)stopVideo {
    if (nil == self.m_pCamera) return;
    
    int nRet = [self.pCameraMonitor stopVideo];
    if (nRet == 0) {
        NSLog(@"停止播放监控录像");
    }
}

#pragma mark - Action
- (void)exitAction {
        [[NSNotificationCenter defaultCenter] postNotificationName:kHYCameraOrientationEvent object:nil userInfo:@{kHYCameraOrientationKey: @(NO)}];
    [UIDevice switchNewOrientation:UIInterfaceOrientationPortrait];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)moreAction {
    
}

#pragma mark -
-  (void)didReceiveCameraStatus:(NSString *) did status:(int) status reserve:(NSString *) reserve1 user:(void *) pUser {
    NSString *sttStatus = nil;
    switch (status) {
        case CONNECT_STATUS_CONNECTING:
        {
            sttStatus = @"connecting";
        }
            break;
        case CONNECT_STATUS_INITIALING:
        {
            sttStatus = @"initialing";
        }
            break;
        case CONNECT_STATUS_ONLINE:
        {
            sttStatus = @"online";
        }
            break;
        case CONNECT_STATUS_CONNECT_FAILED:
        {
            sttStatus = @"connect failed";
        }
            break;
        case CONNECT_STATUS_DISCONNECT:
        {
            sttStatus = @"disconnect";
        }
            break;
        case CONNECT_STATUS_INVALID_ID:
        {
            sttStatus = @"invalid id";
        }
            break;
        case CONNECT_STATUS_DEVICE_NOT_ONLINE:
        {
            sttStatus = @"offline";
        }
            break;
        case CONNECT_STATUS_CONNECT_TIMEOUT:
        {
            sttStatus = @"connect timeout";
        }
            break;
        case CONNECT_STATUS_WRONG_USER_PWD:
        {
            sttStatus = @"wrong password";
        }
            break;
        case CONNECT_STATUS_INVALID_REQ:
        {
            sttStatus = @"invalid request";
        }
            break;
        case CONNECT_STATUS_EXCEED_MAX_USER:
        {
            sttStatus = @"exceed max user";
        }
            break;
        case CONNECT_STATUS_CONNECTED:
        {
            sttStatus = @"connected";
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self startVideo];
            });
            //获取wifi list
//            [self doGetAllNearByWifiList];
        }
            break;
        case CONNECT_STATUS_UNKNOWN:
        {
            sttStatus = @"unknown status";
        }
            break;
            
        default:
            break;
    }
}

@end
