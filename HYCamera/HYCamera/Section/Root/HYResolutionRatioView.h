//
//  HYResolutionRatioView.h
//  HYCamera
//
//  Created by 谢立颖 on 2018/12/8.
//  Copyright © 2018 Viomi. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, HYResolutionRatioType) {
    HYResolutionRatioType120 = 0,
    HYResolutionRatioType480 = 2,
    HYResolutionRatioType1080 = 6
};

@interface HYResolutionRatioView : UIView

@property(nonatomic,assign) BOOL isHidden;

- (void)showWithSelectedIdx:(HYResolutionRatioType)type Complete:(void(^)(BOOL hasSelected, HYResolutionRatioType type))block;
- (void)hide;

@end
