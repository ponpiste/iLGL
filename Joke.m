//
//  Joke.m
//  iLGL
//
//  Created by Sacha Bartholmé on 24/02/15.
//  Copyright (c) 2015 The iLGL Team. All rights reserved.
//

#import "Joke.h"

@implementation Joke

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1) {
        
        jokeTextView.backgroundColor = [UIColor clearColor];
        
        UIVisualEffect *blurEffect;
        blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        
        UIVisualEffectView *visualEffectView;
        visualEffectView = [[UIVisualEffectView alloc]initWithEffect:blurEffect];
        visualEffectView.frame = self.view.bounds;
        
        [self.view insertSubview:visualEffectView belowSubview:jokeTextView];
    }
    
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    
    NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    self.navigationItem.rightBarButtonItem.enabled = [jokeTextView.text stringByTrimmingCharactersInSet:set].length > 40;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    mutableData = [NSMutableData new];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [jokeTextView becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)textViewDidChange:(UITextView *)textView {
    
    NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    self.navigationItem.rightBarButtonItem.enabled = [textView.text stringByTrimmingCharactersInSet:set].length > 40;
    
    if ([textView.text.lowercaseString isEqualToString:@"lol"]) { // Top secret
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setBool:NO forKey:@"isWritingJoke"];
        [userDefaults synchronize];
        
        [self dismissViewControllerAnimated:YES completion:nil];
        
    } else if ([textView.text.lowercaseString isEqualToString:@"delete user"]) {
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        
        [userDefaults removeObjectForKey:@"firstName"];
        [userDefaults removeObjectForKey:@"lastName"];
        [userDefaults removeObjectForKey:@"class"];
        [userDefaults removeObjectForKey:@"identify"];
        [userDefaults setBool:NO forKey:@"isWritingJoke"];
        [userDefaults synchronize];
        
        [NSThread sleepForTimeInterval:0.5];
        exit(0);
        
    } else if ([textView.text.lowercaseString isEqualToString:@"delete joke"]) {
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        
        [userDefaults removeObjectForKey:@"joke_text"];
        [userDefaults removeObjectForKey:@"joke_date"];
        [userDefaults setBool:NO forKey:@"isWritingJoke"];
        [userDefaults synchronize];
        
    } else if ([textView.text.lowercaseString isEqualToString:@"delete highscore"]) {
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        
        [userDefaults removeObjectForKey:@"highscore"];
        [userDefaults setBool:NO forKey:@"isWritingJoke"];
        [userDefaults synchronize];
        
        [NSThread sleepForTimeInterval:0.5];
        exit(0);
    }
}

- (void)keyboardWillShow:(NSNotification*)notification {
    
    NSValue *keyboardFrameValue = [notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardFrame = [keyboardFrameValue CGRectValue];
    
    UIEdgeInsets contentInsets = jokeTextView.contentInset;
    contentInsets.bottom = CGRectGetHeight(keyboardFrame);
    
    jokeTextView.contentInset = contentInsets;
    jokeTextView.scrollIndicatorInsets = contentInsets;
}

- (void)keyboardWillHide:(NSNotification*)notification {
    
    UIEdgeInsets contentInsets = jokeTextView.contentInset;
    contentInsets.bottom = .0;
    
    jokeTextView.contentInset = contentInsets;
    jokeTextView.scrollIndicatorInsets = contentInsets;
}

- (IBAction)done {
    
    NSMutableString *joke = [NSMutableString stringWithString:jokeTextView.text];
    
    NSData *data = [joke dataUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"Uploading joke");
    //[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    NSURL *url = [NSURL URLWithString:@"http://ilgl.eu/joke.php"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10.0];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:data];
    
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
    [connection start];
}

#pragma mark - URLConnection delegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    [mutableData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [mutableData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    NSLog(@"%@", [[NSString alloc]initWithData:mutableData encoding:NSUTF8StringEncoding]);
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:NO forKey:@"isWritingJoke"];
    [userDefaults synchronize];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    
    NSLog(@"%@",error.localizedDescription);
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    self.navigationItem.rightBarButtonItem.enabled = YES;
    self.navigationItem.rightBarButtonItem.style = UIBarButtonItemStyleDone;
    
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"error", nil) message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alertView show];
}

@end
