//
//  AppDelegate.m
//  iLGL
//
//  Created by The iLGL Team on 09/05/13.
//  Copyright (c) 2013 The iLGL Team. All rights reserved.
//

#import "AppDelegate.h"
#import "Button.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    [[UINavigationBar appearance]setBackgroundImage:[UIImage imageNamed:@"red.png"] forBarMetrics:UIBarMetricsDefault];
    
    [self advertisement];
    //[self push];
    
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]){
        
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeSound|UIUserNotificationTypeBadge categories:nil]];
    }
    
    return YES;
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    
    NSLog(@"Notification received");
    
    UIApplicationState state = [application applicationState];
    if (state == UIApplicationStateActive) {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"notification", nil) message:notification.alertBody delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
}

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    NSLog(@"Downloading news");
    NSURL *url = [NSURL URLWithString:@"http://aizide.lgl.lu/lgl.lu/index.php"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30.0];
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
    
    if (error) {NSLog(@"%@",error.localizedDescription);}
    else {
        
        NSLog(@"News downloaded");
        
        TFHpple *parser = [TFHpple hppleWithHTMLData:data];
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
        NSString *archivedTitle = [userDefaults objectForKey:@"lastTitle"];
        
        if (![lastTitle isEqualToString:archivedTitle]) {
            
            NSLog(@"There is a new item");
            
            [userDefaults setObject:lastTitle forKey:@"lastTitle"];
            
            UILocalNotification *notification = [UILocalNotification new];
            
            notification.fireDate = [NSDate date];
            notification.alertBody = lastTitle;
            notification.soundName = UILocalNotificationDefaultSoundName;
            notification.applicationIconBadgeNumber=1;
            [[UIApplication sharedApplication] scheduleLocalNotification:notification];
            
            NSMutableString *htmlString = [NSMutableString stringWithString:@"<html><head><link rel=\"stylesheet\" href=\"news.css\"/><meta name=\"viewport\" content=\"width=device-width; initial-scale=1.0; maximum-scale=1.0; user-scalable=1;\"/></head><body>"];
            
            [htmlString appendString:[[column[0]raw] componentsSeparatedByString:@"<img src=\"images/ribbonRetro2.png\""][0]];
            [htmlString replaceOccurrencesOfString:@"style=" withString:@"styl=" options:0 range:NSMakeRange(0, htmlString.length)];
            [htmlString replaceOccurrencesOfString:@"alt=\"\"" withString:[NSString stringWithFormat:@"alt=\"%@\"",NSLocalizedString(@"no internet", nil)] options:0 range:NSMakeRange(0, htmlString.length)];
            [htmlString replaceOccurrencesOfString:@"src=\"" withString:@"src=\"http://aizide.lgl.lu/lgl.lu/" options:0 range:NSMakeRange(0, htmlString.length)];
            [htmlString replaceOccurrencesOfString:@"<a href=\"" withString:@"<a href=\"http://aizide.lgl.lu/lgl.lu/" options:0 range:NSMakeRange(0, htmlString.length)];
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
            
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *path = [NSString stringWithFormat:@"%@/news.html", paths[0]];
            [htmlString writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
            NSLog(@"New HTML string archieved");
            
        } else NSLog(@"Nihil novis sub sole");
    }
    
    completionHandler(UIBackgroundFetchResultNewData);
    NSLog(@"Fetch completed");
}

#pragma mark

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (alertView.tag == 2) {
        
        MFMailComposeViewController *mc = [MFMailComposeViewController new];
        mc.mailComposeDelegate = self;
        [mc setSubject:@"iLGL - Candidature"];
        
        NSArray *messages = @[@"Moien,\nech sinn interesseiert fir den projet ze iwwerhuelen. Kompetenzen hunn ech genau dei di ee brauch, nämlech guer keng.",@"Moien ech wollt mech umellen fir d'app d'nächst joer ze iwwerhuelen",@"Ech sin dobai",@"Moien,\nech si ganz interesséiert",@"Moien et wier deck cool wann ech dat keint man. merci",@"Ech mellen mech dann halt mol.",@"Loost mech dat weg man", @"Halooooo",@"Ech si Kandidat",@"Wann een neicht spezielles wesse muss dann OK.",@"",@"",@"",@""];
        
        NSInteger index = arc4random() % messages.count;
        NSLog(@"%d",index);
        
        [mc setMessageBody:messages[index] isHTML:NO];
        [mc setToRecipients:@[@"the.ilgl.team@gmail.com"]];
        [self.window.rootViewController presentViewController:mc animated:YES completion:nil];
        
    } else {
        
        NSString *string;
        if (alertView.tag == 0) string = @"fb://profile/1411084939108681";
        else string = @"itms-apps://itunes.apple.com/app/id703135472";
        NSURL *url = [NSURL URLWithString:string];
        [[UIApplication sharedApplication]openURL:url];
    }
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [[NSNotificationCenter defaultCenter]postNotificationName:@"invalidateTimer" object:nil];
    NSLog(@"App entered background");
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"scheduleTimer" object:nil];
    NSLog(@"App entered foreground");
}

- (void)advertisement {
    
    /*NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSInteger launches = [userDefaults integerForKey:@"launches"];
    NSURL *url = [NSURL URLWithString:@"fb://profile/1411084939108681"];
    
    if (launches % 40 == 10) {
        
        BOOL canOpen = [[UIApplication sharedApplication]canOpenURL:url];
        
        if (canOpen) {
            
            NSString *title = @"Facebook";
            
            if ([[[userDefaults dictionaryRepresentation]allKeys] containsObject:@"firstName"]) {
                
                NSString *firstName = [[userDefaults objectForKey:@"firstName"]componentsSeparatedByString:@" "][0];
                title = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"hello", nil),firstName];
            }
            
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:title message:NSLocalizedString(@"facebook", nil) delegate:self cancelButtonTitle:@"Like" otherButtonTitles:nil, nil];
            alertView.tag = 0;
            [alertView show];
        }
        
    } else if (launches % 40 == 30) {
        
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"App Store" message:NSLocalizedString(@"rate", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        alertView.tag = 1;
        [alertView show];
        
    } else if (launches % 10 == 3) {
        
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"recruit title", nil) message:NSLocalizedString(@"recruit message", nil) delegate:self cancelButtonTitle:@"Email" otherButtonTitles:nil, nil];
        alertView.tag = 2;
        [alertView show];
    }
    
    launches ++;
    [[NSUserDefaults standardUserDefaults]setInteger:launches forKey:@"launches"];*/
}

#pragma mark - Push Notifications

- (void)push {
    
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1) {
        
        UIUserNotificationType types = UIUserNotificationTypeSound | UIUserNotificationTypeBadge | UIUserNotificationTypeAlert;
        UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
        
    } else {
        
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    }
}

#ifdef __IPHONE_8_0

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    [application registerForRemoteNotifications];
}

#endif
/*
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:@"<>"];
    NSString *token = [deviceToken.description stringByTrimmingCharactersInSet:set];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (![[[userDefaults dictionaryRepresentation]allKeys] containsObject:@"token"]) {
        
        NSLog(@"token: %@", token);
        [userDefaults setObject:token forKey:@"token"];
        [self uploadToken:token];
    }
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    
    NSLog(@"%@", error.localizedDescription);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    NSLog(@"%@", userInfo);
}
*/
- (void)uploadToken:(NSString *)token {
    
    NSLog(@"Uploading token");
    mutableData = [NSMutableData new];
    NSURL *url = [NSURL URLWithString:@"http://ilgl.eu/token.php"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10.0];
    NSData *data = [token dataUsingEncoding:NSUTF8StringEncoding];
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
    
    NSLog(@"Token uploaded");
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:YES forKey:@"tokenUploaded"];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    
    NSLog(@"%@",error.localizedDescription);
}

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    
    return _restrictRotation ? UIInterfaceOrientationMaskPortrait : UIInterfaceOrientationMaskAll;
}

@end
