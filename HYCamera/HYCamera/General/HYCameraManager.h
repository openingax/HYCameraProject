//
//  HYCameraManager.h
//  HYCamera
//
//  Created by 谢立颖 on 2018/12/7.
//  Copyright © 2018 Viomi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HYConfig.h"

@interface HYCameraManager : NSObject

- (instancetype)initWithConfig:(HYConfig *)config;
- (void)showHYCameraWithcontroller:(UIViewController *)controller;

@end
