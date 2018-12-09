//
//  HYCameraSettingItemView.m
//  HYCamera
//
//  Created by 谢立颖 on 2018/12/8.
//  Copyright © 2018 Viomi. All rights reserved.
//

#import "HYCameraSettingItemView.h"
#import <Masonry.h>
#import <HYCameraHelper.h>
#import "HYSettingCellModel.h"
#import <libextobjc/EXTScope.h>

@interface HYCameraSettingItemView ()

@property(nonatomic,copy) void (^completeBlock)(NSInteger index);

@end

@implementation HYCameraSettingItemView

- (instancetype)initWithItems:(NSArray<HYSettingCellModel *> *)items complete:(void (^)(NSInteger))block {
    if (self = [super init]) {
        self.completeBlock = block;
        
        // 容器视图相关
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 5;
        
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowOffset = CGSizeMake(0, 0);
        self.layer.shadowRadius = 4;
        self.layer.shadowOpacity = 0.05;
        self.layer.masksToBounds = NO;
        
        NSMutableArray *itemViews = [[NSMutableArray new] autorelease];
        
        @weakify(self);
        [items enumerateObjectsUsingBlock:^(HYSettingCellModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            @strongify(self);
            UIView *itemView = [[self drawItemWithTitle:obj.title index:idx withBottomLine:idx != items.count - 1] autorelease];
            
            [itemViews addObject:itemView];
            [self addSubview:itemView];
            [itemView mas_makeConstraints:^(MASConstraintMaker *make) {
                if (idx == 0) {
                    make.left.top.right.equalTo(self);
                } else {
                    UIView *lastItemView = [itemViews objectAtIndex:idx-1];
                    make.top.equalTo(lastItemView.mas_bottom);
                    make.left.right.equalTo(self);
                }
                make.height.mas_equalTo(60);
            }];
        }];
    }
    
    return self;
}

- (UIView *)drawItemWithTitle:(NSString *)title index:(NSInteger)index withBottomLine:(BOOL)withBottomLine {
    UIView *container = [[[UIView alloc] init] autorelease];
    container.tag = index;
    container.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(itemClickAction:)];
    [container addGestureRecognizer:tap];
    [tap release];
    
    UILabel *titleLabel = [[[UILabel alloc] init] autorelease];
    titleLabel.text = title;
    titleLabel.font = [UIFont systemFontOfSize:14];
    titleLabel.textColor = [UIColor colorWithRed:64/255.0 green:64/255.0 blue:64/255.0 alpha:1/1.0];
    [container addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(container).with.offset(15);
        make.centerY.equalTo(container);
    }];
    
    UIImageView *indicatorImgView = [[[UIImageView alloc] initWithImage:[UIImage imageWithBundleAsset:@"ym_user_center_indicator"]] autorelease];
    [container addSubview:indicatorImgView];
    [indicatorImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(container).with.offset(-15);
        make.centerY.equalTo(container);
        make.size.mas_equalTo(CGSizeMake(12, 12));
    }];
    
    if (withBottomLine) {
        UIView *bottomLine = [[[UIView alloc] init] autorelease];
        bottomLine.backgroundColor = [UIColor colorWithRed:227/255.0 green:226/255.0 blue:238/255.0 alpha:1/1.0];
        [container addSubview:bottomLine];
        [bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(container).with.offset(10);
            make.right.equalTo(container);
            make.bottom.equalTo(container);
            make.height.mas_equalTo(0.5);
        }];
    }
    
    return container;
}

- (void)itemClickAction:(UITapGestureRecognizer *)gesture {
    
    if (self.completeBlock) {
        self.completeBlock(gesture.view.tag);
    }
}

@end
