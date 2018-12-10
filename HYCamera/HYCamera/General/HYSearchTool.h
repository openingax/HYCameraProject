//
//  HYSearchTool.h
//  HYCamera
//
//  Created by 谢立颖 on 2018/12/10.
//  Copyright © 2018 Viomi. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kHYCameraConnStatusKey @"kHYCameraConnStatusKey"

@protocol HYSearchToolDelegate <NSObject>

- (void)didSucceedSearchOneDevice: (NSString *) chDID ip:(NSString *) ip port:(int) port devName:(NSString *) devName macaddress:(NSString *) mac productType:(NSString *) productType;

@end

@interface HYSearchTool : NSObject

@property(nonatomic,weak) id <HYSearchToolDelegate> delegate;

- (void)startSearch;
- (void)stopSearch;

@end
