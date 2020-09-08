//
//  News.h
//  Contern
//
//  Created by Sacha Bartholmé on 5/29/16.
//  Copyright © 2016 Sacha Bartholmé. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TFHpple.h"
#import "SWRevealViewController.h"

@interface News : UIViewController <UIScrollViewDelegate, UIWebViewDelegate>

{
    IBOutlet UIWebView *newsWebView;
    IBOutlet UIActivityIndicatorView *activityIndicator;
    
    BOOL fileExists,didRefresh,offlineContent,jokeButton;
    NSString *mime;
    NSURLConnection *jokeConnection;
    NSMutableString *htmlString;
    NSMutableData *mutableData;
}

@end
