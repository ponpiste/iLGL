//
//  Ranking.m
//  iLGL
//
//  Created by Sacha Bartholmé on 1/8/16.
//  Copyright © 2016 The iLGL Team. All rights reserved.
//

#import "Ranking.h"

@implementation Ranking

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (_highscores.count > 0)
        if ([self string:_highscores[0][@"name"] containsString:_name])
            [self present];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self download];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [highscoresConnection cancel];
}

- (BOOL)string:(NSString *)string containsString:(NSString *)substring {
    
    return [string rangeOfString:substring].length > 1;
}

- (void)present {
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"present.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(showPresent)];
    self.navigationItem.rightBarButtonItem = item;
}

- (void)showPresent {
    
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"🏆 Felicitatioun 🏆" message:@"Hei sinn puer geheim Informatiounen ze der App (et ginn der nach vill méi) :\n\n1. Dier kënnt Notte méi schnell aginn wann Dier laang op d'Nimm vun de Fächer gedréckt haalt.\n\n2. Wann Dier e Witz schreift an Dier wëllt d'Fënster zouman ouni op \"Fertig\" ze drécken, schreift einfach \"lol\" (grouss oder kleng, mir ass et egal).\n\n3. Wann Dier laang bei de Notten um Bonus Knäppchen gedréckt haalt, kritt Dier e Bonus vu 9 bis 10 Dausend.\n\nSot et kengem weider." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alertView show];
}

- (IBAction)info {
    
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:_name message:NSLocalizedString(@"surprise", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alertView show];
}

- (IBAction)refresh {
    [self download];
}

- (void)download {
    
    [highscoresConnection cancel];
    NSLog(@"Downloading high scores");
    NSURL *url = [NSURL URLWithString:@"http://ilgl.eu/button.php"];
    mutableData = [NSMutableData new];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10.0];
    highscoresConnection = [NSURLConnection connectionWithRequest:request delegate:self];
    [highscoresConnection start];
}

- (NSString *)highscoreToString:(NSInteger)highscore { // high score in seconds
    
    if (highscore < 1) return [NSString stringWithFormat:@"0 %@",NSLocalizedString(@"seconds", nil)];
    
    NSMutableString *result = [NSMutableString new];
    NSString *secondString,*minuteString,*hourString,*dayString;
    NSInteger total = highscore;
    
    if (total < 60 * 60 * 24) dayString = @"";
    else {
        
        NSInteger days = (NSInteger)(total / (60 * 60 * 24));
        total -= days * 60 * 60 * 24;
        dayString = [NSString stringWithFormat:@"%d %@",days,NSLocalizedString(days == 1 ? @"day" : @"days", nil)];
        [result appendString:dayString];
    }
    
    if (total < 60 * 60) hourString = @"";
    else {
        
        if (![result isEqualToString:@""]) [result appendString:@" "];
        
        NSInteger hours = (NSInteger)(total / (60 * 60));
        total -= hours * 60 * 60;
        hourString = [NSString stringWithFormat:@"%d %@",hours,NSLocalizedString(hours == 1 ? @"hour" : @"hours", nil)];
        [result appendString:hourString];
    }
    
    if (total >= 60) {
        
        if (![result isEqualToString:@""]) [result appendString:@" "];
        
        NSInteger minutes = (NSInteger)(total / 60);
        total -= minutes * 60;
        minuteString = [NSString stringWithFormat:@"%d %@",minutes,NSLocalizedString(minutes == 1 ? @"minute" : @"minutes", nil)];
        [result appendString:minuteString];
    }
    
    if (total >= 1 && [dayString isEqualToString:@""] && [hourString isEqualToString:@""]) {
        
        if (![result isEqualToString:@""]) [result appendString:@" "];
        
        NSInteger seconds = total;
        secondString = [NSString stringWithFormat:@"%d %@",seconds,NSLocalizedString(seconds == 1 ? @"second" : @"seconds", nil)];
        [result appendString:secondString];
    }
    
    return result;
}

#pragma mark - Table view delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _highscores.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.textLabel.text = _highscores[indexPath.row][@"name"];
    cell.detailTextLabel.text = [self highscoreToString:[_highscores[indexPath.row][@"highscore"]integerValue]];
    return cell;
}

#pragma mark - URLConnection delegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    [mutableData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [mutableData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    NSArray *temp = _highscores;
    _highscores = [NSJSONSerialization JSONObjectWithData:mutableData options:NSJSONReadingAllowFragments error:nil];
    
    if ([self string:_highscores[0][@"name"] containsString:_name])
        [self present];
    
    if (![temp isEqualToArray:_highscores]) {
        
    
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
        [_delegate didDownloadHighscores:_highscores];
        
    }
    
    [self.refreshControl endRefreshing];
    NSLog(@"High scores downloaded");
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    
    if (!_highscores || self.refreshControl.isRefreshing) {
        
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"error", nil) message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
    }
    
    NSLog(@"%@",error.localizedDescription);
    [self.refreshControl endRefreshing];
}

@end
