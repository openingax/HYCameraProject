//
//  HYCameraManager.h
//  HYCamera
//
//  Created by 谢立颖 on 2018/12/7.
//  Copyright © 2018 Viomi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HYConfig.h"

/* 屏幕旋转控制的通知名 */
static NSString * const kHYCameraOrientationEvent = @"kHYCameraOrientationEvent";
/* kHYCameraOrientationEvent 通知里 userInfo 字典的 key，根据这个 key 去取值 */
static NSString * const kHYCameraOrientationKey = @"isLandScape";

@interface HYCameraManager : NSObject

- (instancetype)initWithConfig:(HYConfig *)config;
- (void)showHYCameraWithcontroller:(UIViewController *)controller;

@end
