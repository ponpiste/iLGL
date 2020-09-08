//
//  Restopolis.m
//  iLGL
//
//  Created by The iLGL Team on 21/05/13.
//  Copyright (c) 2013 The iLGL Team. All rights reserved.
//

#import "Restopolis.h"
#import "SWRevealViewController.h"

@implementation Restopolis

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.leftBarButtonItem.target = self.revealViewController;
    self.navigationItem.leftBarButtonItem.action = @selector(revealToggle:);
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [segmentedControl setSelectedSegmentIndex:[userDefaults integerForKey:@"restopolis"]] ;
    
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Light" size:21.0];
    NSDictionary *attributes = @{NSFontAttributeName: font};
    [segmentedControl setTitleTextAttributes:attributes forState:UIControlStateNormal];
    
    newDate = [self exitWeekend];
    date = newDate;
        
    UIButton *rewind = self.view.subviews[1];
    [restopolisWebView.scrollView addSubview:rewind];
    
    UIButton *forward = self.view.subviews[1];
    [restopolisWebView.scrollView addSubview:forward];
    [self.view.subviews[1] removeFromSuperview];
    
    restopolisWebView.scrollView.delegate = self;
	[self download];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    [self.view addGestureRecognizer:self.revealViewController.tapGestureRecognizer];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (![[[userDefaults dictionaryRepresentation]allKeys] containsObject:@"restopolis_info"]) {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"information", nil) message:NSLocalizedString(@"touch menus", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
        
        [userDefaults setBool:YES forKey:@"restopolis_info"];
        [userDefaults synchronize];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [menusConnection cancel];
}

- (IBAction)tripleTap {
    
    //newDate = [NSDate date];
    //[self download];
}

- (IBAction)rightSwipe {
    //[self rewind];
}

- (IBAction)leftSwipe {
    //[self forward];
}

- (IBAction)leftButton {
    [self rewind];
}

- (IBAction)rightButton {
    [self forward];
}

- (NSString *)HTMLStringWithError:(NSError*)error {
    
    UIImage *pictures = [UIImage imageNamed:@"pictures.png"];
    self.navigationItem.rightBarButtonItem.image = pictures;
    
    NSMutableString *HTMLString = [NSMutableString new];
    
    [HTMLString appendString:@"<html><head><link rel=\"stylesheet\" href=\"restopolis.css\"/><meta name=\"viewport\" content=\"width=device-width; initial-scale=1.0; maximum-scale=1.0;\"></head><body><header>"];
    
    NSDateFormatter *formatter = [NSDateFormatter new];
    NSString *dateFormat = [NSDateFormatter dateFormatFromTemplate:@"EEEEdMMM" options:0 locale:[NSLocale currentLocale]];
    formatter.dateFormat = dateFormat;
    
    [HTMLString appendString:[formatter stringFromDate:date]];
    [HTMLString appendFormat:@"</header>"];
    
    NSArray *array = segmentedControl.selectedSegmentIndex == 0 ? cafeteria : cantine;
    
    if (error) {
        
        [HTMLString appendString:[NSString stringWithFormat:@"<div class=\"area\"><div class=\"bubble\"><p>%@</p></div></div>", error.localizedDescription]];
        }
    else if (array.count == 0) {
        
        [HTMLString appendString:[NSString stringWithFormat:@"<div class=\"area\"><div class=\"bubble\"><p>%@</p></div></div>", NSLocalizedString(@"no menu", nil)]];
        
    } else {
        
        [HTMLString appendString:@"<p>"];
        for (NSMutableDictionary *dictionary in array) {
            
            [HTMLString appendString:[NSString stringWithFormat:@"<h2>%@<h2>", NSLocalizedString(dictionary[@"name"], nil)]];
            [HTMLString appendString:@"<ul>"];
            
            for (NSString *dish in dictionary[@"menus"]) {
                
                [HTMLString appendString:[NSString stringWithFormat:@"<li><a href=\"https://www.google.com/search?q=%@&client=safari&rls=en&source=lnms&tbm=isch&sa=X&ved=0CAcQ_AUoAWoVChMIhoXvweCcxwIVQTgUCh2xFgFi&biw=1280&bih=628\">%@</a></li>", dish, dish]];
            }
            [HTMLString appendString:@"</ul>"];
        }
        [HTMLString appendString:@"</p>"];
    }
    [HTMLString appendString:@"</body></html>"];
    
    return HTMLString;
}

- (IBAction)didSelectSegment {
    
    [UIView animateWithDuration:0.1 animations:^{restopolisWebView.alpha = 0.0;}];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setInteger:segmentedControl.selectedSegmentIndex forKey:@"restopolis"];
    
    NSArray *array = segmentedControl.selectedSegmentIndex == 0 ? cafeteria : cantine;
    if (!array) {
        [self download];
    } else {
        
        NSString *path = [[NSBundle mainBundle]bundlePath];
        NSURL *baseURL = [NSURL fileURLWithPath:path];
        
        NSString *HTMLString = [self HTMLStringWithError:nil];
        [restopolisWebView loadHTMLString:HTMLString baseURL:baseURL];
    }
}

- (void)rewind {
    
    [UIView animateWithDuration:0.1 animations:^{restopolisWebView.alpha = 0.0;}];
    newDate = [date dateByAddingTimeInterval:-(24 * 60 * 60)];
    [self download];
}

- (void)forward {
    
    [UIView animateWithDuration:0.1 animations:^{restopolisWebView.alpha = 0.0;}];
    newDate = [date dateByAddingTimeInterval:24 * 60 * 60];
    [self download];
}

- (void)download {
    
    self.navigationItem.rightBarButtonItem = nil;
    
    NSDateFormatter *formatter = [NSDateFormatter new];
    formatter.dateStyle = NSDateFormatterShortStyle;
    formatter.locale = [NSLocale localeWithLocaleIdentifier:@"fr_FR"];
    
    NSLog(@"Downloading menus");
    //[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    NSString *link = [NSString stringWithFormat:@"https://webservices.erestauration.lu/Xml/Menu.aspx?RestaurantId=%i&date=%@", 50 - segmentedControl.selectedSegmentIndex, [formatter stringFromDate:newDate]];
    NSURL *url = [NSURL URLWithString:link];
    mutableData = [NSMutableData new];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10.0];
    menusConnection = [NSURLConnection connectionWithRequest:request delegate:self];
    [menusConnection start];
}

- (NSDate *)exitWeekend {
    
    NSDate *today = [NSDate date];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSInteger weekday = [[calendar components: NSWeekdayCalendarUnit fromDate: today] weekday];
    
    if (weekday == 7)
        return [today dateByAddingTimeInterval:2*24*60*60];
    if (weekday == 1)
        return [today dateByAddingTimeInterval:24*60*60];
        
    return today;
}

#pragma mark - Gesture recognizer delegate
/*
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}*/

#pragma mark -URLConnection delegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
	[mutableData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
	[mutableData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    NSDateComponents *components2 = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:date];
    
    NSDateComponents *components1 = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:newDate];
    
    if (!(components1.day == components2.day && components1.month == components2.month && components1.year == components2.year)) {
        cafeteria = nil;
        cantine = nil;
    }
    
    date = newDate;
    
    if (segmentedControl.selectedSegmentIndex == 0) {
        cafeteria = [NSMutableArray new];
    } else {
        cantine = [NSMutableArray new];
    }
    
    XMLparser = [[NSXMLParser alloc]initWithData:mutableData];
    XMLparser.delegate = self;
    [XMLparser parse];
    
    NSString *path = [[NSBundle mainBundle]bundlePath];
    NSURL *baseURL = [NSURL fileURLWithPath:path];
    
    NSString *HTMLString = [self HTMLStringWithError:nil];
    [restopolisWebView loadHTMLString:HTMLString baseURL:baseURL];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    NSLog(@"Menus downloaded");
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
    NSLog(@"%@",error.localizedDescription);
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    NSDateComponents *components2 = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:date];
    
    NSDateComponents *components1 = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:newDate];
    
    NSArray *array = segmentedControl.selectedSegmentIndex == 0 ? cafeteria : cantine;
    ;
    if (!(components1.day == components2.day && components1.month == components2.month && components1.year == components2.year) && array) {
        
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"error", nil) message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
        
        newDate = date;
        [UIView animateWithDuration:0.4 animations:^{restopolisWebView.alpha = 1.0;}];
        
    } else {
        
        NSString *path = [[NSBundle mainBundle]bundlePath];
        NSURL *baseURL = [NSURL fileURLWithPath:path];
        
        NSString *HTMLString = [self HTMLStringWithError:error];
        [restopolisWebView loadHTMLString:HTMLString baseURL:baseURL];
    }
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
    
    return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust])
    {
        [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
    }
    else
    {
        [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
    }
}

#pragma mark Web view

- (void)webViewDidStartLoad:(UIWebView *)webView {
    
    [UIView animateWithDuration:0.4 animations:^{webView.alpha = 0.0;}];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
    if ([webView.request.URL.absoluteString hasPrefix:@"https://"]) {
                
        webView.scrollView.contentOffset = CGPointMake(0, 81.5);
        
        UIImage *text = [UIImage imageNamed:@"text.png"];
        UIBarButtonItem *T = [[UIBarButtonItem alloc] initWithImage:text style:UIBarButtonItemStyleBordered target:self action:@selector(download)];
        self.navigationItem.rightBarButtonItem = T;
        
    } else {
        
        [webView stringByEvaluatingJavaScriptFromString:@"document.body.style.webkitTouchCallout='none'; document.body.style.KhtmlUserSelect='none'"];
    }
    
    [UIView animateWithDuration:0.4 animations:^{webView.alpha = 1.0;}];
}

#pragma mark - XMLParser delegate

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{
    
    NSArray *array = @[@"starter", @"maincourse", @"starchyfood", @"vegetables", @"dessert", @"takeaway"];
    
    if ([array containsObject:elementName] && [attributeDict[@"products"]integerValue] > 0) {
        
        [segmentedControl.selectedSegmentIndex == 0 ? cafeteria : cantine addObject:[NSMutableDictionary dictionaryWithObjects:@[[NSMutableArray new], elementName] forKeys:@[@"menus", @"name"]]];
    }
}

- (void)parser:(NSXMLParser *)parser foundCDATA:(NSData *)CDATABlock{
    
	currentString = [[NSMutableString alloc]initWithData:CDATABlock encoding:NSUTF8StringEncoding];
    [[(segmentedControl.selectedSegmentIndex == 0 ? cafeteria : cantine)lastObject][@"menus"]addObject:currentString];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
    
    if ([elementName isEqualToString:@"menu"]) {
        [segmentedControl.selectedSegmentIndex == 0 ? cafeteria : cantine addObject:[NSMutableDictionary dictionaryWithObjects:@[[NSMutableArray new], @"products"] forKeys:@[@"menus", @"name"]]];
    }
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
    [segmentedControl.selectedSegmentIndex == 0 ? cafeteria : cantine removeLastObject];
}

@end
