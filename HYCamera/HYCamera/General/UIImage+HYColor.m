//
//  UIImage+HYColor.m
//  HYCamera
//
//  Created by 谢立颖 on 2018/12/8.
//  Copyright © 2018 Viomi. All rights reserved.
//

#import "UIImage+HYColor.h"

@implementation UIImage (HYColor)

+ (UIImage *)hy_imageWithColor:(UIColor *)color size:(CGSize)size {
    if (color == nil) {
        return nil;
    }
    
    CGRect rect=CGRectMake(0.0f, 0.0f, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

@end
