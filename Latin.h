//
//  Latin.h
//  iLGL
//
//  Created by Sacha Bartholmé on 13/07/15.
//  Copyright (c) 2015 The iLGL Team. All rights reserved.
//

#import "Ask.h"
#import "Settings.h"

@interface Latin : UITableViewController <UISearchControllerDelegate, UISearchBarDelegate, AskDelegate, SettingsDelegate>

{
    NSMutableArray *vocabulary;
    NSArray *temporaryVoc;
    NSMutableArray *searchResults;
    NSMutableDictionary *askSettings;
    NSMutableArray *selected;
    NSMutableArray *favourites;
    
    IBOutlet UIButton *titleButton;
}

@end
