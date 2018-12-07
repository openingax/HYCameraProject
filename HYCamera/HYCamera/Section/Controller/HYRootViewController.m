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

#define KYL_CAMERA_DID @"KYL_CAMERA_DID"

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
    
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    [self initTheData];
    [self initTheUI];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(changeFrames:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self connectCamera];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


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
    self.imgViewShowVideo = [[[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds] autorelease];
    self.imgViewShowVideo.backgroundColor = [UIColor blackColor];
    [self initTheCameraMonitor];
}

- (void) initTheCameraMonitor
{
    self.pCameraMonitor = [[[KYLCameraMonitor alloc] initWithFrame:[UIScreen mainScreen].bounds] autorelease];
    self.pCameraMonitor.m_pCameraObj = self.m_pCamera;
    oldMonitorRect = self.pCameraMonitor.frame;
    [self.view addSubview:_pCameraMonitor];
    self.pCameraMonitor.delegate = self;
    self.pCameraMonitor.userInteractionEnabled = YES;
    
    [self.pCameraMonitor.layer setAffineTransform:CGAffineTransformMakeRotation(-M_PI/2.f)];
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
        [self.pCameraMonitor.layer setAffineTransform:CGAffineTransformMakeRotation(-M_PI/2.f)];
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
    
    if (nRet == 0) {
        
    }
}

- (void)stopVideo {
    if (nil == self.m_pCamera) return;
    
    int nRet = [self.pCameraMonitor stopVideo];
    if (nRet == 0) {
        NSLog(@"停止播放监控录像");
    }
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
