//
//  Ranking.h
//  iLGL
//
//  Created by Sacha Bartholmé on 1/8/16.
//  Copyright © 2016 The iLGL Team. All rights reserved.
//


@protocol RankingDelegate

- (void)didDownloadHighscores:(NSArray *)newHighscores;

@end

@interface Ranking : UITableViewController <UIAlertViewDelegate>

{
    NSMutableData *mutableData;
    NSURLConnection *highscoresConnection;
    
    BOOL first;
}

@property (strong,nonatomic) NSArray *highscores;
@property (strong,nonatomic) NSString *name;
@property (weak,nonatomic) id delegate;

@end
