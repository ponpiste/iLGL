//
//  News.m
//  Contern
//
//  Created by Sacha Bartholmé on 5/29/16.
//  Copyright © 2016 Sacha Bartholmé. All rights reserved.
//

#import "News.h"

@implementation News

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem.target = self.revealViewController;
    self.navigationItem.leftBarButtonItem.action = @selector(revealToggle:);
    
    mutableData = [NSMutableData new];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [NSString stringWithFormat:@"%@/news.html", paths[0]];
    
    htmlString = [NSMutableString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    fileExists = htmlString.length > 0;
    
    [activityIndicator startAnimating];
    newsWebView.alpha = 0;
    
    if (fileExists) {
        
        [newsWebView loadHTMLString:htmlString baseURL:[[NSBundle mainBundle]bundleURL]];
        offlineContent = YES;
        NSLog(@"Loading offline content");
        
    } else [self download];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults boolForKey:@"isWritingJoke"])
        [self performSegueWithIdentifier:@"segue" sender:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [jokeConnection cancel];
}

- (void)archive {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [NSString stringWithFormat:@"%@/news.html", paths[0]];
    [htmlString writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

- (void)download {
    
    NSLog(@"Downloading news");
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSURL *url = [NSURL URLWithString:[@"http://aizide.lgl.lu/lgl.lu/index.php" stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:20.0];
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
    [connection start];
}

- (IBAction)joke {
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSDateComponents *components1 = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[userDefaults objectForKey:@"joke_date"] ? [userDefaults objectForKey:@"joke_date"] : [NSDate dateWithTimeIntervalSinceNow:- 24 * 60 * 60]];
    
    NSDateComponents *components2 = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
    
    if (components1.day == components2.day && components1.month == components2.month && components1.year == components2.year) {
        
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"daily joke", nil) message:[userDefaults objectForKey:@"joke_text"] delegate:self cancelButtonTitle:NSLocalizedString(@"excellent", nil) otherButtonTitles:NSLocalizedString(@"write", nil), nil];
        [alertView show];
        
    } else {
        
        //[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        self.navigationItem.rightBarButtonItem.enabled = NO;
        NSLog(@"Downloading joke");
        NSURL *url = [NSURL URLWithString:@"http://ilgl.eu/joke.php"];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10.0];
        jokeConnection = [NSURLConnection connectionWithRequest:request delegate:self];
        [jokeConnection start];
        
        jokeButton = YES;
    }
}

#pragma mark - URLConnection delegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    
    mime = [response MIMEType];
    [mutableData setLength:0];
}

- (BOOL)isDisplayingPDF {
    
    NSString *extension = [[mime substringFromIndex:([mime length] - 3)] lowercaseString];
    
    return ([[[newsWebView.request.URL pathExtension] lowercaseString] isEqualToString:@"pdf"] || [extension isEqualToString:@"pdf"]);
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [mutableData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    if (connection == jokeConnection) {
        
        NSLog(@"Joke downloaded");
        self.navigationItem.rightBarButtonItem.enabled = YES;
        NSString *joke = [[NSString alloc]initWithData:mutableData encoding:NSUTF8StringEncoding];
        
        NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
        
        if ([joke hasPrefix:@"<"] || [joke stringByTrimmingCharactersInSet:set].length == 0) {
            
            // Blague de secours
            joke = @"Jesus said to Petrus: come forth and you'll get eternal life. But Petrus came fifth and won a toaster.";
        }
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:joke forKey:@"joke_text"];
        [userDefaults setObject:[NSDate date] forKey:@"joke_date"];
        [userDefaults synchronize];
        
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"daily joke", nil) message:joke delegate:self cancelButtonTitle:NSLocalizedString(@"excellent", nil) otherButtonTitles:NSLocalizedString(@"write", nil), nil];
        [alertView show];
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
    } else {
        
        NSLog(@"News downloaded");
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        htmlString = [NSMutableString stringWithString:@"<html><head><link rel=\"stylesheet\" href=\"news.css\"/><meta name=\"viewport\" content=\"width=device-width; initial-scale=1.0; maximum-scale=1.0; user-scalable=1;\"/><meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\"/></head><body>"];
        
        TFHpple *parser = [TFHpple hppleWithHTMLData:mutableData];
        
        NSString *XPath = @"//div[@id='colonne1']//div[@id='content']";
        NSArray *column = [parser searchWithXPathQuery:XPath];
        
        NSMutableString *lastTitle = [NSMutableString stringWithString:[[column[0]searchWithXPathQuery:@"//h1"][0]content]];
        
        [lastTitle replaceOccurrencesOfString:@"â" withString:@"'" options:0 range:NSMakeRange(0, lastTitle.length)];
        [lastTitle replaceOccurrencesOfString:@"â¬" withString:@"€" options:0 range:NSMakeRange(0, lastTitle.length)];
        [lastTitle replaceOccurrencesOfString:@"Â°" withString:@"°" options:0 range:NSMakeRange(0, lastTitle.length)];
        [lastTitle replaceOccurrencesOfString:@"Ã»" withString:@"û" options:0 range:NSMakeRange(0, lastTitle.length)];
        [lastTitle replaceOccurrencesOfString:@"Ã¼" withString:@"ü" options:0 range:NSMakeRange(0, lastTitle.length)];
        [lastTitle replaceOccurrencesOfString:@"Ã§" withString:@"ç" options:0 range:NSMakeRange(0, lastTitle.length)];
        [lastTitle replaceOccurrencesOfString:@"Ã´" withString:@"ô" options:0 range:NSMakeRange(0, lastTitle.length)];
        [lastTitle replaceOccurrencesOfString:@"Ã¶" withString:@"ö" options:0 range:NSMakeRange(0, lastTitle.length)];
        [lastTitle replaceOccurrencesOfString:@"Ã¹" withString:@"ù" options:0 range:NSMakeRange(0, lastTitle.length)];
        [lastTitle replaceOccurrencesOfString:@"Ã¯" withString:@"ï" options:0 range:NSMakeRange(0, lastTitle.length)];
        [lastTitle replaceOccurrencesOfString:@"Ã®" withString:@"î" options:0 range:NSMakeRange(0, lastTitle.length)];
        [lastTitle replaceOccurrencesOfString:@"Ã«" withString:@"ë" options:0 range:NSMakeRange(0, lastTitle.length)];
        [lastTitle replaceOccurrencesOfString:@"Ã¨" withString:@"è" options:0 range:NSMakeRange(0, lastTitle.length)];
        [lastTitle replaceOccurrencesOfString:@"Ã©" withString:@"é" options:0 range:NSMakeRange(0, lastTitle.length)];
        [lastTitle replaceOccurrencesOfString:@"Ã¢" withString:@"â" options:0 range:NSMakeRange(0, lastTitle.length)];
        [lastTitle replaceOccurrencesOfString:@"Ãª" withString:@"ê" options:0 range:NSMakeRange(0, lastTitle.length)];
        [lastTitle replaceOccurrencesOfString:@"Ã" withString:@"à" options:0 range:NSMakeRange(0, lastTitle.length)];
        [lastTitle replaceOccurrencesOfString:@"Å" withString:@"œ" options:0 range:NSMakeRange(0, lastTitle.length)];
        [lastTitle replaceOccurrencesOfString:@"Å" withString:@"œ" options:0 range:NSMakeRange(0, lastTitle.length)];
        [lastTitle replaceOccurrencesOfString:@"Â" withString:@"" options:0 range:NSMakeRange(0, lastTitle.length)];
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:lastTitle forKey:@"lastTitle"];
        
        [htmlString appendString:[[column[0]raw] componentsSeparatedByString:@"<img src=\"images/ribbonRetro2.png\""][0]];
        [htmlString replaceOccurrencesOfString:@"style=" withString:@"styl=" options:0 range:NSMakeRange(0, htmlString.length)];
        [htmlString replaceOccurrencesOfString:@"alt=\"\"" withString:[NSString stringWithFormat:@"alt=\"%@\"",NSLocalizedString(@"no internet", nil)] options:0 range:NSMakeRange(0, htmlString.length)];
        [htmlString replaceOccurrencesOfString:@"src=\"images" withString:@"src=\"http://aizide.lgl.lu/lgl.lu/images" options:0 range:NSMakeRange(0, htmlString.length)];
        [htmlString replaceOccurrencesOfString:@"<a href=\"images" withString:@"<a href=\"http://aizide.lgl.lu/lgl.lu/images" options:0 range:NSMakeRange(0, htmlString.length)];
        [htmlString replaceOccurrencesOfString:@"<a href=\"pdf" withString:@"<a href=\"http://aizide.lgl.lu/lgl.lu/pdf" options:0 range:NSMakeRange(0, htmlString.length)];
        [htmlString replaceOccurrencesOfString:@"&amp;nbsp" withString:@" " options:0 range:NSMakeRange(0, htmlString.length)];
        
        [htmlString replaceOccurrencesOfString:@"â" withString:@"'" options:0 range:NSMakeRange(0, htmlString.length)];
        [htmlString replaceOccurrencesOfString:@"â¬" withString:@"€" options:0 range:NSMakeRange(0, htmlString.length)];
        [htmlString replaceOccurrencesOfString:@"Â°" withString:@"°" options:0 range:NSMakeRange(0, htmlString.length)];
        [htmlString replaceOccurrencesOfString:@"Ã»" withString:@"û" options:0 range:NSMakeRange(0, htmlString.length)];
        [htmlString replaceOccurrencesOfString:@"Ã¼" withString:@"ü" options:0 range:NSMakeRange(0, htmlString.length)];
        [htmlString replaceOccurrencesOfString:@"Ã§" withString:@"ç" options:0 range:NSMakeRange(0, htmlString.length)];
        [htmlString replaceOccurrencesOfString:@"Ã´" withString:@"ô" options:0 range:NSMakeRange(0, htmlString.length)];
        [htmlString replaceOccurrencesOfString:@"Ã¶" withString:@"ö" options:0 range:NSMakeRange(0, htmlString.length)];
        [htmlString replaceOccurrencesOfString:@"Ã¹" withString:@"ù" options:0 range:NSMakeRange(0, htmlString.length)];
        [htmlString replaceOccurrencesOfString:@"Ã¯" withString:@"ï" options:0 range:NSMakeRange(0, htmlString.length)];
        [htmlString replaceOccurrencesOfString:@"Ã®" withString:@"î" options:0 range:NSMakeRange(0, htmlString.length)];
        [htmlString replaceOccurrencesOfString:@"Ã«" withString:@"ë" options:0 range:NSMakeRange(0, htmlString.length)];
        [htmlString replaceOccurrencesOfString:@"Ã¨" withString:@"è" options:0 range:NSMakeRange(0, htmlString.length)];
        [htmlString replaceOccurrencesOfString:@"Ã©" withString:@"é" options:0 range:NSMakeRange(0, htmlString.length)];
        [htmlString replaceOccurrencesOfString:@"Ã¢" withString:@"â" options:0 range:NSMakeRange(0, htmlString.length)];
        [htmlString replaceOccurrencesOfString:@"Ãª" withString:@"ê" options:0 range:NSMakeRange(0, htmlString.length)];
        [htmlString replaceOccurrencesOfString:@"Ã" withString:@"à" options:0 range:NSMakeRange(0, htmlString.length)];
        [htmlString replaceOccurrencesOfString:@"Å" withString:@"œ" options:0 range:NSMakeRange(0, htmlString.length)];
        [htmlString replaceOccurrencesOfString:@"Å" withString:@"œ" options:0 range:NSMakeRange(0, htmlString.length)];
        [htmlString replaceOccurrencesOfString:@"Â" withString:@"" options:0 range:NSMakeRange(0, htmlString.length)];
        
        fileExists = htmlString.length > 0;
        [newsWebView loadHTMLString:htmlString baseURL:[[NSBundle mainBundle]bundleURL]];
        [self archive];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    
    NSLog(@"%@",error.localizedDescription);
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    if (!fileExists) {
        
        NSMutableString *errorString = [NSMutableString new];
        
        [errorString appendString:@"<html><head><link rel=\"stylesheet\" href=\"news.css\"/><meta name=\"viewport\" content=\"width=device-width; initial-scale=1.0; maximum-scale=1.0;\"></head><body>"];
        
        [errorString appendString:[NSString stringWithFormat:@"<div class=\"area\"><div class=\"bubble\"><p>%@</p></div></div>", error.localizedDescription]];
        
        [errorString appendString:@"</body></html>"];
        
        [newsWebView loadHTMLString:errorString baseURL:[[NSBundle mainBundle]bundleURL]];
        
    } else if (didRefresh) {
        
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"error", nil) message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
        
        didRefresh = NO;
    }
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    
    [UIView animateWithDuration:0.7 animations:^{
        newsWebView.alpha = 1.0;
    }];
    [activityIndicator stopAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
    NSLog(@"Web view finished loading");
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    if (offlineContent) {
        
        offlineContent = NO;
        [self download];
    }
    
    if ([self isDisplayingPDF]) {
        
        //UIBarButtonItem *share = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(share)];
        //self.navigationItem.rightBarButtonItem = share;
        
    } //else self.navigationItem.rightBarButtonItem = nil;
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    return YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    
    if (webView.isLoading) return;
    NSLog(@"%@",error.localizedDescription);
    
    [UIView animateWithDuration:0.7 animations:^{
        newsWebView.alpha = 1.0;
    }];
    [activityIndicator stopAnimating];
}

- (void)share { // à faire...
    
    NSArray *activityItems = @[mutableData];
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    [self presentViewController:activityVC animated:YES completion:nil];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 1) {
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setBool:YES forKey:@"isWritingJoke"];
        [userDefaults synchronize];
        
        [self performSegueWithIdentifier:@"segue" sender:nil];
    }
}


@end
