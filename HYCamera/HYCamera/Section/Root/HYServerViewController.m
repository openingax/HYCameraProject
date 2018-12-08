//
//  HYServerViewController.m
//  HYCamera
//
//  Created by 谢立颖 on 2018/12/7.
//  Copyright © 2018 Viomi. All rights reserved.
//

#import "HYServerViewController.h"
#import "HYConfig.h"

@interface HYServerViewController ()

@end

@implementation HYServerViewController

- (instancetype)initWithConfig:(HYConfig *)config
{
    if (self = [super init]) {
        
        [KYLCamera initSDK];
        
        self.deviceID = config.deviceID;
        self.account = config.account;
        self.password = config.password;
        
        // init 时不要设置 view 的背影色等与 view 相关的属性，否则它会调用 viewDidLoad 的方法，即使没 present 这个 VC
    }
    return self;
}

- (void)dealloc {
    [KYLCamera deInitializeSDK];
}

//耳机监听模式
- (void) activeAudioSessionForListenSound
{
    //OSStatus status;
    AudioSessionInitialize(NULL, NULL, MyInterruptionListener, NULL);
    
    UInt32 inDataSize = kAudioSessionCategory_PlayAndRecord;
    AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(inDataSize), &inDataSize);
    
    inDataSize = 1;
    /*status = */AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryDefaultToSpeaker, sizeof(inDataSize), &inDataSize);
    //NSLog(@"status1:%c%c%c%c",status >> 24 & 0XFF,status>>16 & 0XFF,status>>8&0XFF, status & 0XFF);
    inDataSize = 1;
    /*status = */AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryMixWithOthers, sizeof(inDataSize), &inDataSize);
    //NSLog(@"status2:%c%c%c%c",status >> 24 & 0XFF,status>>16 & 0XFF,status>>8&0XFF,status & 0XFF);
    inDataSize = 1;
    /*status = */AudioSessionSetProperty(kAudioSessionProperty_OtherMixableAudioShouldDuck, sizeof(inDataSize), &inDataSize);
    //NSLog(@"status3:%c%c%c%c",status >> 24 & 0XFF,status>>16 & 0XFF,status>>8&0XFF,status & 0XFF);
    AudioSessionSetActive(true);
    
}

void MyInterruptionListener(void *inClientData, UInt32  inInterruptionState )
{
    
}

@end
