//
//  HYWiFiConfigViewController.m
//  HYCamera
//
//  Created by 谢立颖 on 2018/12/8.
//  Copyright © 2018 Viomi. All rights reserved.
//

#import "HYWiFiConfigViewController.h"
#import <SystemConfiguration/CaptiveNetwork.h>

@interface HYWiFiConfigViewController ()

@end

@implementation HYWiFiConfigViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (NSDictionary *)fetchCurrentWiFi {
    NSDictionary *wifi = nil;
    CFArrayRef wifiInterfaces = CNCopySupportedInterfaces();
    
    NSArray *interfaces = (__bridge NSArray *)wifiInterfaces;
    
    for (NSString *interfaceName in interfaces) {
        CFDictionaryRef dictRef = CNCopyCurrentNetworkInfo((__bridge CFStringRef)(interfaceName));
        
        if (dictRef) {
            NSDictionary *networkInfo = (__bridge NSDictionary *)dictRef;
            NSLog(@"network info -> %@", networkInfo);
            
            wifi = networkInfo;
            
            CFRelease(dictRef);
        }
    }
    CFRelease(wifiInterfaces);
    
    return wifi;
}

@end
