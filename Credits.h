//
//  Credits.h
//  iLGL
//
//  Created by Sacha Bartholmé on 12/07/15.
//  Copyright (c) 2015 The iLGL Team. All rights reserved.
//

#import <MessageUI/MessageUI.h>

@interface Credits : UITableViewController <UIAlertViewDelegate, MFMailComposeViewControllerDelegate>

{
    IBOutlet UILabel *label;
}

@end
