//
//  Menu.m
//  iLGL
//
//  Created by Sacha Bartholmé on 11/07/15.
//  Copyright (c) 2015 The iLGL Team. All rights reserved.
//

#import "Menu.h"
#import "SWRevealViewController.h"

@implementation Menu

#pragma mark - Navigation

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UINavigationController *navigation = (UINavigationController *)self.revealViewController.frontViewController;
    cache = [NSMutableDictionary dictionaryWithDictionary:@{@"Surveillance": navigation.topViewController}];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (cache[identifier]) {
        
        UINavigationController* navController = (UINavigationController*)self.revealViewController.frontViewController;
        [navController setViewControllers: @[cache[identifier]] animated: NO];
        [self.revealViewController setFrontViewPosition:FrontViewPositionLeft animated:YES];
        
    } else [self performSegueWithIdentifier:identifier sender:nil];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ( [segue isKindOfClass: [SWRevealViewControllerSegue class]] ) {
        SWRevealViewControllerSegue *swSegue = (SWRevealViewControllerSegue*) segue;
        
        swSegue.performBlock = ^(SWRevealViewControllerSegue* rvc_segue, UIViewController* svc, UIViewController* dvc) {
            
            NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            identifier = cell.reuseIdentifier;
            if(!cache[identifier]) cache[identifier] = segue.destinationViewController;
            
            UINavigationController* navController = (UINavigationController*)self.revealViewController.frontViewController;
            [navController setViewControllers: @[dvc] animated: NO ];
            [self.revealViewController setFrontViewPosition:FrontViewPositionLeft animated:YES];
        };
    }
}

@end
