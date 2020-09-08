//
//  Physics.m
//  iLGL
//
//  Created by Sacha Bartholmé on 1/12/16.
//  Copyright © 2016 The iLGL Team. All rights reserved.
//

#import "Physics.h"
#import "SWRevealViewController.h"
#import "Formulas.h"

@implementation Physics

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem.target = self.revealViewController;
    self.navigationItem.leftBarButtonItem.action = @selector(revealToggle:);
    
    self.tableView.contentOffset = CGPointMake(0.0, self.searchDisplayController.searchBar.frame.size.height);
    self.searchDisplayController.searchResultsTableView.separatorColor = self.tableView.separatorColor;
    
    NSString *path = [NSString stringWithFormat:@"%@/Physics",[NSBundle mainBundle].resourcePath];
    files = [NSMutableArray arrayWithArray:[[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil]];
    [files removeObject:@".DS_Store"];
    
    /*path = [path stringByAppendingPathComponent:@"contents.txt"];
    NSString *string = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    contents = [string componentsSeparatedByString:@"\n\n"];*/
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    [self.view addGestureRecognizer:self.revealViewController.tapGestureRecognizer];
    
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Table view delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return tableView == self.tableView ? files.count : searchResults.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    
    NSArray *array = tableView == self.tableView ? files : searchResults;
    cell.textLabel.text = [array[indexPath.row]stringByReplacingOccurrencesOfString:@".pdf" withString:@""];
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:23.0];
    cell.textLabel.textColor = [UIColor darkGrayColor];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"segue" sender:nil];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    Formulas *formulas = segue.destinationViewController;
    NSIndexPath *indexPath = [self.searchDisplayController.isActive ? self.searchDisplayController.searchResultsTableView : self.tableView indexPathForSelectedRow];
    NSArray *array = self.searchDisplayController.isActive ? searchResults : files;
    formulas.file = array[indexPath.row];
}

#pragma mark - Search controller delegate

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] %@", searchString];
    searchResults = [files filteredArrayUsingPredicate:predicate];
    return YES;
}

@end
