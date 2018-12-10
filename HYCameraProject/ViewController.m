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
#import <SystemConfiguration/CaptiveNetwork.h>
#import <HYCamera/HYSearchTool.h>

@interface ViewController () <HYSearchToolDelegate>

@property(nonatomic,strong) HYCameraManager *cameraManager;
@property(nonatomic,assign) BOOL hasShowCameraVC;
@property(nonatomic,strong) HYSearchTool *searchTool;

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
    
    self.searchTool = [[HYSearchTool alloc] init];
    self.searchTool.delegate = self;
#endif
    
    UIButton *btn = [[UIButton alloc] init];
    [btn setTitle:@"打开摄像头" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(showCameraVC) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
    }];
    
    UIButton *wifiBtn = [[UIButton alloc] init];
    [wifiBtn setTitle:@"获取 Wi-Fi 信息" forState:UIControlStateNormal];
    [wifiBtn addTarget:self action:@selector(fetchWiFiInfo) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:wifiBtn];
    [wifiBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(btn.mas_bottom).with.offset(16);
        make.centerX.equalTo(self.view);
    }];
    
    UIButton *searchBtn = [[UIButton alloc] init];
    [searchBtn setTitle:@"开始搜索" forState:UIControlStateNormal];
    [searchBtn addTarget:self action:@selector(searchDeviceInfo) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:searchBtn];
    [searchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(wifiBtn.mas_bottom).with.offset(16);
        make.centerX.equalTo(self.view);
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

- (void)fetchWiFiInfo {
    NSDictionary *wifi = nil;
    CFArrayRef wifiInterfaces = CNCopySupportedInterfaces();
    
    NSArray *interfaces = (__bridge NSArray *)wifiInterfaces;
    
    for (NSString *interfaceName in interfaces) {
        CFDictionaryRef dictRef = CNCopyCurrentNetworkInfo((__bridge CFStringRef)(interfaceName));
        
        if (dictRef) {
            NSDictionary *networkInfo = (__bridge NSDictionary *)dictRef;
            NSLog(@"network info -> %@", networkInfo);
            
            wifi = networkInfo;
            
            CFRelease(dictRef);
        }
    }
    CFRelease(wifiInterfaces);
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"%@", wifi] delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alertView show];
}

- (void)searchDeviceInfo {
    [self.searchTool startSearch];
}

- (void)didSucceedSearchOneDevice:(NSString *)chDID ip:(NSString *)ip port:(int)port devName:(NSString *)devName macaddress:(NSString *)mac productType:(NSString *)productType {
    if ([chDID isEqualToString:@"VIEW-1385328-HKXCK"]) {
        [self.searchTool stopSearch];
    }
}

@end
