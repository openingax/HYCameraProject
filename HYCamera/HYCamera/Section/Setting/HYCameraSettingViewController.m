//
//  HYCameraSettingViewController.m
//  HYCamera
//
//  Created by 谢立颖 on 2018/12/8.
//  Copyright © 2018 Viomi. All rights reserved.
//

#import "HYCameraSettingViewController.h"
#import <Masonry.h>
#import "HYCameraSettingItemView.h"
#import <libextobjc/EXTScope.h>
#import "HYSettingCellModel.h"

@interface HYCameraSettingViewController ()

@end

@implementation HYCameraSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"设置";
    self.view.backgroundColor = [UIColor colorWithRed:247/255.f green:247/255.f blue:247/255.f alpha:1];
    [self drawView];
}

- (void)drawView {
    HYSettingCellModel *cell0 = [[HYSettingCellModel alloc] init];
    HYSettingCellModel *cell1 = [[HYSettingCellModel alloc] init];
    HYSettingCellModel *cell2 = [[HYSettingCellModel alloc] init];
    
    cell0.title = @"通用设置";
    cell1.title = @"设备名称";
    cell1.detail = self.deviceName;
    cell2.title = @"配置 Wi-Fi";
    
//    NSArray *items = @[cell0, cell1, cell2];
    NSArray *items = [NSArray arrayWithObjects:cell0, cell1, cell2, nil];
    
    @weakify(self);
    HYCameraSettingItemView *itemView = [[HYCameraSettingItemView alloc] initWithItems:items complete:^(NSInteger index) {
        @strongify(self);
        [self didCellClicked:index];
    }];
    [self.view addSubview:itemView];
    [itemView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).with.offset(20);
        make.left.equalTo(self.view).with.offset(20);
        make.right.equalTo(self.view).with.offset(-20);
        make.height.mas_equalTo(60*items.count);
    }];
}

- (void)didCellClicked:(NSInteger)index {
    
}

@end
