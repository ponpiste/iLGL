//
//  Countdown.m
//  iLGL
//
//  Created by Sacha Bartholmé on 21/10/2014.
//  Copyright (c) 2014 The iLGL Team. All rights reserved.
//

#import "Countdown.h"

@implementation Countdown

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.topItem.title = @" ";
    
    // Activer ou non
    //self.navigationItem.rightBarButtonItem = nil;
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(invalidateTimer) name:@"invalidateTimer" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(scheduleTimer) name:@"scheduleTimer" object:nil];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    durationButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    durationButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    durationIndex = -1;
    alertViewIndex = -1;
    [self duration];
    
    //titleButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    [self scheduleTimer];
    
    formatter = [NSNumberFormatter new];
    formatter.maximumFractionDigits = 9;
    formatter.minimumFractionDigits = 9;
    formatter.minimumIntegerDigits = 1;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    
    [self invalidateTimer];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"invalidateTimer" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"scheduleTimer" object:nil];
}

- (IBAction)duration {
    
    durationIndex = durationIndex == 5 ? 0 : durationIndex + 1;
    NSNumberFormatter *numberFormatter = [NSNumberFormatter new];
    numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
    numberFormatter.groupingSeparator = @" ";
    
    if (durationIndex == 0) {
        
        NSDateComponents *components = [[NSCalendar currentCalendar]components:NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit fromDate:_holidays[@"start"] toDate:_holidays[@"end"] options:0];
        
        NSString *days = components.day == 0 ? @"" : [NSString stringWithFormat:@"%@%@ ",[numberFormatter stringFromNumber:[NSNumber numberWithInteger:components.day]] , NSLocalizedString(components.day == 1 ? @"d" : @"ds", nil)];
        NSString *hours = components.hour == 0 ? @"" : [NSString stringWithFormat:@"%@%@ ",[numberFormatter stringFromNumber:[NSNumber numberWithInteger:components.hour]] , NSLocalizedString(components.hour == 1 ? @"hr" : @"hrs", nil)];
        NSString *minutes = components.minute == 0 ? @"" : [NSString stringWithFormat:@"%@%@ ",[numberFormatter stringFromNumber:[NSNumber numberWithInteger:components.minute]] , NSLocalizedString(@"’", nil)];
        NSString *seconds = components.second == 0 ? @"" : [NSString stringWithFormat:@"%@%@",[numberFormatter stringFromNumber:[NSNumber numberWithInteger:components.second]] , NSLocalizedString(@"”", nil)];
        
        [durationButton setTitle:[NSString stringWithFormat:@"%@%@%@%@", days, hours, minutes, seconds] forState:UIControlStateNormal];
        
    } else if (durationIndex == 1) {
        
        NSDateComponents *components = [[NSCalendar currentCalendar]components:NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit fromDate:_holidays[@"start"] toDate:_holidays[@"end"] options:0];
        
        NSString *hours = components.hour == 0 ? @"" : [NSString stringWithFormat:@"%@%@ ",[numberFormatter stringFromNumber:[NSNumber numberWithInteger:components.hour]] , NSLocalizedString(components.hour == 1 ? @"hr" : @"hrs", nil)];
        NSString *minutes = components.minute == 0 ? @"" : [NSString stringWithFormat:@"%@%@ ",[numberFormatter stringFromNumber:[NSNumber numberWithInteger:components.minute]] , NSLocalizedString(@"’", nil)];
        NSString *seconds = components.second == 0 ? @"" : [NSString stringWithFormat:@"%@%@",[numberFormatter stringFromNumber:[NSNumber numberWithInteger:components.second]] , NSLocalizedString(@"”", nil)];
        
        [durationButton setTitle:[NSString stringWithFormat:@"%@%@%@", hours, minutes, seconds] forState:UIControlStateNormal];
        
    } else if (durationIndex == 2) {
        
        NSDateComponents *components = [[NSCalendar currentCalendar]components:NSMinuteCalendarUnit | NSSecondCalendarUnit fromDate:_holidays[@"start"] toDate:_holidays[@"end"] options:0];
        
        NSString *minutes = components.minute == 0 ? @"" : [NSString stringWithFormat:@"%@%@ ",[numberFormatter stringFromNumber:[NSNumber numberWithInteger:components.minute]] , NSLocalizedString(@"’", nil)];
        NSString *seconds = components.second == 0 ? @"" : [NSString stringWithFormat:@"%@%@",[numberFormatter stringFromNumber:[NSNumber numberWithInteger:components.second]] , NSLocalizedString(@"”", nil)];
        
        [durationButton setTitle:[NSString stringWithFormat:@"%@%@", minutes, seconds] forState:UIControlStateNormal];
        
    } else if (durationIndex == 3) {
        
        NSDateComponents *components = [[NSCalendar currentCalendar]components:NSSecondCalendarUnit fromDate:_holidays[@"start"] toDate:_holidays[@"end"] options:0];
        
        NSString *seconds = [NSString stringWithFormat:@"%@%@",[numberFormatter stringFromNumber:[NSNumber numberWithInteger:components.second]] , NSLocalizedString(@"”", nil)];
        
        [durationButton setTitle:[NSString stringWithFormat:@"%@", seconds] forState:UIControlStateNormal];
        
    } else if (durationIndex == 4) {
        
        NSDateComponents *components = [[NSCalendar currentCalendar]components:NSWeekCalendarUnit fromDate:_holidays[@"start"] toDate:_holidays[@"end"] options:0];
        
        NSString *weeks = [NSString stringWithFormat:@"%@ %@", [numberFormatter stringFromNumber:[NSNumber numberWithInteger:components.week]], NSLocalizedString(components.week == 1 ? @"week" : @"weeks", nil)];
        
        [durationButton setTitle:[NSString stringWithFormat:@"%@", weeks] forState:UIControlStateNormal];
        
    } else {
        
        NSDateComponents *components = [[NSCalendar currentCalendar]components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:_holidays[@"start"] toDate:_holidays[@"end"] options:0];
        
        NSString *years = components.year == 0 ? @"" : [NSString stringWithFormat:@"%@ %@ ", [numberFormatter stringFromNumber:[NSNumber numberWithInteger:components.year]], NSLocalizedString(components.year == 1 ? @"year" : @"years", nil)];;
        NSString *months = components.month == 0 ? @"" : [NSString stringWithFormat:@"%@ %@ ", [numberFormatter stringFromNumber:[NSNumber numberWithInteger:components.month]], NSLocalizedString(components.month == 1 ? @"month" : @"months", nil)];
        NSString *days = components.day == 0 ? @"" : [NSString stringWithFormat:@"%@%@ ",[numberFormatter stringFromNumber:[NSNumber numberWithInteger:components.day]] , NSLocalizedString(components.day == 1 ? @"d" : @"ds", nil)];
        
        [durationButton setTitle:[NSString stringWithFormat:@"%@%@%@", years, months, days] forState:UIControlStateNormal];
    }
}

- (IBAction)secret {
    
    alertViewIndex = alertViewIndex < 0 ? arc4random()%2 : alertViewIndex == 0 ? 1 : 0;
    
    if (alertViewIndex) {
        
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Entrez un nombre" message:@"Entrez un nombre entre 1 et 100 pour connaître la date exacte où le pourcentage atteint le nombre donné." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
        [alertView textFieldAtIndex:0].keyboardType = UIKeyboardTypeDecimalPad;
        [alertView textFieldAtIndex:0].textAlignment = NSTextAlignmentCenter;
        [alertView show];
        
    } else {
        
        NSDateFormatter *dateFormatter = [NSDateFormatter new];
        dateFormatter.dateFormat = @"dd/MM/yyyy HH:mm:ss";
        
        dateAlertView = [[UIAlertView alloc]initWithTitle:@"Entrez deux dates" message:@"Entrez deux dates pour rafraîchir la page avec les nouveaux paramètres." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        dateAlertView.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
        [dateAlertView textFieldAtIndex:0].placeholder = @"08/12/2013 08:00:00";
        [dateAlertView textFieldAtIndex:0].text = [dateFormatter stringFromDate:_holidays[@"start"]];
        [dateAlertView textFieldAtIndex:1].secureTextEntry = NO;
        [dateAlertView textFieldAtIndex:1].placeholder = @"28/02/2017 13:00:00";
        [dateAlertView textFieldAtIndex:1].text = [dateFormatter stringFromDate:_holidays[@"end"]];
        [dateAlertView show];
    }
}

- (IBAction)didSelectTitle {/*
    
    titleIndex = titleIndex == 0 ? 1 : 0;
    if (titleIndex == 0) {
        
        [self scheduleTimer];
        
    } else {
        
        [titleButton setTitle:_name forState:UIControlStateNormal];
        NSLog(@"Progress invalidated");
        progress = nil;
        [progressTimer invalidate];
    }
    [titleButton sizeToFit];
*/}

- (void)invalidateTimer {
    
    if (countdownTimer.isValid) {
        
        NSLog(@"Countdown invalidated");
        [countdownTimer invalidate];
    }
    
    if (progressTimer.isValid) {
        
        NSLog(@"Progress invalidated");
        progress = nil;
        [progressTimer invalidate];
    }
}

- (void)scheduleTimer {
    
    if (!countdownTimer.isValid) {
        
        NSLog(@"Countdown scheduled");
        [self updateCountdown];
        
        countdownTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateCountdown) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop]addTimer:countdownTimer forMode:NSRunLoopCommonModes];
    }
    
    if (!progressTimer.isValid) {
        
        NSLog(@"Progress scheduled");
        [self updateProgress];
        
        progressTimer = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(updateProgress) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop]addTimer:progressTimer forMode:NSRunLoopCommonModes];
    }
}

- (void)updateProgress {
        
    if (!progress) {
        
        NSNumber *interval = [NSNumber numberWithInteger:[[NSDate date] timeIntervalSinceDate:_holidays[@"start"]]];
        duration = [NSNumber numberWithInteger:[_holidays[@"end"] timeIntervalSinceDate:_holidays[@"start"]]];
        progress = [NSNumber numberWithDouble:interval.doubleValue / duration.doubleValue * 100.0];
        
    } else progress = [NSNumber numberWithDouble:progress.doubleValue + fabs(2.0 / duration.doubleValue)];
    
    [titleButton setTitle:[NSString stringWithFormat:@"%@%%", [formatter stringFromNumber:progress]] forState:UIControlStateNormal];
}

- (void)updateCountdown {
    
    NSDateComponents *components;
    
    components = [[NSCalendar currentCalendar]components:NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit fromDate:[NSDate date] toDate:_holidays[@"start"] options:0];
    
    if (labs(components.day) >= 100) {
        
        components = [[NSCalendar currentCalendar]components:NSMonthCalendarUnit | NSDayCalendarUnit fromDate:[NSDate date] toDate:_holidays[@"start"] options:0];
        
        monthsStart.hidden = NO;
        
        NSString *months = components.month == 0 ? @"" : [NSString stringWithFormat:@"%d %@", components.month, NSLocalizedString(components.month == 1 ? @"month" : @"months", nil)];
        NSString *days = components.day == 0 ? @"" : [NSString stringWithFormat:@"%d %@", components.day, NSLocalizedString(components.month == 1 ? @"day" : @"days", nil)];
        monthsStart.text = [NSString stringWithFormat:@"%@ %@", months, days];
        
    } else {
        
        monthsStart.hidden = YES;
        
        daysStart.text = [NSString stringWithFormat:@"%i", components.day];
        hoursStart.text = [NSString stringWithFormat:@"%i", components.hour];
        minutesStart.text = [NSString stringWithFormat:@"%i", components.minute];
        secondsStart.text = [NSString stringWithFormat:@"%i", components.second];
    }
    
    
    
    components = [[NSCalendar currentCalendar]components:NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit fromDate:[NSDate date] toDate:_holidays[@"end"] options:0];
    
    if (labs(components.day) >= 100) {
        
        components = [[NSCalendar currentCalendar]components:NSMonthCalendarUnit | NSDayCalendarUnit fromDate:[NSDate date] toDate:_holidays[@"end"] options:0];
        
        monthsEnd.hidden = NO;
        
        NSString *months = components.month == 0 ? @"" : [NSString stringWithFormat:@"%d %@", components.month, NSLocalizedString(components.month == 1 ? @"month" : @"months", nil)];
        NSString *days = components.day == 0 ? @"" : [NSString stringWithFormat:@"%d %@", components.day, NSLocalizedString(components.month == 1 ? @"day" : @"days", nil)];
        monthsEnd.text = [NSString stringWithFormat:@"%@ %@", months, days];
        
    } else {
        
        monthsEnd.hidden = YES;
        
        daysEnd.text = [NSString stringWithFormat:@"%i", components.day];
        hoursEnd.text = [NSString stringWithFormat:@"%i", components.hour];
        minutesEnd.text = [NSString stringWithFormat:@"%i", components.minute];
        secondsEnd.text = [NSString stringWithFormat:@"%i", components.second];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UILabel *label = [UILabel new];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = [UIColor lightGrayColor];
    label.alpha = 0.6;
    label.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:22.0];
    label.text = [self.tableView.dataSource tableView:tableView titleForHeaderInSection:section];
    return label;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 25.0;
}

# pragma mark - Alert view delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if ([alertView isEqual:dateAlertView]) {
        
        UITextField *textField1 = [alertView textFieldAtIndex:0];
        UITextField *textField2 = [alertView textFieldAtIndex:1];
        
        NSDateFormatter *dateFormatter = [NSDateFormatter new];
        dateFormatter.dateFormat = @"dd/MM/yyyy HH:mm:ss";
        
        NSDate *date1 = [textField1.text.lowercaseString isEqualToString:@"lo"] ? [NSDate date] : [dateFormatter dateFromString:textField1.text];
        NSDate *date2 = [textField2.text.lowercaseString isEqualToString:@"lo"] ? [NSDate date] : [dateFormatter dateFromString:textField2.text];
        _holidays = @{@"name": _holidays[@"name"], @"start": date1, @"end": date2};
        
        durationIndex --;
        [self duration];
        progress = nil;
        [self updateCountdown];
        
    } else {
        
        UITextField *textField = [alertView textFieldAtIndex:0];
        NSNumber *number = [formatter numberFromString:textField.text];
        NSDate *date = [_holidays[@"start"]dateByAddingTimeInterval:duration.doubleValue / 100.0 * number.doubleValue];
        
        NSDateFormatter *dateFormatter = [NSDateFormatter new];
        dateFormatter.timeZone = [NSTimeZone localTimeZone]; // ???
        NSString *dateFormat = [NSDateFormatter dateFormatFromTemplate:@"EEEEdMMMMy" options:0 locale:[NSLocale localeWithLocaleIdentifier:@"fr_FR"]];
        dateFormatter.dateFormat = dateFormat;
        dateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"fr_FR"];
        NSString *day = [dateFormatter stringFromDate:date];
        
        dateFormat = [NSDateFormatter dateFormatFromTemplate:@"EEEEdMMMM" options:0 locale:[NSLocale localeWithLocaleIdentifier:@"fr_FR"]];
        dateFormatter.dateFormat = dateFormat;
        NSString *title = [dateFormatter stringFromDate:date];
        
        dateFormatter.timeStyle = NSDateFormatterFullStyle;
        NSString *time = [dateFormatter stringFromDate:date];
        
        NSNumberFormatter *numberFormatter = [NSNumberFormatter new];
        numberFormatter.maximumFractionDigits = 7;
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *components = [calendar components:NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit fromDate:[NSDate date] toDate:date options:0];
        BOOL over = [date timeIntervalSinceNow] < 0;
        NSString *message = [NSString stringWithFormat:@"Le pourcentage %@ les %@%% le %@ à %@, soit %@ %dj, %dh, %d’ et %ld”\n\nTrouvez-vous cette information utile ou pas?", over ? @"a atteint" : @"atteindra", [numberFormatter stringFromNumber:number], day, time, over ? @"il y a" : @"dans", labs(components.day), labs(components.hour), labs(components.minute), labs(components.second)];
        
        UIAlertView *newAlertView = [[UIAlertView alloc]initWithTitle:title message:message delegate:nil cancelButtonTitle:@"Excellent 😂" otherButtonTitles:nil];
        [newAlertView show];
    }
}

- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView {
    
    if ([alertView isEqual:dateAlertView]) {
        
        UITextField *textField1 = [alertView textFieldAtIndex:0];
        UITextField *textField2 = [alertView textFieldAtIndex:1];
        
        NSDateFormatter *dateFormatter = [NSDateFormatter new];
        dateFormatter.dateFormat = @"dd/MM/yyyy HH:mm:ss";
        
        NSDate *date1 = [dateFormatter dateFromString:textField1.text];
        NSDate *date2 = [dateFormatter dateFromString:textField2.text];
        
        NSDateComponents *components = [[NSCalendar currentCalendar] components: NSYearCalendarUnit fromDate:date1 toDate:date2 options:0];
        
        return (date1 || [textField1.text.lowercaseString isEqualToString:@"lo"]) && (date2 || [textField2.text.lowercaseString isEqualToString:@"lo"]) && labs(components.year) <= 200;
        
    } else {
        
        UITextField *textField = [alertView textFieldAtIndex:0];
        NSNumber *number = [formatter numberFromString:textField.text];
        return number && textField.text.length < 8;
    }
}

@end
