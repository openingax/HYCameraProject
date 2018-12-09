//
//  HYCameraSettingViewController.h
//  HYCamera
//
//  Created by 谢立颖 on 2018/12/8.
//  Copyright © 2018 Viomi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HYCameraSettingViewController : UIViewController

#if __has_feature(objc_arc)
@property(nonatomic,strong) NSString *deviceName;
#else
@property(nonatomic,retain) NSString *deviceName;
#endif

@end
