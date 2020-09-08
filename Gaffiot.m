//
//  Gaffiot.m
//  iLGL
//
//  Created by Sacha Bartholmé on 17/08/15.
//  Copyright (c) 2015 The iLGL Team. All rights reserved.
//

#import "Gaffiot.h"
#import "ZipArchive/Main.h"

@implementation Gaffiot

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.topItem.title = @" ";
    
    UIBarButtonItem *rewind = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"rewind.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(rewind)];
    UIBarButtonItem *forward = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"forward.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(forward)];
    self.navigationItem.rightBarButtonItems = @[forward, rewind];
    
    searchTextField.tintColor = [UIColor whiteColor];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [NSString stringWithFormat:@"%@/%@", paths[0], @"Gaffiot/glossary.txt"];
    fileExists = [[NSFileManager defaultManager]fileExistsAtPath:path];
    
    if (fileExists) {
        
        NSString *string = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
        words = [string componentsSeparatedByString:@"\n"];
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        index = [userDefaults integerForKey:@"gaffiot"];
        
    } else {
        
        searchTextField.text = @"Félix Gaffiot";
    }
    
    [UIApplication sharedApplication].idleTimerDisabled = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    [download cancel];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (fileExists) [self load];
    else {
        
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Dictionnaire illustré latin - français (1934)" message:NSLocalizedString(@"gaffiot", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) otherButtonTitles:NSLocalizedString(@"download", nil), nil];
        [alertView show];
    }
}

- (void)delete {
    
    [searchTextField resignFirstResponder];
    [indicator startAnimating];
    
    [UIView animateWithDuration:0.4 animations:^{
        
        indicator.alpha = 1.0;
        
    } completion:^(BOOL finished){
    
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *file = [NSString stringWithFormat:@"%@/%@", paths[0], @"Gaffiot"];
            
            [[NSFileManager defaultManager] removeItemAtPath:file error:nil];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                NSLog(@"Gaffiot deleted");
                [self.navigationController popToRootViewControllerAnimated:YES];
            });
        });
    }];
}

- (void)load {
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setInteger:index forKey:@"gaffiot"];
    [userDefaults synchronize];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [NSString stringWithFormat:@"%@/%@/%@", paths[0], @"Gaffiot", [NSString stringWithFormat:@"%d.tif", index]];
    NSURL *url = [NSURL URLWithString:path];
    [gaffiotWebView loadRequest:[NSURLRequest requestWithURL:url]];
}

- (IBAction)didSelectTitle:(UIButton *)sender {
    
    [sender setTitle:[sender.titleLabel.text isEqualToString:@"Gaffiot"] ? @"Félix" : [sender.titleLabel.text isEqualToString:@"Félix"] ? @"1934" : @"Gaffiot" forState:UIControlStateNormal];
}

- (void)rewind {
    
    if (fileExists) {
        
        index = index == 0 ? words.count - 1 : index - 1;
        [self load];
    }
}

- (void)forward {
    
    if (fileExists) {
        
        index = index == words.count - 1 ? 0 : index + 1;
        [self load];
    }
}

- (IBAction)didEndOnExit:(UITextField *)sender {
    [sender resignFirstResponder];
}

- (IBAction)editingDidBegin:(UITextField *)sender {
    sender.text = @"";
}

- (IBAction)editingChanged:(UITextField *)sender {
    
    NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *searchText = [sender.text stringByTrimmingCharactersInSet:set].lowercaseString;
    
    if (searchText.length > 0 && fileExists) {
        
        NSInteger value = labs(searchText.integerValue);
        if (value < words.count + 1 && value > 0) {
            
            index = value - 1;
            [self load];
        }
        
        else if ([searchText isEqualToString:NSLocalizedString(@"delete", nil)]) {
            
            [self delete];
            
        } else if ([searchText isEqualToString:@"collatinus"]) {
        
            NSURL *url = [NSURL URLWithString:@"http://collatinus.fltr.ucl.ac.be"];
            [gaffiotWebView loadRequest:[NSURLRequest requestWithURL:url]];
            
        } else if ([searchText isEqualToString:@"close"]) {
            
            //UIApplication *app = [UIApplication sharedApplication];
            //[app performSelector:@selector(suspend)];
            
        } else {
            
            if ([searchText compare:@"a"] == NSOrderedAscending || [searchText compare:@"zy"] == NSOrderedDescending) {
                
                index = words.count - 1;
                
            } else {
                
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF >= %@", searchText];
                searchResults = [words filteredArrayUsingPredicate:predicate];
                
                if (searchResults.count > 0) {
                    
                    index = [words indexOfObject:searchResults[0]];
                    if ([searchText.lowercaseString compare:words[index]] == NSOrderedAscending) index --;
                }
            }
            [self load];
        }
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
    BOOL hidden = webView.alpha == 0.0;
    [UIView animateWithDuration:0.5 animations:^{
        
        webView.alpha = 1.0;
    
    } completion:^(BOOL finished){
    
        if (hidden) [searchTextField becomeFirstResponder];
    }];
}

#pragma mark - Gesture recognizer delegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return NO;
}

- (IBAction)tap {
    
    //[self.navigationController setNavigationBarHidden:!self.navigationController.navigationBarHidden animated:YES];
}

- (IBAction)leftSwipe {
    [self forward];
}

- (IBAction)rightSwipe {
    [self rewind];
}

# pragma mark - Alert view delegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 0) [self.navigationController popToRootViewControllerAnimated:YES];
    else {
        
        [UIView animateWithDuration:0.5 animations:^{
            
            progressLabel.alpha = 1.0;
            progressView.alpha = 1.0;
            sizeLabel.alpha = 1.0;
        }];
        
        NSLog(@"Downloading Gaffiot");
        mutableData = [NSMutableData new];
        NSURL *url = [NSURL URLWithString:@"http://ilgl.eu/gaffiot.zip"];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:100000.0];
        download = [NSURLConnection connectionWithRequest:request delegate:self];
        [download start];
    }
}

#pragma mark - URLConnection delegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    [mutableData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
    [mutableData appendData:data];
    NSNumber *progress = [NSNumber numberWithDouble:mutableData.length / 136280440.0];
    [progressView setProgress:progress.doubleValue animated:YES];
    
    if (!formatter) {
        
        formatter = [NSNumberFormatter new];
        formatter.numberStyle = NSNumberFormatterPercentStyle;
        formatter.minimumFractionDigits = 6;
        formatter.maximumFractionDigits = 6;
    }
    
    progressLabel.text = progress.doubleValue == 1.0 ? @"100 %" : [formatter stringFromNumber:progress];
    
    sizeLabel.text = [NSString stringWithFormat:@"%d / 136 Mb", (int)(mutableData.length / 1000000)];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    NSLog(@"Gaffiot downloaded");
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documents = paths[0];
    NSString *file = [NSString stringWithFormat:@"%@/%@", paths[0], @"gaffiot.zip"];
    
    [UIView animateWithDuration:0.4 animations:^{
        
        progressLabel.alpha = 0.0;
        progressView.alpha = 0.0;
        sizeLabel.alpha = 0.0;
    
    } completion:^(BOOL finished){
        
        [indicator startAnimating];
        [UIView animateWithDuration:0.4 animations:^{
            
            indicator.alpha = 1.0;
        }];
    }];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        [mutableData writeToFile:file atomically:YES];
        [Main unzipFileAtPath:file toDestination:documents];
        [[NSFileManager defaultManager] removeItemAtPath:file error:nil];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSLog(@"Gaffiot archived");
            fileExists = YES;
            
            [UIView animateWithDuration:0.4 animations:^{
                
                indicator.alpha = 0;
            
            } completion:^(BOOL finished){
                
                [indicator stopAnimating];
                NSString *path = [NSString stringWithFormat:@"%@/Gaffiot/glossary.txt", documents];
                NSString *string = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
                words = [string componentsSeparatedByString:@"\n"];
                
                [self load];
            }];
        });
    });
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    
    NSLog(@"%@",error.localizedDescription);
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"error", nil) message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alertView show];
}

@end