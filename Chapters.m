//
//  Chapters.m
//  iLGL
//
//  Created by Sacha Bartholmé on 12/08/15.
//  Copyright (c) 2015 The iLGL Team. All rights reserved.
//

#import "Chapters.h"

@implementation Chapters

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [titleButton setTitle:[self wordCount] forState:UIControlStateNormal];
}

- (IBAction)wand {
    
    if (selectedWords < (double)wordCount / 2) for (NSInteger i = 0; i < _selected.count; i ++) _selected[i] = @YES;
    else for (NSInteger i = 0; i < _selected.count; i ++) _selected[i] = @NO;
    
    [titleButton setTitle:[self wordCount] forState:UIControlStateNormal];
    [titleButton sizeToFit];
    [self.tableView reloadData];
    [_delegate didEditSelected:_selected];
}

- (IBAction)didSelectTitle {
    
    if ([titleButton.titleLabel.text hasSuffix:@"%"]) {
        
        [titleButton setTitle:[NSString stringWithFormat:@"%d / %d", selectedWords, wordCount] forState:UIControlStateNormal];
    }
    
    else {
        
        NSNumber *number = [NSNumber numberWithDouble:(double)selectedWords / (double)wordCount * 100];
        NSNumberFormatter *formatter = [NSNumberFormatter new];
        formatter.numberStyle = NSNumberFormatterDecimalStyle;
        formatter.maximumFractionDigits = 5;
        [titleButton setTitle:[NSString stringWithFormat:@"%@%%", [formatter stringFromNumber:number]] forState:UIControlStateNormal];
    }
}

- (NSString *)wordCount {
    
    wordCount = 0, selectedWords = 0;
    for (NSInteger i = 0; i < _chapters.count; i++) {
        
        wordCount += [_chapters[i][@"words"]count];
        if ([_selected[i]boolValue]) selectedWords += [_chapters[i][@"words"]count];
    }
        
    if ([titleButton.titleLabel.text hasSuffix:@"%"]) {
        
        NSNumber *number = [NSNumber numberWithDouble:(double)selectedWords / (double)wordCount * 100];
        NSNumberFormatter *formatter = [NSNumberFormatter new];
        formatter.numberStyle = NSNumberFormatterDecimalStyle;
        formatter.maximumFractionDigits = 5;
        return [NSString stringWithFormat:@"%@%%", [formatter stringFromNumber:number]];
    }
    
    else {
        return [NSString stringWithFormat:@"%d / %d", selectedWords, wordCount];
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _chapters.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.accessoryType = [_selected[indexPath.row]boolValue] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    
    cell.textLabel.text = [_chapters[indexPath.row][@"location"] stringByReplacingCharactersInRange:NSMakeRange(0, 3) withString:@""];
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", [_chapters[indexPath.row][@"words"]count]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
        
        cell.accessoryType = UITableViewCellAccessoryNone;
        _selected[indexPath.row] = @NO;
        
    } else {
        
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        _selected[indexPath.row] = @YES;
    }
    
    [titleButton setTitle:[self wordCount] forState:UIControlStateNormal];
    [_delegate didEditSelected:_selected];
}

@end
