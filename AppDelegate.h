//
//  AppDelegate.h
//  iLGL
//
//  Created by The iLGL Team on 09/05/13.
//  Copyright (c) 2013 The iLGL Team. All rights reserved.
//

#import "TFHpple.h"
#import <MessageUI/MessageUI.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, UIAlertViewDelegate,MFMailComposeViewControllerDelegate>

{
    NSMutableData *mutableData;
}

@property (strong, nonatomic) UIWindow *window;
@property () BOOL restrictRotation;

@end
