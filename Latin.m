//
//  Latin.m
//  iLGL
//
//  Created by Sacha Bartholmé on 13/07/15.
//  Copyright (c) 2015 The iLGL Team. All rights reserved.
//

#import "Latin.h"
#import "SWRevealViewController.h"

@implementation Latin

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.searchDisplayController.searchBar.placeholder = [NSString stringWithFormat:@"4e %@ 11, infero, manger...", NSLocalizedString(@"chapter", nil)];
    
    UIBarButtonItem *menu = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"menu.png"] style:UIBarButtonItemStyleBordered target:self.revealViewController action:@selector(revealToggle:)];
    UIBarButtonItem *heart = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"heart_white.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(favourites)];
    self.navigationItem.leftBarButtonItems = @[menu, heart];
    
    UIBarButtonItem *gaffiot = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"book.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(gaffiot)];
    UIBarButtonItem *wheel = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"settings.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(settings)];
    self.navigationItem.rightBarButtonItems = @[wheel, gaffiot];
    
    self.tableView.contentOffset = CGPointMake(0.0, self.searchDisplayController.searchBar.frame.size.height);
    self.searchDisplayController.searchResultsTableView.separatorColor = self.tableView.separatorColor;
    
    vocabulary = [NSMutableArray new];
    searchResults = [NSMutableArray new];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    if (![[[userDefaults dictionaryRepresentation]allKeys] containsObject:@"latin_ask"]) askSettings = [NSMutableDictionary dictionaryWithDictionary:@{@"version": @YES, @"smudged": @YES, @"random": @NO}];
    else askSettings = [NSMutableDictionary dictionaryWithDictionary:[userDefaults objectForKey:@"latin_ask"]];
    
    
    if (![[[userDefaults dictionaryRepresentation]allKeys] containsObject:@"latin_selected"]) {
        
        selected = [NSMutableArray new];
        for (NSInteger i = 0; i < 68; i ++) [selected addObject:@YES];
        [userDefaults setObject:selected forKey:@"latin_selected"];
        [userDefaults synchronize];
    } else selected = [NSMutableArray arrayWithArray:[userDefaults objectForKey:@"latin_selected"]];
    
    
    if (![[[userDefaults dictionaryRepresentation]allKeys] containsObject:@"latin_favourites"]) {
        
        favourites = [NSMutableArray new];
        for (NSInteger i = 0; i < 1745; i ++) [favourites addObject:@NO];
        [userDefaults setObject:favourites forKey:@"latin_favourites"];
        [userDefaults synchronize];
        
    } else {
        
        favourites = [NSMutableArray arrayWithArray:[userDefaults objectForKey:@"latin_favourites"]];
        
        if (favourites.count != 1742) {
            
            while (favourites.count != 1742) {
                if (favourites.count > 1742) [favourites removeLastObject];
                else [favourites addObject:@NO];
            }
            
            [userDefaults setObject:favourites forKey:@"latin_favourites"];
            [userDefaults synchronize];
        }
    }
    [self createList];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    [self.view addGestureRecognizer:self.revealViewController.tapGestureRecognizer];
    
    if (temporaryVoc) {
        
        [vocabulary removeAllObjects];
        NSInteger count = 0;
        
        for (NSMutableDictionary *chapter in temporaryVoc) {
            
            NSMutableDictionary *newChapter = chapter.mutableCopy;
            newChapter[@"words"] = [NSMutableArray new];
            
            for (NSDictionary *word in chapter[@"words"]) {
                
                BOOL favourite = [favourites[[word[@"index"]intValue]]boolValue];
                if (favourite) [newChapter[@"words"] addObject:word];
                count ++;
            }
            
            if ([newChapter[@"words"]count] > 0) [vocabulary addObject:newChapter];
        }
        [titleButton setTitle:[self wordCount] forState:UIControlStateNormal];
        [self.tableView reloadData];
    }
}

- (void)gaffiot {
    [self performSegueWithIdentifier:@"gaffiot" sender:nil];
}

- (void)settings {
    [self performSegueWithIdentifier:@"settings" sender:nil];
}

- (void)favourites {
    
    if (!temporaryVoc) {
        
        temporaryVoc = vocabulary.copy;
        [vocabulary removeAllObjects];
        NSInteger count = 0;
        
        for (NSMutableDictionary *chapter in temporaryVoc) {
            
            NSMutableDictionary *newChapter = chapter.mutableCopy;
            newChapter[@"words"] = [NSMutableArray new];
            
            for (NSDictionary *word in chapter[@"words"]) {
                
                BOOL favourite = [favourites[[word[@"index"]intValue]]boolValue];
                if (favourite) [newChapter[@"words"] addObject:word];
                count ++;
            }
            
            if ([newChapter[@"words"]count] > 0) [vocabulary addObject:newChapter];
        }
        
    } else {
        
        vocabulary = temporaryVoc.mutableCopy;
        temporaryVoc = nil;
    }
    
    [self.tableView reloadData];
    [titleButton setTitle:[self wordCount] forState:UIControlStateNormal];
}

- (void)invertOrder {
    
    for (NSInteger i = 0; i < vocabulary.count; i ++) {
        
        [vocabulary insertObject:[vocabulary lastObject] atIndex:i];
        [vocabulary removeLastObject];
    }
    [self.tableView reloadData];
}

- (void)createList {
    
    [vocabulary removeAllObjects];
    NSInteger chapterCount = 0;
    NSInteger wordCount = 0;
    
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
                
                if(array.count<2){
                    
                    
                    continue;
                    
                    
                }
                
                NSString *latin = array[0];
                NSString *french = array[1];
                BOOL favourite = [favourites[wordCount]boolValue];
                
                [words addObject:[NSMutableDictionary dictionaryWithDictionary:@{@"latin": latin, @"french": french, @"favourite": @(favourite), @"index": @(wordCount)}]];
                
                wordCount ++;
            }
            
            NSString *location = [NSString stringWithFormat:@"%@ %@", filename, chapter];
            if ([selected[chapterCount]boolValue]) [vocabulary addObject:[NSMutableDictionary dictionaryWithDictionary:@{@"location": location, @"words": words}]];
            chapterCount ++;
        }
    }
    
    [titleButton setTitle:[self wordCount] forState:UIControlStateNormal];
}

- (IBAction)didSelectTitle {
    
    [self invertOrder];
    
    //[titleButton setTitle:[titleButton.titleLabel.text isEqualToString:NSLocalizedString(@"latin", nil)] ? [self wordCount] : NSLocalizedString(@"latin", nil) forState:UIControlStateNormal];
    //[titleButton sizeToFit];
    //titleButton.titleLabel.adjustsFontSizeToFitWidth = YES;
}

- (void)didEditFavourite:(BOOL)favourite forIndex:(NSInteger)index {
    
    favourites[index] = @(favourite);
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:favourites forKey:@"latin_favourites"];
}

- (void)didEditAskSettings:(NSMutableDictionary *)newSettings {
    
    askSettings = newSettings;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:askSettings forKey:@"latin_ask"];
}

- (void)didEditSelected:(NSMutableArray *)newSelected {
    
    selected = newSelected;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:selected forKey:@"latin_selected"];
    [userDefaults synchronize];
    
    [self createList];
    temporaryVoc = nil;
    
    //[titleButton setTitle:[titleButton.titleLabel.text isEqualToString:NSLocalizedString(@"latin", nil)] ? NSLocalizedString(@"latin", nil) : [self wordCount] forState:UIControlStateNormal];
    [self.tableView reloadData];
}

- (NSString *)wordCount {
    
    NSInteger wordCount = 0;
    NSArray *array = self.searchDisplayController.isActive ? searchResults : vocabulary;
    for (NSDictionary *dictionary in array) wordCount += [dictionary[@"words"]count];
    return [NSString stringWithFormat:@"%d", wordCount];
}

#pragma mark - Search controller delegate

- (void)filterContentForSearchString:(NSString*)searchString scope:(NSInteger)scope
{
    [searchResults removeAllObjects];
    
    for (NSDictionary *dictionary in vocabulary) {
        
        NSArray *words = dictionary[@"words"];
        NSPredicate *predicate;
        
        predicate = [NSPredicate predicateWithFormat:@"french CONTAINS[cd] %@ || latin CONTAINS[cd] %@", searchString, searchString];
        
        /*if (scope == 0) { // Both
            
            predicate = [NSPredicate predicateWithFormat:@"french CONTAINS[cd] %@ || latin CONTAINS[cd] %@", searchString, searchString];
            
        } else if (scope == 1) { // Latin only
            
            predicate = [NSPredicate predicateWithFormat:@"latin CONTAINS[cd] %@", searchString];
            
        } else { // French only
            
            predicate = [NSPredicate predicateWithFormat:@"french CONTAINS[cd] %@", searchString];
        }*/
        
        NSArray *array = [words filteredArrayUsingPredicate:predicate];
        
        if ([[dictionary[@"location"]lowercaseString] rangeOfString:searchString.lowercaseString].location != NSNotFound) {
            [searchResults addObject:@{@"location": dictionary[@"location"], @"words": dictionary[@"words"]}];
            
        } else if (array.count > 0) [searchResults addObject:@{@"location": dictionary[@"location"], @"words": array}];
    }
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    
    [self filterContentForSearchString:searchString scope:self.searchDisplayController.searchBar.selectedScopeButtonIndex];
    
    return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
    
    [self filterContentForSearchString:self.searchDisplayController.searchBar.text scope:searchOption];
    
    return YES;
}

#pragma mark - Table view delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return tableView == self.tableView ? vocabulary.count : searchResults.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UILabel *label = [UILabel new];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = [UIColor lightGrayColor];
    label.alpha = 0.7;
    label.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:22.0];
    
    NSArray *array = tableView == self.tableView ? vocabulary : searchResults;
    NSString *location = array[section][@"location"];
    //NSInteger count = [array[section][@"words"]count];
    label.text = [NSString stringWithFormat:@"%@", location];
    //label.text = [NSString stringWithFormat:@"%@ - %d %@", location, count, NSLocalizedString(@"terms", nil)];
    
    return label;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 25.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return tableView == self.tableView ? [vocabulary[section][@"words"]count] : [searchResults[section][@"words"]count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    
    NSArray *array = tableView == self.tableView ? vocabulary : searchResults;
    
    cell.textLabel.text = array[indexPath.section][@"words"][indexPath.row][@"latin"];
    cell.detailTextLabel.numberOfLines = 2;
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:23.0];
    cell.textLabel.textColor = [UIColor colorWithRed:230/255.0 green:78/255.0 blue:77/255.0 alpha:1.0];
    
    cell.detailTextLabel.text = array[indexPath.section][@"words"][indexPath.row][@"french"];
    cell.detailTextLabel.numberOfLines = 2;
    cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:23.0];
    cell.detailTextLabel.textColor = [UIColor colorWithRed:85/255.0 green:85/255.0 blue:85/255.0 alpha:1.0];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"ask" sender:nil];
}

#pragma mark Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"settings"]) {
        
        Settings *settingsVC = segue.destinationViewController;
        settingsVC.delegate = self;
        settingsVC.selected = selected;
        
    } else if ([segue.identifier isEqualToString:@"ask"]) {
        
        UITableView *tableView = self.searchDisplayController.isActive ? self.searchDisplayController.searchResultsTableView : self.tableView;
        
        Ask *ask = (Ask *)segue.destinationViewController;
        ask.askSettings = askSettings;
        ask.indexPath = [tableView indexPathForSelectedRow];
        ask.delegate = self;
        ask.vocabulary = self.searchDisplayController.isActive ? searchResults : vocabulary;
        ask.wordCount = [self wordCount].integerValue;
    }
}

@end
