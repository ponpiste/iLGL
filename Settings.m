//
//  Settings.m
//  iLGL
//
//  Created by Sacha Bartholmé on 13/07/15.
//  Copyright (c) 2015 The iLGL Team. All rights reserved.
//

#import "Settings.h"

@implementation Settings

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.topItem.title = @" ";
    [self createList];
    [titleButton setTitle:[self wordCount] forState:UIControlStateNormal];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    /*if (self.isMovingFromParentViewController) [_delegate didEditSelected:_selected];
*/}

- (IBAction)longPress:(UILongPressGestureRecognizer *)sender {
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        
        CGPoint point = [sender locationInView:self.tableView];
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:point];
        [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        
        if (indexPath) {
            
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            
            NSInteger loc = -1, len = 1;
            for (NSInteger i = 0; i < vocabulary.count; i++) {
                if ([vocabulary[i][@"location"]hasPrefix:cell.textLabel.text]) {
                    if (loc < 0) loc = i;
                    else len ++;
                }
            }
            
            NSMutableArray *array = [NSMutableArray new];
            
            if ([[cell.detailTextLabel.text componentsSeparatedByString:@" / "][0]doubleValue] < [[cell.detailTextLabel.text componentsSeparatedByString:@" / "][1]doubleValue] / 2) {
                
                for (NSInteger i = 0; i < len; i ++) [array addObject:@YES];
                
            } else for (NSInteger i = 0; i < len; i ++) [array addObject:@NO];
            
            [_selected replaceObjectsInRange:NSMakeRange(loc, len) withObjectsFromArray:array];
            [self.tableView reloadData];
            [titleButton setTitle:[self wordCount] forState:UIControlStateNormal];
            [_delegate didEditSelected:_selected];
        }
    }
}

- (IBAction)wand {
    
    if (selectedWords < (double)wordCount / 2) for (NSInteger i = 0; i < _selected.count; i ++) _selected[i] = @YES;
    else for (NSInteger i = 0; i < _selected.count; i ++) _selected[i] = @NO;
    
    [titleButton setTitle:[self wordCount] forState:UIControlStateNormal];
    [titleButton sizeToFit];
    [self.tableView reloadData];
    [_delegate didEditSelected:_selected];
}

- (void)didEditSelected:(NSArray *)newSelected {
    
    [_selected replaceObjectsInRange:range withObjectsFromArray:newSelected];
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionMiddle];
    [titleButton setTitle:[self wordCount] forState:UIControlStateNormal];
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
    for (NSInteger i = 0; i < vocabulary.count; i++) {
        
        wordCount += [vocabulary[i][@"words"]count];
        if ([_selected[i]boolValue]) selectedWords += [vocabulary[i][@"words"]count];
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

- (void)createList {
    
    vocabulary = [NSMutableArray new];
    
    for (NSInteger i = 6; i > 1; i --) {
        
        NSString *filename = [NSString stringWithFormat:@"%de", i];
        NSString *path = [[NSBundle mainBundle]pathForResource:filename ofType:@"txt"];
        NSString *content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
        NSArray *divisions = [content componentsSeparatedByString:@"\n\n"];
        
        for (NSInteger j = 0; j < divisions.count; j ++) {
            
            NSString *division = divisions[j];
            NSMutableArray *lines = [NSMutableArray arrayWithArray:[division componentsSeparatedByString:@"\n"]];
            NSString *chapter = [lines[0] stringByReplacingOccurrencesOfString:@"chapter" withString:NSLocalizedString(@"chapter", nil)];
            [lines removeObjectAtIndex:0];
            
            NSMutableArray *words = [NSMutableArray new];
            
            for (NSString *line in lines) {
                
                NSArray *array = [line componentsSeparatedByString:@" = "];
                if(array.count<2)continue;
                NSString *latin = array[0];
                NSString *french = array[1];
                
                [words addObject:@{@"latin": latin, @"french": french}];
            }
            
            NSString *location = [NSString stringWithFormat:@"%@ %@", filename, chapter];
            NSDictionary *dictionary = @{@"location": location, @"words": words};
            [vocabulary addObject:dictionary];
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.textLabel.text = [NSString stringWithFormat:@"%de", indexPath.row + 2];
    
    NSInteger selected = 0, count = 0;
    NSMutableArray *array = [NSMutableArray new];
    for (NSInteger i = 0; i < vocabulary.count; i++) {
        if ([vocabulary[i][@"location"]hasPrefix:cell.textLabel.text]) {
            [array addObject:vocabulary[i]];
            if ([_selected[i]boolValue]) selected += [vocabulary[i][@"words"]count];
        }
    }
    for (NSDictionary *dictionary in array) count += [dictionary[@"words"]count];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d / %d", selected, count];
    
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    Chapters *chapters = segue.destinationViewController;
    chapters.delegate = self;
    
    self.navigationItem.title = cell.textLabel.text;
    NSMutableArray *array = [NSMutableArray new];
    for (NSDictionary *chapter in vocabulary) if ([chapter[@"location"]hasPrefix:cell.textLabel.text]) [array addObject:chapter];
    chapters.chapters = array;
    
    NSInteger loc = -1, len = 1;
    for (NSInteger i = 0; i < vocabulary.count; i++) {
        if ([vocabulary[i][@"location"]hasPrefix:cell.textLabel.text]) {
            if (loc < 0) loc = i;
            else len ++;
        }
    }
    
    range = NSMakeRange(loc, len);
    chapters.selected = [NSMutableArray arrayWithArray:[_selected objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:range]]];
}

@end
