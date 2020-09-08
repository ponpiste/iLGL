//
//  Countdown.h
//  iLGL
//
//  Created by Sacha Bartholmé on 21/10/2014.
//  Copyright (c) 2014 The iLGL Team. All rights reserved.
//



@interface Countdown : UITableViewController <UIAlertViewDelegate>

{
    NSTimer *countdownTimer;
    NSTimer *progressTimer;
    NSNumber *progress;
    NSNumber *duration;
    NSNumberFormatter *formatter;
    NSInteger titleIndex;
    NSInteger durationIndex;
    NSInteger alertViewIndex;
    UIAlertView *dateAlertView;
    
    IBOutlet UIButton *titleButton;
    IBOutlet UIButton *durationButton;
    
    IBOutlet UILabel *daysStart;
    IBOutlet UILabel *hoursStart;
    IBOutlet UILabel *minutesStart;
    IBOutlet UILabel *secondsStart;
    IBOutlet UILabel *monthsStart;
    
    IBOutlet UILabel *daysEnd;
    IBOutlet UILabel *hoursEnd;
    IBOutlet UILabel *minutesEnd;
    IBOutlet UILabel *secondsEnd;
    IBOutlet UILabel *monthsEnd;
}

@property (strong, nonatomic) NSDictionary *holidays;
@property (strong, nonatomic) NSString *name;

@end
