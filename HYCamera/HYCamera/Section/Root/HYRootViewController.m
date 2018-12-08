//
//  HYRootViewController.m
//  HYCamera
//
//  Created by 谢立颖 on 2018/12/7.
//  Copyright © 2018 Viomi. All rights reserved.
//

#import <MBProgressHUD.h>
#import <libextobjc/EXTScope.h>
#import <AVFoundation/AVAudioSession.h>

#import "HYRootViewController.h"
#import "KYLDeviceInfo.h"
#import "SEP2P_Define.h"
#import "KYLWifiObject.h"
#import "HYCameraManager.h"
#import "UIDevice+Orientation.h"
#import "HYCameraHelper.h"
#import "HYCameraSettingViewController.h"
#import "HYResolutionRatioView.h"

#define KYL_CAMERA_DID @"KYL_CAMERA_DID"
#define KYL_CAMERA_USE_TIPS @"KYL_CAMERA_USE_TIPS"

#define kNavButtonSize 24
#define kFunctionButtonSize 36

@interface HYRootViewController ()
{
    CGRect oldMonitorRect;
    BOOL hasConnectCamera;
    
    BOOL hasEnableVoice;
    BOOL hasEnablePhone;
    BOOL hasShowRatioView;
}

@property(nonatomic,retain) UIButton *voiceBtn;
@property(nonatomic,retain) UIButton *phoneBtn;
@property(nonatomic,retain) UIButton *resolutionRatioBtn;
@property(nonatomic,retain) HYResolutionRatioView *resolutionRatioView;

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
    
    [self initTheData];
    [self initTheUI];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(changeFrames:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kHYCameraOrientationEvent object:nil userInfo:@{kHYCameraOrientationKey: @(YES)}];
    [UIDevice switchNewOrientation:UIInterfaceOrientationLandscapeRight];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (hasConnectCamera && [self.m_pCamera getCameraStatus] == CONNECT_STATUS_CONNECTED) {
        [self startVideo];
    } else {
        [self connectCamera];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self stopVideo];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)HYHiddenNavigatorBar {
    
}

- (void)changeFrames:(NSNotification *)noti {
    
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
    CGFloat width = kIsiPhoneX ? floor(18*height/9) : MAX(kScreenWidth, kScreenHeight);
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
    backBtn.bounds = CGRectMake(0, 0, kNavButtonSize, kNavButtonSize);
    [backBtn addTarget:self action:@selector(exitAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBtn];
    [backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kNavButtonSize, kNavButtonSize));
        make.centerY.equalTo(self.titleLabel.mas_centerY);
        make.left.equalTo(self.view).with.offset(kIsiPhoneX ? 54 : 20);
    }];
    
    UIButton *moreBtn = [[UIButton buttonWithType:UIButtonTypeCustom] autorelease];
    [moreBtn setImage:[UIImage imageWithBundleAsset:@"ym_nav_back"] forState:UIControlStateNormal];
    moreBtn.bounds = CGRectMake(0, 0, kNavButtonSize, kNavButtonSize);
    [moreBtn addTarget:self action:@selector(moreAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:moreBtn];
    [moreBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kNavButtonSize, kNavButtonSize));
        make.centerY.equalTo(self.titleLabel.mas_centerY);
        make.right.equalTo(self.view).with.offset(kIsiPhoneX ? -54 : -20);
    }];
    
    self.voiceBtn = [[UIButton buttonWithType:UIButtonTypeCustom] autorelease];
    [self.voiceBtn setImage:[UIImage imageWithBundleAsset:@""] forState:UIControlStateNormal];
    self.voiceBtn.bounds = CGRectMake(0, 0, kFunctionButtonSize, kFunctionButtonSize);
    self.voiceBtn.layer.cornerRadius = kFunctionButtonSize/2.f;
    self.voiceBtn.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
    [self.voiceBtn addTarget:self action:@selector(voiceAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.voiceBtn];
    [self.voiceBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kFunctionButtonSize, kFunctionButtonSize));
        make.left.equalTo(self.view).with.offset(kIsiPhoneX ? 54 : 20);
        make.bottom.equalTo(self.view).with.offset(-13);
    }];
    
    self.phoneBtn = [[UIButton buttonWithType:UIButtonTypeCustom] autorelease];
    [self.phoneBtn setImage:[UIImage imageWithBundleAsset:@""] forState:UIControlStateNormal];
    self.phoneBtn.bounds = CGRectMake(0, 0, kFunctionButtonSize, kFunctionButtonSize);
    self.phoneBtn.layer.cornerRadius = kFunctionButtonSize/2.f;
    self.phoneBtn.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
    [self.phoneBtn addTarget:self action:@selector(phoneAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.phoneBtn];
    [self.phoneBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kFunctionButtonSize, kFunctionButtonSize));
        make.left.equalTo(self.voiceBtn.mas_right).with.offset(16);
        make.centerY.equalTo(self.voiceBtn.mas_centerY);
    }];
    
    self.resolutionRatioBtn = [[UIButton buttonWithType:UIButtonTypeCustom] autorelease];
    [self.resolutionRatioBtn setImage:[UIImage imageWithBundleAsset:@""] forState:UIControlStateNormal];
    self.resolutionRatioBtn.bounds = CGRectMake(0, 0, kFunctionButtonSize, kFunctionButtonSize);
    self.resolutionRatioBtn.layer.cornerRadius = kFunctionButtonSize/2.f;
    self.resolutionRatioBtn.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
    [self.resolutionRatioBtn addTarget:self action:@selector(resolutionRatioAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.resolutionRatioBtn];
    [self.resolutionRatioBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kFunctionButtonSize, kFunctionButtonSize));
        make.right.equalTo(self.view).with.offset(kIsiPhoneX ? -54 : -20);
        make.centerY.equalTo(self.voiceBtn.mas_centerY);
    }];
    
    self.resolutionRatioView = [[HYResolutionRatioView alloc] init];
    self.resolutionRatioView.hidden = YES;
    [self.view addSubview:self.resolutionRatioView];
    [self.resolutionRatioView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.right.equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(kIsiPhoneX ? 200 : 186, kScreenHeight));
    }];
    
    BOOL hasShowTips = [[[NSUserDefaults standardUserDefaults] objectForKey:KYL_CAMERA_USE_TIPS] boolValue];
    if (!hasShowTips) {
        
    }
}

- (void)showConnFailedView {
    
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
        
        // 这里设置三个功能按键的显示状态
        int voiceStatus = [self.m_pCamera getAudioStatus];
        int phoneStatus = [self.m_pCamera getTalkStatus];
        int resolutionType = self.m_pCamera.m_nCameraResolution;
        
        
        
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

#pragma mark - KYLMontiorTouchProtocol
- (void)KYLMontiorTouchProtocolDidGestureOneTap:(void *)pUser {
    if (!self.resolutionRatioView.isHidden) {
        [self.resolutionRatioView hide];
    }
}

#pragma mark - Action
- (void)exitAction {
    [[NSNotificationCenter defaultCenter] postNotificationName:kHYCameraOrientationEvent object:nil userInfo:@{kHYCameraOrientationKey: @(NO)}];
    [UIDevice switchNewOrientation:UIInterfaceOrientationPortrait];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)moreAction {
    [[NSNotificationCenter defaultCenter] postNotificationName:kHYCameraOrientationEvent object:nil userInfo:@{kHYCameraOrientationKey: @(NO)}];
    [UIDevice switchNewOrientation:UIInterfaceOrientationPortrait];
    HYCameraSettingViewController *settingVC = [[HYCameraSettingViewController alloc] init];
    [self.navigationController pushViewController:settingVC animated:YES];
    [settingVC autorelease];
}

- (void)voiceAction {
    if (self.m_pCamera == nil) return;
    
    int nRet = -1;
    
    if (!hasEnableVoice) {
        if ([self.m_pCamera getCameraStatus] == CONNECT_STATUS_CONNECTED) {
            nRet = [self.m_pCamera startAudio];
            if (nRet == 0) {
                hasEnableVoice = YES;
                NSLog(@"打开了语音功能");
                [self.voiceBtn setImage:[UIImage imageWithBundleAsset:@""] forState:UIControlStateNormal];
            }
        }
    } else {
        nRet = [self.m_pCamera stopAudio];
        if (nRet == 1) {
            hasEnableVoice = NO;
            NSLog(@"关闭了语音功能");
            [self.voiceBtn setImage:[UIImage imageWithBundleAsset:@""] forState:UIControlStateNormal];
        }
    }
}

- (void)phoneAction {
    if (self.m_pCamera == nil) return;
    
    if (![self canRecord]) return;
    
    int nRet = -1;
    if (!hasEnablePhone) {
        if ([self.m_pCamera getCameraStatus] == CONNECT_STATUS_CONNECTED) {
            nRet = [self.m_pCamera startTalk];
            if (nRet == 0) {
                hasEnablePhone = YES;
                [self.phoneBtn setImage:[UIImage imageWithBundleAsset:@""] forState:UIControlStateNormal];
            } else {
                NSLog(@"打开实时对讲功能失败");
            }
        }
    } else {
        nRet = [self.m_pCamera stopTalk];
        if (nRet == 0) {
            hasEnablePhone = NO;
            [self.phoneBtn setImage:[UIImage imageWithBundleAsset:@""] forState:UIControlStateNormal];
        }
    }
}

- (void)resolutionRatioAction {
    if (self.m_pCamera == nil) return;
    
    if (hasShowRatioView) {
//        [self.resolutionRatioView hide];
        self.resolutionRatioView.hidden = YES;
    } else {
        @weakify(self);
        self.resolutionRatioView.hidden = NO;
        [self.resolutionRatioView showWithSelectedIdx:self.m_pCamera.m_nCameraResolution Complete:^(BOOL hasSelected, HYResolutionRatioType type) {
            @strongify(self);
            if (!hasSelected) return;
            
            int result = [self.m_pCamera setTheCameraResolutionParams:self.strDID resolution:(int)type];
            if (result >= 0) {
                NSLog(@"设置成功");
                if (type == HYResolutionRatioType1080) {
                    [self.resolutionRatioBtn setImage:[UIImage imageWithBundleAsset:@""] forState:UIControlStateNormal];
                } else if (type == HYResolutionRatioType480) {
                    [self.resolutionRatioBtn setImage:[UIImage imageWithBundleAsset:@""] forState:UIControlStateNormal];
                }
                
            } else {
                
            }
        }];
    }
}

- (BOOL)canRecord {
    __block BOOL bCanRecord = YES;
    
    if ([[[UIDevice currentDevice] systemVersion] compare:@"7.0" options:NSNumericSearch] != NSOrderedAscending) {
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        if ([audioSession respondsToSelector:@selector(requestRecordPermission:)]) {
            [audioSession performSelector:@selector(requestRecordPermission:) withObject:^(BOOL granted) {
                bCanRecord = granted;
            }];
        }
    }
    return bCanRecord;
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
            hasConnectCamera = YES;
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
