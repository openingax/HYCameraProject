//
//  HYSearchTool.m
//  HYCamera
//
//  Created by 谢立颖 on 2018/12/10.
//  Copyright © 2018 Viomi. All rights reserved.
//

#import "HYSearchTool.h"
#import "KYLSearchTool.h"

@interface HYSearchTool () <KYLSearchProtocol>

@property(nonatomic,retain) KYLSearchTool *searchTool;

@end

@implementation HYSearchTool

- (instancetype)init {
    if (self = [super init]) {
        
        if (!self.searchTool) {
            self.searchTool = [[KYLSearchTool alloc] init];
            self.searchTool.delegate = self;
        }
    }
    return self;
}

- (void)dealloc {
    if (self.searchTool) {
        self.searchTool.delegate = nil;
        [self.searchTool release];
        self.searchTool = nil;
    }
    
    [super dealloc];
}

- (void)startSearch {
    if (self.searchTool) {
        [self.searchTool startSearch];
    }
}

- (void)stopSearch {
    if (self.searchTool) {
        [self.searchTool stopSearch];
    }
}

- (void)didSucceedSearchOneDevice: (NSString *) chDID ip:(NSString *) ip port:(int) port devName:(NSString *) devName macaddress:(NSString *) mac productType:(NSString *) productType {
    if ([_delegate respondsToSelector:@selector(didSucceedSearchOneDevice:ip:port:devName:macaddress:productType:)]) {
        [_delegate didSucceedSearchOneDevice:chDID ip:ip port:port devName:devName macaddress:mac productType:productType];
    }
}

@end
