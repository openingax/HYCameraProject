//
//  ViewController.m
//  HYCameraProject
//
//  Created by 谢立颖 on 2018/12/7.
//  Copyright © 2018 Viomi. All rights reserved.
//

#import "ViewController.h"
#import <HYCamera/HYCamera.h>

@interface ViewController ()

@property(nonatomic,strong) HYCameraManager *cameraManager;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blueColor];
    
#if __has_feature(objc_arc)
    HYConfig *config = [[HYConfig alloc] init];
    config.deviceID = @"VIEW-1385328-HKXCK";
    config.account = @"admin";
    config.password = @"123456";
    self.cameraManager = [[HYCameraManager alloc] initWithConfig:config];
#endif
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.cameraManager showHYCameraWithcontroller:self];
}


@end
