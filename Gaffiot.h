//
//  Gaffiot.h
//  iLGL
//
//  Created by Sacha Bartholmé on 17/08/15.
//  Copyright (c) 2015 The iLGL Team. All rights reserved.
//


@interface Gaffiot : UIViewController <UITextFieldDelegate, UIWebViewDelegate, UIAlertViewDelegate, NSURLConnectionDelegate, UIGestureRecognizerDelegate, UIScrollViewDelegate>

{
    IBOutlet UIWebView *gaffiotWebView;
    IBOutlet UITextField *searchTextField;
    IBOutlet UILabel *progressLabel;
    IBOutlet UILabel *sizeLabel;
    IBOutlet UIProgressView *progressView;
    IBOutlet UIActivityIndicatorView *indicator;
    
    NSMutableData *mutableData;
    NSURLConnection *download;
    NSNumberFormatter *formatter;
    NSInteger index;
    NSArray *words;
    NSArray *searchResults;
    BOOL fileExists;
}

@end
