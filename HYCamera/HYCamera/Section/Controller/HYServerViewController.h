//
//  HYServerViewController.h
//  HYCamera
//
//  Created by 谢立颖 on 2018/12/7.
//  Copyright © 2018 Viomi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AudioToolbox/AudioFile.h>
#include <AudioToolbox/AudioQueue.h>
#include <AudioToolbox/AudioServices.h>

#import "KYLCamera.h"

@class HYConfig;

@interface HYServerViewController : UIViewController

@property (nonatomic, retain)  NSString *deviceID;
@property (nonatomic, retain)  NSString *account;
@property (nonatomic, retain)  NSString *password;

- (instancetype)initWithConfig:(HYConfig *)config;

@end


