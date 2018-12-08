//
//  HYBaseNavigationController.m
//  HYCamera
//
//  Created by 谢立颖 on 2018/12/7.
//  Copyright © 2018 Viomi. All rights reserved.
//

#import "HYBaseNavigationController.h"
#import "HYCameraHelper.h"
#import "UIImage+HYColor.h"

@interface HYBaseNavigationController () <UINavigationControllerDelegate, UIGestureRecognizerDelegate>

@end

@implementation HYBaseNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    self.navigationBar.translucent = NO;
    self.delegate = self;
    
    [self.navigationBar setBackgroundImage:[UIImage hy_imageWithColor:[UIColor whiteColor] size:CGSizeMake(10, 10)] forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [self.navigationBar setShadowImage:[UIImage hy_imageWithColor:[UIColor colorWithRed:227/255.f green:226/255.f blue:238/255.f alpha:1] size:CGSizeMake(1, 1)]];
    [self.navigationBar setTintColor:[UIColor colorWithRed:51/255.f green:51/255.f blue:51/255.f alpha:1]];
    [self.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithRed:51/255.f green:51/255.f blue:51/255.f alpha:1],NSForegroundColorAttributeName, nil]];
    [self.navigationBar setTranslucent:NO];
    
//    __weak HYBaseNavigationController *weakSelf = self;
//    
//    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
//        self.interactivePopGestureRecognizer.delegate = self;
//        self.delegate = weakSelf;
//    }
}

//- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
//    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
//        self.interactivePopGestureRecognizer.enabled = NO;
//    }
//    [super pushViewController:viewController animated:animated];
//}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if ([viewController respondsToSelector:@selector(HYHiddenNavigatorBar)]) {
        [self setNavigationBarHidden:YES animated:YES];
    }else{
        [self setNavigationBarHidden:NO animated:YES];
    }
    
    UIViewController *root = navigationController.viewControllers[0];
    
    if (root != viewController) {
        if (!viewController.navigationItem.leftBarButtonItem) {
            UIBarButtonItem *itemleft = [[UIBarButtonItem alloc] initWithImage:[UIImage imageWithBundleAsset:@"ym_nav_back"] style:UIBarButtonItemStylePlain target:self action:@selector(backAction)];
            viewController.navigationItem.leftBarButtonItem = itemleft;
        }
    } else {
        if (!viewController.navigationItem.leftBarButtonItem) {
            UIBarButtonItem *itemleft = [[UIBarButtonItem alloc] initWithImage:[UIImage imageWithBundleAsset:@"ym_nav_back"] style:UIBarButtonItemStylePlain target:self action:@selector(dismissVCAction)];
            viewController.navigationItem.leftBarButtonItem = itemleft;
        }
    }
}

//- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
//
//    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
//        if ([self.viewControllers count] == 1) {
//            self.interactivePopGestureRecognizer.enabled = NO;
//        } else {
//            if ([viewController respondsToSelector:@selector(YMDisablePopGesture)]) {
//                self.interactivePopGestureRecognizer.enabled = NO;
//            }else{
//                self.interactivePopGestureRecognizer.enabled = YES;
//            }
//        }
//    }
//}

- (void)backAction {
    [self popViewControllerAnimated:YES];
}

- (void)dismissVCAction {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:YES completion:nil];
    });
}

@end
