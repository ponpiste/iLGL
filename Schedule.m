//
//  Schedule.m
//  iLGL
//
//  Created by Sacha Bartholmé on 05/09/15.
//  Copyright (c) 2015 The iLGL Team. All rights reserved.
//

#import "Schedule.h"
#import "SWRevealViewController.h"

@implementation Schedule

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem.target = self.revealViewController;
    self.navigationItem.leftBarButtonItem.action = @selector(revealToggle:);
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
        
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *name = [userDefaults objectForKey:@"firstName"];
    userclass = [userDefaults objectForKey:@"class"];
    
    if (name.length > 1) [titleButton setTitle:name forState:UIControlStateNormal];
    else [titleButton setTitle:NSLocalizedString(@"schedule", nil) forState:UIControlStateNormal];
    
    if (userclass.length > 1) {

        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *path = [NSString stringWithFormat:@"%@/%@.pdf", paths[0],userclass];
        fileExists = [[NSFileManager defaultManager] fileExistsAtPath:path];
        
        if (fileExists) {
            
            if (!scheduleWebView.request) [scheduleWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:path]]];
            
        } else {
            
            scheduleWebView.alpha = 0.0;
            indicator.alpha = 1.0;
            [indicator startAnimating];
        }
        
        NSLog(@"Downloading schedule");
        NSString *link = [NSString stringWithFormat:@"http://ilgl.eu/schedules/%@.pdf", userclass];
        NSURL *url = [NSURL URLWithString:link];
        mutableData = [NSMutableData new];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:fileExists ? 10000.0 : 10.0];
        scheduleConnection = [NSURLConnection connectionWithRequest:request delegate:self];
        [scheduleConnection start];
        //[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        
    } else {
        
        NSString *path = [[NSBundle mainBundle]bundlePath];
        NSURL *baseURL = [NSURL fileURLWithPath:path];
        
        NSString *HTML = [NSString stringWithFormat:@"<html><head><link rel=\"stylesheet\" href=\"schedule.css\"/><meta name=\"viewport\" content=\"width=device-width; initial-scale=1.0; maximum-scale=1.0;\"></head><body><div class=\"area\"><div class=\"bubble\"><p>%@</p></div></div></body></html>", NSLocalizedString(name.length > 0 ? @"you're a teacher" : @"no ID" , nil)];
        [scheduleWebView loadHTMLString:HTML baseURL:baseURL];
    }
    
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    [self.view addGestureRecognizer:self.revealViewController.tapGestureRecognizer];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [scheduleConnection cancel];
}

- (IBAction)didSelectTitle {/*
    
    if (![titleButton.titleLabel.text isEqualToString:NSLocalizedString(@"schedule", nil)]) {
        
        NSString *title;
        switch (titleIndex) {
            case 0:
                title = @"28 hours";
                break;
                
            case 1:
                title = @"8 march 2015";
                break;
                
            default:
                title = [[[NSUserDefaults standardUserDefaults] objectForKey:@"user"] componentsSeparatedByString:@" <br> "][1];
                break;
        }
        
        [titleButton setTitle:title forState:UIControlStateNormal];
        [titleButton sizeToFit];
        titleButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        
        titleIndex = titleIndex == 2 ? 0 : titleIndex + 1;
    }
*/}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    
    if (!scheduleWebView.request) scheduleWebView.alpha = 0.0;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
    [UIView animateWithDuration:0.5 animations:^{webView.alpha = 1.0;}];
}

#pragma mark - NSURLConnection Delegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    [mutableData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [mutableData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [UIView animateWithDuration:0.4 animations:^{indicator.alpha = 0.0;} completion:^(BOOL finished){[indicator stopAnimating];}];
    
    NSString *content = [[NSString alloc] initWithData:mutableData encoding:NSUTF8StringEncoding];
    
    if ([content hasPrefix:@"<"] && !fileExists) {
        
        NSString *path = [[NSBundle mainBundle]bundlePath];
        NSURL *baseURL = [NSURL fileURLWithPath:path];
        
        NSString *HTML = [NSString stringWithFormat:@"<html><head><link rel=\"stylesheet\" href=\"schedule.css\"/><meta name=\"viewport\" content=\"width=device-width; initial-scale=1.0; maximum-scale=1.0;\"></head><body><div class=\"area\"><div class=\"bubble\"><p>%@</p></div></div></body></html>", NSLocalizedString(@"no schedule", nil)];
        [scheduleWebView loadHTMLString:HTML baseURL:baseURL];
        
    } else if (![content hasPrefix:@"<"]) {
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *path = [NSString stringWithFormat:@"%@/%@.pdf", paths[0],userclass];
        //[titleButton setTitle:userclass forState:UIControlStateNormal];
        
        BOOL sameFile = [[NSData dataWithContentsOfFile:path] isEqualToData:mutableData];
        
        if (!sameFile) {
            
            [mutableData writeToFile:path atomically:YES];
            fileExists = YES;
            [UIView animateWithDuration:0.4 animations:^{
                
                scheduleWebView.alpha = 0.0;
                
            } completion:^(BOOL finished){
                
                NSURL *URL = [NSURL URLWithString:path];
                NSURLRequest *request = [NSURLRequest requestWithURL:URL];
                [scheduleWebView loadRequest:request];
            }];
        };
        
        NSLog(@"Schedule downloaded, %@", sameFile ? @"but the file isn't new" : @"it's a new file");
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    
    NSLog(@"%@",error.localizedDescription);
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [UIView animateWithDuration:0.4 animations:^{indicator.alpha = 0.0;} completion:^(BOOL finished){[indicator stopAnimating];}];
    
    if (!fileExists) {
        
        NSString *path = [[NSBundle mainBundle]bundlePath];
        NSURL *baseURL = [NSURL fileURLWithPath:path];
        
        NSString *HTML = [NSString stringWithFormat:@"<html><head><link rel=\"stylesheet\" href=\"schedule.css\"/><meta name=\"viewport\" content=\"width=device-width; initial-scale=1.0; maximum-scale=1.0;\"></head><body><div class=\"area\"><div class=\"bubble\"><p>%@</p></div></div></body></html>", error.localizedDescription];
        [scheduleWebView loadHTMLString:HTML baseURL:baseURL];
    }
}

@end
