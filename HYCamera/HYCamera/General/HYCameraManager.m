//
//  HYCameraManager.m
//  HYCamera
//
//  Created by 谢立颖 on 2018/12/7.
//  Copyright © 2018 Viomi. All rights reserved.
//

#import "HYCameraManager.h"
#import "HYBaseNavigationController.h"
#import "HYRootViewController.h"

@interface HYCameraManager ()
{
    HYRootViewController *_rootVC;
    HYBaseNavigationController *_navVC;
}

@end

@implementation HYCameraManager

- (instancetype)initWithConfig:(HYConfig *)config {
    if (self = [super init]) {
#if __has_feature(objc_arc)
        
#else
        _rootVC = [[HYRootViewController alloc] initWithConfig:config];
        _navVC = [[HYBaseNavigationController alloc] initWithRootViewController:_rootVC];
        _navVC.modalPresentationStyle = UIModalPresentationFullScreen;
#endif
    }
    return self;
}

- (void)showHYCameraWithcontroller:(UIViewController *)controller {
    if (_rootVC) {
        [controller presentViewController:_navVC animated:YES completion:nil];
    }
}

- (void)dealloc {
    [_rootVC release];
    [_navVC release];
    
    _rootVC = nil;
    _navVC = nil;
    
    [super dealloc];
}

@end
