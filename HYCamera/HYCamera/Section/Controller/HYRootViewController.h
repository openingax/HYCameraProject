//
//  HYRootViewController.h
//  HYCamera
//
//  Created by 谢立颖 on 2018/12/7.
//  Copyright © 2018 Viomi. All rights reserved.
//

#import "HYServerViewController.h"

#import "KYLCamera.h"
#import "KYLCameraProtocol.h"
#import "KYLSearchProtocol.h"
#import "KYLSearchTool.h"
#import "KYLCameraMonitor.h"

@class KYLWifiObject;
@interface HYRootViewController : HYServerViewController <KYLCameraProtocol, KYLSearchProtocol, KYLMontiorTouchProtocol>
{
    KYLCamera                   *m_pCamera;
    KYLWifiObject               *selectedWifiObject;
}

@property (nonatomic, retain) KYLCameraMonitor *pCameraMonitor;
@property (nonatomic, retain) KYLCamera *m_pCamera;
@property (nonatomic, retain) KYLWifiObject *selectedWifiObject;

@property (nonatomic, copy) NSString *strDID;
@property (nonatomic, retain)  UIImageView *imgViewShowVideo;

@end
