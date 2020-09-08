//
//  Button.m
//  iLGL
//
//  Created by Sacha Bartholmé on 1/7/16.
//  Copyright © 2016 The iLGL Team. All rights reserved.
//

#import "Button.h"
#import "SWRevealViewController.h"
#import "AppDelegate.h"

@implementation Button

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem.target = self.revealViewController;
    self.navigationItem.leftBarButtonItem.action = @selector(revealToggle:);
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSNumber *number = [userDefaults objectForKey:@"highscore"];
    highscore = number.integerValue * 100;
    highscoreLabel.text = [self highscoreToString];
    
    mutableData = [NSMutableData new];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    appDelegate.restrictRotation = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
        
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    appDelegate.restrictRotation = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    name = [userDefaults objectForKey:@"firstName"];
    
    self.navigationItem.rightBarButtonItem.enabled = name.length > 0;
    [self uploadHighscore];
}

- (void)didDownloadHighscores:(NSArray *)newHighscores {
    highscores = newHighscores;
}

- (void)downloadHighscores {
    
    NSLog(@"Downloading high scores");
    NSURL *url = [NSURL URLWithString:@"http://ilgl.eu/button.php"];
    mutableData = [NSMutableData new];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:5.0];
    download = [NSURLConnection connectionWithRequest:request delegate:self];
    [download start];
}

- (void)increment {
    
    centiseconds += 2; // 2
    timeLabel.text = [self centisecondsToString];
    
    if ((centiseconds - 1) % 100 == 0) [self updateHighscore];
}
- (IBAction)touchDown {
    
    centiseconds = 1; // 1
    timeLabel.text = @"00:00,01";
    [self updateHighscore];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(increment) userInfo:nil repeats:YES];
}

- (IBAction)touchUpInside {
    
    [timer invalidate];
    [self uploadHighscore];
}

- (IBAction)touchCancel {
    
    [timer invalidate];
    [self uploadHighscore];
}

- (IBAction)touchDragExit {
    
    [timer invalidate];
    [self uploadHighscore];
}

- (IBAction)touchDragOutside {
    
    [timer invalidate];
    [self uploadHighscore];
}

- (NSString *)centisecondsToString {
    
    NSInteger total = centiseconds;
    NSInteger seconds,minutes,hours,days;
    
    if (total >= 100 * 60 * 60) {
        
        days = (NSInteger)(total / (100 * 60 * 60 * 24));
        total -= days * 100 * 60 * 60 * 24;
        
        hours = (NSInteger)(total / (100 * 60 * 60));
        total -= hours * 100 * 60 * 60;
        
    } else {
        
        days = 0;
        hours = 0;
    }
    
    minutes = (NSInteger)(total / (100 * 60));
    total -= minutes * 100 * 60;
    
    seconds = (NSInteger)(total / 100);
    total -= seconds * 100;
    
    NSString *string;
    
    if (days != 0)
        string = [NSString stringWithFormat:@"%02d:%02d:%02d:%02d",days,hours,minutes,seconds];
    else if (hours != 0)
        string = [NSString stringWithFormat:@"%02d:%02d:%02d",hours,minutes,seconds];
    else
        string = [NSString stringWithFormat:@"%02d:%02d,%02d",minutes,seconds,total];
    
    return string;
}

- (NSString *)highscoreToString { // high score in centiseconds
    
    if (highscore < 100) return [NSString stringWithFormat:@"0 %@",NSLocalizedString(@"seconds", nil)];
    
    NSMutableString *result = [NSMutableString new];
    NSString *secondString,*minuteString,*hourString,*dayString;
    NSInteger total = highscore;
    
    if (total >= 100 * 60 * 60 * 24) {
        
        NSInteger days = (NSInteger)(total / (100 * 60 * 60 * 24));
        total -= days * 100 * 60 * 60 * 24;
        dayString = [NSString stringWithFormat:@"%d %@",days,NSLocalizedString(days == 1 ? @"day" : @"days", nil)];
        [result appendString:dayString];
    }
    
    if (total >= 100 * 60 * 60) {
        
        if (![result isEqualToString:@""]) [result appendString:@" "];
        
        NSInteger hours = (NSInteger)(total / (100 * 60 * 60));
        total -= hours * 100 * 60 * 60;
        hourString = [NSString stringWithFormat:@"%d %@",hours,NSLocalizedString(hours == 1 ? @"hour" : @"hours", nil)];
        [result appendString:hourString];
    }
    
    if (total >= 100 * 60) {
        
        if (![result isEqualToString:@""]) [result appendString:@" "];
        
        NSInteger minutes = (NSInteger)(total / (100 * 60));
        total -= minutes * 100 * 60;
        minuteString = [NSString stringWithFormat:@"%d %@",minutes,NSLocalizedString(minutes == 1 ? @"minute" : @"minutes", nil)];
        [result appendString:minuteString];
    }
    
    if (total >= 100) {
        
        if (![result isEqualToString:@""]) [result appendString:@" "];
        
        NSInteger seconds = (NSInteger)(total / 100);
        secondString = [NSString stringWithFormat:@"%d %@",seconds,NSLocalizedString(seconds == 1 ? @"second" : @"seconds", nil)];
        [result appendString:secondString];
    }
    
    return result;
}

- (void)updateHighscore {
    
    if (centiseconds > highscore && centiseconds <= NSIntegerMax) {
        
        highscore = centiseconds;
        highscoreLabel.text = [self highscoreToString];
        
        NSInteger seconds = (NSInteger)(highscore / 100);
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSNumber *number = [NSNumber numberWithInteger:seconds];
        [userDefaults setObject:number forKey:@"highscore"];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    [download cancel];
    
    Ranking *ranking = segue.destinationViewController;
    ranking.highscores = highscores;
    ranking.name = name;
    ranking.delegate = self;
}

- (void)uploadHighscore {
    
    if (!name) return;
    
    NSInteger seconds = (NSInteger)(highscore / 100);
    NSString *score = [NSString stringWithFormat:@"%d",seconds];
    
    NSLog(@"Uploading high score");
    NSString *urlString = [NSString stringWithFormat:@"http://ilgl.eu/button.php?highscore=%@&name=%@&password=P7?-Jz55?c-uU8xH/f21]b", score, name];
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:5.0];
    
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
    
    if (connection == download) {
        
        highscores = [NSJSONSerialization JSONObjectWithData:mutableData options:NSJSONReadingAllowFragments error:nil];
        NSLog(@"High scores downloaded");
        
    } else {
        
        NSLog(@"%@",[[NSString alloc]initWithData:mutableData encoding:NSUTF8StringEncoding]);
        [self downloadHighscores];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    NSLog(@"%@",error.localizedDescription);
}

@end
