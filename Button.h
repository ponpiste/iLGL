//
//  Button.h
//  iLGL
//
//  Created by Sacha Bartholmé on 1/7/16.
//  Copyright © 2016 The iLGL Team. All rights reserved.
//

#import "Ranking.h"

@interface Button : UIViewController <RankingDelegate>

{
    NSInteger centiseconds,highscore;
    NSTimer *timer;
    NSMutableData *mutableData;
    NSURLConnection *download;
    NSArray *highscores;
    NSString *name;
    
    IBOutlet UILabel *timeLabel;
    IBOutlet UILabel *highscoreLabel;
}

@end
