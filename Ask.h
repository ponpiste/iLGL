//
//  Ask.h
//  iLGL
//
//  Created by Sacha Bartholmé on 13/07/15.
//  Copyright (c) 2015 The iLGL Team. All rights reserved.
//


@protocol AskDelegate

- (void)didEditAskSettings:(NSMutableDictionary *)newSettings;
- (void)didEditFavourite:(BOOL)favourite forIndex:(NSInteger)index;

@end

@interface Ask : UITableViewController

{
    IBOutlet UIButton *titleButton;
    IBOutlet UILabel *latin;
    IBOutlet UIImageView *latinSmudge;
    IBOutlet UILabel *french;
    IBOutlet UIImageView *frenchSmudge;
    
    IBOutlet UISegmentedControl *segmentedControl;
    IBOutlet UISwitch *smudged;
    IBOutlet UISwitch *random;
    IBOutlet UIButton *heart;
    
    NSMutableArray *cache;
}

@property (strong, nonatomic) NSMutableArray *vocabulary;
@property (assign, nonatomic) NSInteger wordCount;
@property (strong, nonatomic) NSMutableDictionary *askSettings;
@property (strong, nonatomic, readwrite) NSIndexPath *indexPath;
@property (weak, nonatomic) id delegate;

@end
