//
//  Schedule.h
//  iLGL
//
//  Created by Sacha Bartholmé on 05/09/15.
//  Copyright (c) 2015 The iLGL Team. All rights reserved.
//


@interface Schedule : UIViewController <UIWebViewDelegate>

{
    IBOutlet UIWebView *scheduleWebView;
    IBOutlet UIButton *titleButton;
    IBOutlet UIActivityIndicatorView *indicator;
    
    NSInteger titleIndex;
    NSMutableData *mutableData;
    NSURLConnection *scheduleConnection;
    NSString *userclass;
    BOOL fileExists;
}

@end
