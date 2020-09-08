//
//  Holidays.h
//  iLGL
//
//  Created by Sacha Bartholmé on 21/10/2014.
//  Copyright (c) 2014 The iLGL Team. All rights reserved.
//



@interface Holidays : UITableViewController <UIAlertViewDelegate>

{
    NSTimer *timer;
    BOOL fileExists;
    
    NSMutableData *mutableData;
    NSURLConnection *automaticConnection;
    
    NSNumberFormatter *numberFormatter;
    NSDate *start;
    NSDate *end;
    NSInteger titleIndex;
    NSInteger currentTerm;
    NSNumber *progress;
    
    NSArray *holidays;
    NSMutableArray *sortedArray;
    
    IBOutlet UIButton *titleButton;
}

@end
