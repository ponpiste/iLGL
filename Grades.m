//
//  Grades.m
//  iLGL
//
//  Created by Sacha Bartholmé on 7/11/16.
//  Copyright © 2016 The iLGL Team. All rights reserved.
//

#import "Grades.h"
#import "SWRevealViewController.h"

@implementation Grades

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem.target = self.revealViewController;
    self.navigationItem.leftBarButtonItem.action = @selector(revealToggle:);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    [self.view addGestureRecognizer:self.revealViewController.tapGestureRecognizer];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    appDelegate.restrictRotation = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    appDelegate.restrictRotation = YES;
    
    [UIView animateWithDuration:1 animations:^{
        label.alpha = 1;
    } completion:^(BOOL finished){
        [UIView animateWithDuration:1 animations:^{
            button.alpha = 1;
        }];
    }];
}

- (IBAction)download {
    
    NSURL *url = [NSURL URLWithString:@"itms-apps://itunes.apple.com/app/id1102506814"];
    [[UIApplication sharedApplication]openURL:url];
}

@end
