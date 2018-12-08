//
//  HYCameraSettingItemView.h
//  HYCamera
//
//  Created by 谢立颖 on 2018/12/8.
//  Copyright © 2018 Viomi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HYSettingCellModel;

@interface HYCameraSettingItemView : UIView

- (instancetype)initWithItems:(NSArray <HYSettingCellModel *> *)items complete:(void(^)(NSInteger index))block;

@end
