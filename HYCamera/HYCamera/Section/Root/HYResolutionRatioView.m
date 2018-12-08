//
//  HYResolutionRatioView.m
//  HYCamera
//
//  Created by 谢立颖 on 2018/12/8.
//  Copyright © 2018 Viomi. All rights reserved.
//

#import "HYResolutionRatioView.h"
#import <Masonry.h>

@interface HYResolutionRatioView ()

@property(nonatomic,copy) void(^CompleteBlock)(BOOL hasSelected, HYResolutionRatioType type);

@property(nonatomic,assign) BOOL hasSelected;
@property(nonatomic,assign) HYResolutionRatioType selectedType;
@property(nonatomic,retain) UIButton *highRatioBtn;
@property(nonatomic,retain) UIButton *lowRatioBtn;

@end

@implementation HYResolutionRatioView

- (instancetype)init {
    if (self = [super init]) {
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
        self.isHidden = YES;
        
        UITapGestureRecognizer *tap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)] autorelease];
        [self addGestureRecognizer:tap];
        
        
        self.highRatioBtn = [[[UIButton alloc] init] autorelease];
        NSMutableAttributedString *highStr = [[[NSMutableAttributedString alloc] initWithString:@"1080P" attributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName, [UIFont systemFontOfSize:16 weight:UIFontWeightMedium], NSFontAttributeName, nil]] autorelease];
        [self.highRatioBtn setAttributedTitle:highStr forState:UIControlStateNormal];
        [self.highRatioBtn addTarget:self action:@selector(highRatioAction) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.highRatioBtn];
        
        self.lowRatioBtn = [[[UIButton alloc] init] autorelease];
        NSMutableAttributedString *lowStr = [[NSMutableAttributedString alloc] initWithString:@"480P" attributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithRed:182/255.f green:181/255.f blue:190/255.f alpha:1], NSForegroundColorAttributeName, [UIFont systemFontOfSize:16 weight:UIFontWeightMedium], NSFontAttributeName, nil]];
        [self.lowRatioBtn setAttributedTitle:lowStr forState:UIControlStateNormal];
        [self.lowRatioBtn addTarget:self action:@selector(lowRatioAction) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.lowRatioBtn];
        
        [self.highRatioBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.bottom.equalTo(self.mas_centerY).with.offset(-18);
        }];
        [self.lowRatioBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.top.equalTo(self.mas_centerY).with.offset(18);
        }];
    }
    return self;
}

- (void)showWithSelectedIdx:(HYResolutionRatioType)type Complete:(void(^)(BOOL hasSelected, HYResolutionRatioType type))block {
    
    self.hasSelected = NO;
    self.selectedType = type;
    
    if (type == HYResolutionRatioType1080) {
        [self.highRatioBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.lowRatioBtn setTitleColor:[UIColor colorWithRed:182/255.f green:181/255.f blue:190/255.f alpha:1] forState:UIControlStateNormal];
    } else if (type == HYResolutionRatioType480) {
        [self.highRatioBtn setTitleColor:[UIColor colorWithRed:182/255.f green:181/255.f blue:190/255.f alpha:1] forState:UIControlStateNormal];
        [self.lowRatioBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    } else {
        [self.highRatioBtn setTitleColor:[UIColor colorWithRed:182/255.f green:181/255.f blue:190/255.f alpha:1] forState:UIControlStateNormal];
        [self.lowRatioBtn setTitleColor:[UIColor colorWithRed:182/255.f green:181/255.f blue:190/255.f alpha:1] forState:UIControlStateNormal];
    }
    
    self.alpha = 0.5;
    CGRect rect = self.frame;
    rect.origin.x -= rect.size.width;
    
//    [UIView animateWithDuration:0.3 animations:^{
//        self.alpha = 1;
//        self.hidden = NO;
//        self.frame = rect;
//    } completion:^(BOOL finished) {
        self.alpha = 1;
        self.frame = rect;
        self.isHidden = NO;
//    }];
    
    self.CompleteBlock = block;
}

- (void)hide {
    
    self.alpha = 1;
    CGRect rect = self.frame;
    rect.origin.x = [UIScreen mainScreen].bounds.size.width;
    
//    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0.5;
        self.frame = rect;
//    } completion:^(BOOL finished) {
        self.isHidden = YES;
//    }];
    
    self.CompleteBlock(self.hasSelected, self.selectedType);
}

- (void)highRatioAction {
    self.hasSelected = YES;
    self.selectedType = HYResolutionRatioType1080;
    
    [self.highRatioBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.lowRatioBtn setTitleColor:[UIColor colorWithRed:182/255.f green:181/255.f blue:190/255.f alpha:1] forState:UIControlStateNormal];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
         [self hide];
    });
}

- (void)lowRatioAction {
    self.hasSelected = YES;
    self.selectedType = HYResolutionRatioType480;
    
    [self.highRatioBtn setTitleColor:[UIColor colorWithRed:182/255.f green:181/255.f blue:190/255.f alpha:1] forState:UIControlStateNormal];
    [self.lowRatioBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
         [self hide];
    });
}

@end
