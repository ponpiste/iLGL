//
//  Ask.m
//  iLGL
//
//  Created by Sacha Bartholmé on 13/07/15.
//  Copyright (c) 2015 The iLGL Team. All rights reserved.
//

#import "Ask.h"

@implementation Ask

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *rewind = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"rewind.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(rewind)];
    
    UIBarButtonItem *forward = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"forward.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(forward)];
    
    self.navigationController.navigationBar.topItem.title = @" ";
    self.navigationItem.rightBarButtonItems = @[forward, rewind];
        
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Light" size:21.0];
    NSDictionary *attributes = @{NSFontAttributeName: font};
    [segmentedControl setTitleTextAttributes:attributes forState:UIControlStateNormal];
    
    segmentedControl.selectedSegmentIndex = [_askSettings[@"version"]integerValue];
    [smudged setOn:[_askSettings[@"smudged"]boolValue]];
    [random setOn:[_askSettings[@"random"]boolValue]];
    
    cache = [NSMutableArray arrayWithArray:@[_indexPath]];
    [self reloadWords:NO];
}

- (void)reloadWords:(BOOL)animated {
    
    NSDictionary *word = _vocabulary[_indexPath.section][@"words"][_indexPath.row];
    latin.text = word[@"latin"];
    french.text = word[@"french"];
    heart.selected = [word[@"favourite"]boolValue];
    
    NSMutableString *title = [NSMutableString stringWithString:_vocabulary[_indexPath.section][@"location"]];
    [title replaceOccurrencesOfString:NSLocalizedString(@"chapter", nil) withString:NSLocalizedString(@"chap", nil) options:0 range:NSMakeRange(0, title.length)];
    [titleButton setTitle:title forState:UIControlStateNormal];
    
    if ([_askSettings[@"smudged"]boolValue]) {
        
        [UIView animateWithDuration:animated ? 0.2 : 0 animations:^{
            
            latinSmudge.alpha = [_askSettings[@"version"]integerValue] == 0;
            frenchSmudge.alpha = [_askSettings[@"version"]integerValue] == 1;
        }];
        
    } else {
        
        [UIView animateWithDuration:animated ? 0.2 : 0 animations:^{
            
            latinSmudge.alpha = 0;
            frenchSmudge.alpha = 0;
        }];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        
        if (frenchSmudge.alpha == 0 && latinSmudge.alpha == 0) _askSettings[@"smudged"] = @YES;
        [smudged setOn:YES animated:YES];
        
        if (indexPath.row == 0) {
            
            _askSettings[@"version"] = @NO;
            segmentedControl.selectedSegmentIndex = 0;
            
            if (!(frenchSmudge.alpha == 0)) {
                
                latinSmudge.alpha = 1;
                frenchSmudge.alpha = 0;
                
            } else [UIView animateWithDuration:0.2 animations:^{latinSmudge.alpha = 1 - latinSmudge.alpha;}];
        
        } else {
            
            _askSettings[@"version"] = @YES;
            segmentedControl.selectedSegmentIndex = 1;
            
            if (!(latinSmudge.alpha == 0)) {
                
                latinSmudge.alpha = 0;
                frenchSmudge.alpha = 1;
                
                
            } else [UIView animateWithDuration:0.2 animations:^{frenchSmudge.alpha = 1 - frenchSmudge.alpha;}];
        }
        [_delegate didEditAskSettings:_askSettings];
        
    } else if (indexPath.section == 1 && indexPath.row == 0) [self favourite];
}

- (IBAction)favourite {
    
    heart.selected = !heart.selected;
    _vocabulary[_indexPath.section][@"words"][_indexPath.row][@"favourite"] = @(heart.selected);
    [_delegate didEditFavourite:heart.selected forIndex:[_vocabulary[_indexPath.section][@"words"][_indexPath.row][@"index"]integerValue]];
}

- (void)rewind {
    
    if (random.isOn && cache.count > 0) {
        
        [cache removeLastObject];
        [self setIndexPath:[cache lastObject]];
        
    } else {
        
        NSInteger row = _indexPath.row - 1;
        NSInteger section = _indexPath.section;
        
        if (row < 0) {
            
            section -= 1;
            
            if (section < 0) {
                section = _vocabulary.count - 1;
            }
            row = [_vocabulary[section][@"words"]count] - 1;
        }
        [self setIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
    }
    [self reloadWords:NO];
}

- (void)forward {
    
    NSInteger row, section;
    
    if (random.isOn) {
        
        NSIndexPath *indexPath;
        
        do {
            
            if (cache.count == _wordCount) [cache removeAllObjects];
            
            section = arc4random()%_vocabulary.count;
            row = arc4random()%[_vocabulary[section][@"words"]count];
            indexPath = [NSIndexPath indexPathForRow:row inSection:section];
            
        } while ([cache containsObject:indexPath]);
    
        [cache addObject:indexPath];
        
    } else {
        
        row = _indexPath.row + 1;
        section = _indexPath.section;
        
        if (row + 1 > [_vocabulary[_indexPath.section][@"words"]count]) {
            
            section += 1;
            row = 0;
            
            if (section + 1 > _vocabulary.count) {
                section = 0;
            }
        }
    }
    
    [self setIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
    [self reloadWords:NO];
}

- (IBAction)didSelectSegment {
    
    _askSettings[@"version"] = [NSNumber numberWithInteger:segmentedControl.selectedSegmentIndex];
    [_delegate didEditAskSettings:_askSettings];
    [self reloadWords:YES];
}

- (IBAction)leftSwipe {
    [self forward];
}
- (IBAction)rightSwipe {
    [self rewind];
}

- (IBAction)smudged {
    
    _askSettings[@"smudged"] = @(smudged.isOn);
    [_delegate didEditAskSettings:_askSettings];
    [self reloadWords:YES];
}

- (IBAction)random {
    
    [cache removeAllObjects];
    [cache addObject:_indexPath];
    
    _askSettings[@"random"] = @(random.isOn);
    [_delegate didEditAskSettings:_askSettings];
}

@end
