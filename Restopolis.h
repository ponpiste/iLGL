//
//  Restopolis.h
//  iLGL
//
//  Created by The iLGL Team on 21/05/13.
//  Copyright (c) 2013 The iLGL Team. All rights reserved.
//



@interface Restopolis : UIViewController <NSXMLParserDelegate, UIGestureRecognizerDelegate, UIWebViewDelegate, UIScrollViewDelegate, NSURLConnectionDelegate>

{
    IBOutlet UISegmentedControl *segmentedControl;
    IBOutlet UIWebView *restopolisWebView;
        
    NSDate *date;
    NSDate *newDate;
    NSXMLParser *XMLparser;
			
	NSMutableString *currentString;
	NSMutableData *mutableData;
    NSURLConnection *menusConnection;
	
    NSMutableArray *cafeteria;
    NSMutableArray *cantine;
}

@end
