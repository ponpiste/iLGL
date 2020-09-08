//
//  Chapters.h
//  iLGL
//
//  Created by Sacha Bartholmé on 12/08/15.
//  Copyright (c) 2015 The iLGL Team. All rights reserved.
//


@protocol ChaptersDelegate 

- (void)didEditSelected:(NSArray *)newSelected;

@end

@interface Chapters : UITableViewController

{
    IBOutlet UIButton *titleButton;
    
    NSInteger wordCount;
    NSInteger selectedWords;
}

@property (strong, nonatomic) NSArray *chapters;
@property (strong, nonatomic) NSMutableArray *selected;
@property (weak, nonatomic) id delegate;

@end
