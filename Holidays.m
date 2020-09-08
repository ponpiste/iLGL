//
//  Holidays.m
//  iLGL
//
//  Created by Sacha Bartholmé on 21/10/2014.
//  Copyright (c) 2014 The iLGL Team. All rights reserved.
//

#import "Holidays.h"
#import "Countdown.h"
#import "SWRevealViewController.h"

@implementation Holidays

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem.target = self.revealViewController;
    self.navigationItem.leftBarButtonItem.action = @selector(revealToggle:);
    
    if (arc4random()%150 != 74) self.navigationItem.rightBarButtonItem = nil;
    
    NSLog(@"Downloading holidays");
    NSURL *url = [NSURL URLWithString:@"http://ilgl.eu/holidays.php"];
    mutableData = [NSMutableData new];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10.0];
    automaticConnection = [NSURLConnection connectionWithRequest:request delegate:self];
    [automaticConnection start];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(invalidateTimer) name:@"invalidateTimer" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(scheduleTimer) name:@"scheduleTimer" object:nil];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [NSString stringWithFormat:@"%@/%@", paths[0],@"holidays.json"];
    fileExists = [[NSFileManager defaultManager]fileExistsAtPath:path];
    
    numberFormatter = [NSNumberFormatter new];
    numberFormatter.maximumFractionDigits = 9;
    numberFormatter.minimumFractionDigits = 9;
    numberFormatter.minimumIntegerDigits = 1;
    
    if (fileExists) {
        
        holidays = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path] options:NSJSONReadingAllowFragments error:nil];
        [self createArrays];
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        titleIndex = [userDefaults integerForKey:@"holidays"];
        
        currentTerm = [holidays[2][@"end"] timeIntervalSinceNow] > 0 ? 0 : [holidays[4][@"end"] timeIntervalSinceNow] > 0 ? 1 : 2;
        [self didSelectTitle:nil];
        
    } else [titleButton setTitle:NSLocalizedString(@"holidays", nil) forState:UIControlStateNormal];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (titleIndex == 0) [self scheduleTimer];
    
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    [self.view addGestureRecognizer:self.revealViewController.tapGestureRecognizer];
    
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    
    [automaticConnection cancel];
    
    [self invalidateTimer];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"invalidateTimer" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"scheduleTimer" object:nil];
}

- (void)createArrays {
    
    NSMutableArray *array = [NSMutableArray new];
    
    for (NSDictionary *holiday in holidays) {
        
        NSDateFormatter *formatter = [NSDateFormatter new];
        [formatter setDateFormat:@"dd/MM/yyyy HH:mm:ss"];
        
        NSDate *date1 = [formatter dateFromString:holiday[@"start"]];
        NSDate *date2 = [formatter dateFromString:holiday[@"end"]];
        
        [array addObject:@{@"name": holiday[@"name"], @"start": date1, @"end": date2}];
        
    }
    holidays = array;
    
    sortedArray = [NSMutableArray arrayWithArray:@[[NSMutableArray new], [NSMutableArray new]]];
    for (NSDictionary *holiday in holidays) {
        [sortedArray[[holiday[@"end"]timeIntervalSinceNow] < 0 ? 1 : 0]addObject:holiday];
    }
    
    if(!sortedArray)return;
    if(sortedArray.count==0)return;
    if([sortedArray[0] count]==0)return;
    
    [sortedArray[0]addObject:sortedArray[0][0]];
    [sortedArray[0]removeObjectAtIndex:0];
}

- (IBAction)mushroom {
    
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Gléckspiltz 🍄" message:@"Dier hutt nëmmen 1% Chance, déi Noriicht ze gesinn! Hei sinn elo puer geheim Informatiounen ze der App (et ginn der nach vill méi) :\n\n1. Dier kënnt bal iwwerall an der App op déi wäiss Iwwerschrëften uewen drécken.\n\n2. Dier kënnt Notte méi schnell aginn wann Dier laang op d'Nimm vun de Fächer gedréckt haalt.\n\n3. Wann Dier e Witz schreift an Dier wëllt d'Fënster zouman ouni op \"Fertig\" ze drécken, schreift einfach \"lol\" (grouss oder kleng, mir ass et egal)." delegate:self cancelButtonTitle:@"Wousst ech net" otherButtonTitles:nil, nil];
    [alertView show];
}

- (IBAction)refresh {
    
    [automaticConnection cancel];
    NSLog(@"Downloading holidays");
    NSURL *url = [NSURL URLWithString:@"http://ilgl.eu/holidays.php"];
    [mutableData setLength:0];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10.0];
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
    [connection start];
}

- (void)invalidateTimer {
    
    if (timer.isValid) {
        
        NSLog(@"Timer invalidated");
        progress = nil;
        [timer invalidate];
    }
}

- (void)scheduleTimer {
    
    if (!timer.isValid && fileExists && titleIndex == 0) {
        
        NSLog(@"Timer scheduled");
        [self updateProgress];
        timer = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(updateProgress) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop]addTimer:timer forMode:NSRunLoopCommonModes];
    }
}
- (IBAction)didSelectTitle:(id)sender {
    
    if (fileExists) {
        
        [self invalidateTimer];
        if ([sender isKindOfClass:[UIButton class]]) titleIndex = titleIndex == 5 ? 0 : titleIndex + 1;
        currentTerm = [holidays[2][@"end"] timeIntervalSinceNow] > 0 ? 0 : [holidays[4][@"end"] timeIntervalSinceNow] > 0 ? 1 : 2;
        
        start = currentTerm == 0 ? holidays[0][@"start"] : holidays[currentTerm == 1 ? 2 : 4][@"end"];
        end = holidays[currentTerm == 0 ? 2 : currentTerm == 1 ? 4 : 9][@"start"];
        
        if (titleIndex == 0) { // 67.8267501%
            
            [self updateProgress];
            [self scheduleTimer];
            
        } else if (titleIndex == 1) { // 1. Term
            
            [titleButton setTitle:[NSString stringWithFormat:@"%d. %@", currentTerm + 1, NSLocalizedString(@"term", nil)] forState:UIControlStateNormal];
            
        } else if (titleIndex == 2) { // 09/17/14 - 07/08/15
            
            NSDateFormatter *formatter = [NSDateFormatter new];
            NSString *dateFormat = [NSDateFormatter dateFormatFromTemplate:@"dMMM" options:0 locale:[NSLocale currentLocale]];
            formatter.dateFormat = dateFormat;
            
            [titleButton setTitle:[NSString stringWithFormat:@"%@ - %@", [formatter stringFromDate:start], [formatter stringFromDate:end]] forState:UIControlStateNormal];
            
        } else if (titleIndex == 3) { // 67 / 90 days
            
            NSInteger days = 0, elapsed = 0;
            
            for (NSDate *date = start; [date compare: end] < 0; date = [date dateByAddingTimeInterval:24 * 60 * 60]) {
                
                days ++;
                
                BOOL todayElapsed;
                
                NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth fromDate:date];
                NSDateComponents *today = [[NSCalendar currentCalendar] components: NSCalendarUnitHour | NSCalendarUnitDay | NSCalendarUnitMonth fromDate:[NSDate date]];
                
                if (today.day == components.day && today.month == components.month) {
                    
                    todayElapsed = today.hour >= 14;
                    
                } else todayElapsed = YES;
                
                if ([date compare: [NSDate date]] <= 0 && todayElapsed) elapsed ++;
            }
            
            [titleButton setTitle:[NSString stringWithFormat:@"%d/%d %@", elapsed, days, NSLocalizedString(@"days", nil)] forState:UIControlStateNormal];
            
        } else if (titleIndex == 4) { // 32/56 schooldays
            
            NSDateComponents *components;
            BOOL weekend, holiday;
            
            NSInteger schooldays = 0, elapsed = 0;
            
            for (NSDate *date = start; [date compare: end] < 0; date = [date dateByAddingTimeInterval:24 * 60 * 60]) {
                
                components = [[NSCalendar currentCalendar] components:NSCalendarUnitWeekday | NSCalendarUnitDay | NSCalendarUnitMonth fromDate:date];
                
                weekend = components.weekday == 7 || components.weekday == 1;
                
                NSDictionary *period = holidays[currentTerm == 0 ? 1 : currentTerm == 1 ? 3 : 7];
                holiday = ([date compare:period[@"start"]] >= 0 && [date compare:period[@"end"]] < 0);
                
                BOOL publicHoliday = NO;
                if (currentTerm == 2) {
                    
                    publicHoliday = components.day == 30 && components.month == 4;
                    if (!publicHoliday) {
                        
                        NSDateComponents *holiday = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth fromDate:holidays[6][@"start"]];
                        publicHoliday = components.day == holiday.day + 1 && components.month == holiday.month;
                        if (!publicHoliday) {
                            
                            holiday = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth fromDate:holidays[8][@"start"]];
                            publicHoliday = components.day == holiday.day + 1 && components.month == holiday.month;
                        }
                    }
                }
                
                BOOL todayElapsed;
                
                NSDateComponents *today = [[NSCalendar currentCalendar] components: NSCalendarUnitHour | NSCalendarUnitDay | NSCalendarUnitMonth fromDate:[NSDate date]];
                
                if (today.day == components.day && today.month == components.month) {
                    
                    todayElapsed = today.hour >= 14;
                    
                } else todayElapsed = YES;
                
                if (!weekend && !holiday && !publicHoliday) schooldays ++;
                if (!weekend && !holiday && !publicHoliday && todayElapsed && [date compare: [NSDate date]] <= 0) elapsed ++;
            }
            
            [titleButton setTitle:[NSString stringWithFormat:@"%d/%d %@", elapsed, schooldays, NSLocalizedString(@"schooldays", nil)] forState:UIControlStateNormal];
            
        } else { // 10 schoolweeks
            
            NSCalendar *calendar = [NSCalendar currentCalendar];
            NSDateComponents *components = [calendar components:NSWeekCalendarUnit fromDate:start toDate:end options:0];
            
            // - 1 wéinst der Vakanz
            [titleButton setTitle:[NSString stringWithFormat:@"%d %@", components.week - 1, NSLocalizedString(@"schoolweeks", nil)] forState:UIControlStateNormal];
        }
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setInteger:titleIndex forKey:@"holidays"];
        
        [titleButton sizeToFit];
        titleButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    }
}

- (void)updateProgress {
    
    NSInteger newTerm = currentTerm = [holidays[2][@"end"] timeIntervalSinceNow] > 0 ? 0 : [holidays[4][@"end"] timeIntervalSinceNow] > 0 ? 1 : 2;
    if (currentTerm != newTerm) {
        
        currentTerm = newTerm;
        start = currentTerm == 0 ? holidays[0][@"start"] : holidays[currentTerm == 1 ? 2 : 4][@"end"];
        end = holidays[currentTerm == 0 ? 2 : currentTerm == 1 ? 4 : 9][@"start"];
        progress = nil;
    }
    
    NSInteger timeInterval = [end timeIntervalSinceDate:start];
    if (!progress) progress = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSinceDate:start] / timeInterval * 100];
    CGFloat fraction = 2.0 / timeInterval;
    progress = [NSNumber numberWithDouble:progress.doubleValue + fraction];
    
    [titleButton setTitle:[NSString stringWithFormat:@"%@%%", [numberFormatter stringFromNumber:progress]] forState:UIControlStateNormal];
}

#pragma mark - Table view delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return fileExists ? [sortedArray[section]count] : 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    
    UILabel *label = [UILabel new];
    label.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.15];
    return label;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    return section == 1 || [sortedArray[0]count] == 0 || [sortedArray[1]count] == 0 ? 0.0 : 15.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    NSDateFormatter *formatter = [NSDateFormatter new];
    NSString *dateFormat = [NSDateFormatter dateFormatFromTemplate:@"EEEEdMMMM" options:0 locale:[NSLocale currentLocale]];
    formatter.dateFormat = dateFormat;
    
    NSString *name = sortedArray[indexPath.section][indexPath.row][@"name"];
    
    if ([name isEqualToString:@"schoolyear"]) {
        
        NSDateComponents *components = [[NSCalendar currentCalendar] components:NSYearCalendarUnit fromDate:holidays[0][@"start"]];
        NSInteger year = components.year;
        cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"current year", nil), year, year - 2000 + 1];
        
    } else cell.textLabel.text = NSLocalizedString(name, nil);
    
    NSDate *date1 = [sortedArray[indexPath.section][indexPath.row][@"start"]dateByAddingTimeInterval:[name isEqualToString:@"schoolyear"] ? 0 : 24 * 60 * 60];
    NSDate *date2 = [sortedArray[indexPath.section][indexPath.row][@"end"]dateByAddingTimeInterval:[name isEqualToString:@"schoolyear"] ? 0 : -(24 * 60 * 60)];
    
    NSString *startString = [formatter stringFromDate:date1];
    NSString *endString = [formatter stringFromDate:date2];
    
    if ([startString isEqualToString:endString] || [date1 timeIntervalSinceDate:date2] > 0) cell.detailTextLabel.text = startString;
    else cell.detailTextLabel.text = [NSString stringWithFormat:@"%@\n%@", [formatter stringFromDate:date1], [formatter stringFromDate:date2]];
    
    return cell;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    Countdown *countdown = segue.destinationViewController;
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    countdown.name = cell.textLabel.text;
    countdown.holidays = sortedArray[indexPath.section][indexPath.row];
}

#pragma mark - NSURLConnection Delegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    [mutableData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [mutableData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    
    [self.refreshControl endRefreshing];
    
    NSString *string = [[NSString alloc]initWithData:mutableData encoding:NSUTF8StringEncoding];
    NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    if ([string hasPrefix:@"<"] || [string stringByTrimmingCharactersInSet:set].length == 0) return;
    
    holidays = [NSJSONSerialization JSONObjectWithData:mutableData options:NSJSONReadingAllowFragments error:nil];
    [self createArrays];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [NSString stringWithFormat:@"%@/%@", paths[0],@"holidays.json"];
    if (holidays.count > 0) [mutableData writeToFile:path atomically:YES];
    
    if (!fileExists) {
        
        fileExists = YES;
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 2)] withRowAnimation:UITableViewRowAnimationFade];
        [self didSelectTitle:nil];
        
    } else [self.tableView reloadData];
    
    NSLog(@"Holidays downloaded");
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    
    NSLog(@"%@",error.localizedDescription);
    
    [self.refreshControl endRefreshing];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    if (connection != automaticConnection || !fileExists) {
        
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"error", nil) message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
    }
}

#pragma mark - Alert view delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    self.navigationItem.rightBarButtonItem = nil;
}

@end
