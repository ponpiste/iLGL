//
//  Settings.h
//  iLGL
//
//  Created by Sacha Bartholmé on 13/07/15.
//  Copyright (c) 2015 The iLGL Team. All rights reserved.
//

#import "Chapters.h"

@protocol SettingsDelegate 

- (void)didEditSelected:(NSMutableArray *)newSelected;

@end

@interface Settings : UITableViewController <ChaptersDelegate>

{
    NSMutableArray *vocabulary;
    NSRange range;
    NSInteger wordCount;
    NSInteger selectedWords;
    IBOutlet UIButton *titleButton;
}

@property (strong, nonatomic) NSMutableArray *selected;
@property (weak, nonatomic) id delegate;

@end
