//
//  Menu.h
//  iLGL
//
//  Created by Sacha Bartholmé on 11/07/15.
//  Copyright (c) 2015 The iLGL Team. All rights reserved.
//


@interface Menu : UITableViewController

{
    IBOutlet UIImageView *rel;
    IBOutlet UIImageView *cutlery;
    IBOutlet UIImageView *news;
    IBOutlet UIImageView *palm;
    IBOutlet UIImageView *pen;
    
    NSMutableDictionary *cache;
    NSString *identifier;
}

@end
