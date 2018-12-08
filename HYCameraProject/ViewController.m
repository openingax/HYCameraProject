//
//  ViewController.m
//  HYCameraProject
//
//  Created by 谢立颖 on 2018/12/7.
//  Copyright © 2018 Viomi. All rights reserved.
//

#import "ViewController.h"
#import <HYCamera/HYCamera.h>
#import "AppDelegate.h"
#import <Masonry.h>

@interface ViewController ()

@property(nonatomic,strong) HYCameraManager *cameraManager;
@property(nonatomic,assign) BOOL hasShowCameraVC;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blueColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveDeviceOrientationEvent:) name:kHYCameraOrientationEvent object:nil];
    
#if __has_feature(objc_arc)
    HYConfig *config = [[HYConfig alloc] init];
    config.deviceID = @"VIEW-1385328-HKXCK";
    config.account = @"admin";
    config.password = @"123456";
    self.cameraManager = [[HYCameraManager alloc] initWithConfig:config];
#endif
    
    UIButton *btn = [[UIButton alloc] init];
    [btn setTitle:@"打开摄像头" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(showCameraVC) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)didReceiveDeviceOrientationEvent:(NSNotification *)noti {
    BOOL isLandScape = [[noti.userInfo objectForKey:kHYCameraOrientationKey] boolValue];
    AppDelegate * appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.allowRotation = isLandScape;
}

- (void)showCameraVC {
    self.hasShowCameraVC = YES;
    [self.cameraManager showHYCameraWithcontroller:self];
}

@end
