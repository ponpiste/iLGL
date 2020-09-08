//
//  Credits.m
//  iLGL
//
//  Created by Sacha Bartholmé on 12/07/15.
//  Copyright (c) 2015 The iLGL Team. All rights reserved.
//

#import "Credits.h"
#import "SWRevealViewController.h"

@implementation Credits

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem.target = self.revealViewController;
    self.navigationItem.leftBarButtonItem.action = @selector(revealToggle:);
    
    self.tableView.contentInset = UIEdgeInsetsMake(-10, 0, 0, 0);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    [self.view addGestureRecognizer:self.revealViewController.tapGestureRecognizer];
    
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        
        if (indexPath.row == 2) {
            
            MFMailComposeViewController *mc = [MFMailComposeViewController new];
            mc.mailComposeDelegate = self;
            [mc setSubject:@"iLGL"];
            [mc setMessageBody:@"Déi App ass déck cool !!! 😍😍😍" isHTML:NO];
            [mc setToRecipients:@[@"the.ilgl.team@gmail.com"]];
            [self presentViewController:mc animated:YES completion:nil];
            
        } else if (indexPath.row == 3) {
            
            NSURL *url = [NSURL URLWithString:@"fb://profile/1411084939108681"];
            
            if (![[UIApplication sharedApplication]canOpenURL:url]) {
                url = [NSURL URLWithString:@"https://www.facebook.com/ilglCompanionApp?fref=ts"];
            }
            [[UIApplication sharedApplication]openURL:url];
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        }
        
    } else if (indexPath.section == 1) {
        
        if (indexPath.row == 0) {
            
            NSURL *url = [NSURL URLWithString:@"http://aizide.lgl.lu/lgl.lu/index.php"];
            [[UIApplication sharedApplication]openURL:url];
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
            
        } else if (indexPath.row == 1) {
            
            MFMailComposeViewController *mc = [MFMailComposeViewController new];
            mc.mailComposeDelegate = self;
            [mc setToRecipients:@[@"secretariat@lgl.lu"]];
            [self presentViewController:mc animated:YES completion:nil];
            
        } else if (indexPath.row == 2) {
            
            NSURL *url = [NSURL URLWithString:@"tel:+3522223021"];
            [[UIApplication sharedApplication] openURL:url];
            
        } else {
            
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"error", nil) message:NSLocalizedString(@"fax", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alertView show];
        }
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
