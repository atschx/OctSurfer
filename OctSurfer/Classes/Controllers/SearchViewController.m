//
//  SearchViewController.m
//  OctSurfer
//
//  Copyright (c) 2012 yo_waka. All rights reserved.
//

#import "SearchViewController.h"
#import "ApiUrl.h"
#import "CCDateTime.h"
#import "CCHttpClient.h"
#import "RepositoryViewController.h"
#import "RepositoryCell.h"


@interface SearchViewController ()

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, strong) NSArray *repositories;

@end


@implementation SearchViewController

- (id) init
{
    self = [super init];
    if (self) {
        _repositories = @[];
    }
    return self;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    CGRect bounds = [[UIScreen mainScreen] applicationFrame];
    
    // Add searchbar
    UISearchBar *searchBar = [[UISearchBar alloc]
                              initWithFrame: CGRectMake(0.0, 0.0, bounds.size.width, 48.0)];
    searchBar.showsCancelButton = YES;
    searchBar.placeholder = @"Input repository name";
    searchBar.keyboardType = UIKeyboardTypeASCIICapable;
    searchBar.delegate = self;
    [self.view addSubview: searchBar];
    
    // Add tableview
    UITableView *tableView = [[UITableView alloc]
                              initWithFrame: CGRectMake(0.0, 48.0,
                                                        bounds.size.width, bounds.size.height - 48.0)];
    tableView.rowHeight = 60;
    tableView.scrollEnabled = YES;
    tableView.contentInset = UIEdgeInsetsMake(0, 0, 100, 0);
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview: tableView];
    
    // Set self property
    self.title = @"Search";
    self.tableView = tableView;
}


#pragma mark - Table view delegate

- (void) tableView: (UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    // Pass the selected object to the new view controller.
    // [self.navigationController pushViewController:detailViewController animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    RepositoryViewController *repositoryView = [[RepositoryViewController alloc] init];
    NSDictionary *data = (self.repositories)[indexPath.row];
    repositoryView.name = data[@"name"];
    repositoryView.owner = data[@"owner"];
    [self.navigationController pushViewController: repositoryView animated: YES];
}

- (void) viewWillAppear: (BOOL)animated
{
	[super viewWillAppear: animated];
    
    NSIndexPath *selection = [self.tableView indexPathForSelectedRow];
	if (selection) {
		[self.tableView deselectRowAtIndexPath: selection animated: YES];
    }
	[self.tableView reloadData];
}

- (void) viewDidAppear: (BOOL)animated
{
    [super viewDidAppear:animated];
    
	//	The scrollbars won't flash unless the tableview is long enough.
	[self.tableView flashScrollIndicators];
}


#pragma mark - Table view data source

- (NSInteger) numberOfSectionsInTableView: (UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger) tableView: (UITableView *)tableView numberOfRowsInSection: (NSInteger)section
{
    // Return the number of rows in the section.
    return [self.repositories count];
}

- (UITableViewCell *) tableView: (UITableView *)tableView cellForRowAtIndexPath: (NSIndexPath *)indexPath
{
    RepositoryCell *cell = [tableView dequeueReusableCellWithIdentifier: @"RepositoryCell"];
    if (!cell) {
        // Configure the cell...
        cell = [[RepositoryCell alloc]
                initWithStyle: UITableViewCellStyleDefault reuseIdentifier: @"RepositoryCell"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    [self updateCell: cell atIndexPath: indexPath];
    return cell;
}

- (void) updateCell: (UITableViewCell *)cell atIndexPath: (NSIndexPath *)indexPath
{
    RepositoryCell *repositoryCell = (RepositoryCell *)cell;
    NSDictionary *data = nil;
    if (indexPath.row < [self.repositories count]) {
        data = (self.repositories)[indexPath.row];
    }
    
    NSString *name = [NSString stringWithFormat:@"%@ / %@", data[@"owner"], data[@"name"]];
    NSString *date = [CCDateTime prettyPrint: [CCDateTime dateFromString: data[@"pushed_at"]]];
    
    repositoryCell.nameLabel.text = name;
    repositoryCell.descriptionLabel.text = data[@"description"];
    repositoryCell.starsLabel.text = [NSString stringWithFormat: @"%@ stars", data[@"followers"]];
    repositoryCell.lastActivityLabel.text = [NSString stringWithFormat: @"last activity %@", date];
}


#pragma mark - Search bar delegate

// Tap search
- (void) searchBarSearchButtonClicked: (UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    
    NSString *value = searchBar.text;
    if ([value length] != 0) {
        value = [value stringByReplacingOccurrencesOfString: @"　" withString: @" "];
        value = [value stringByReplacingOccurrencesOfString: @" " withString: @"+"];
        [self doSearch: value];
    }
}

// Tap cancel
- (void) searchBarCancelButtonClicked: (UISearchBar *) searchBar
{
    [searchBar resignFirstResponder];
}

// Go search
- (void) doSearch: (NSString *)keyword
{
    NSString *url = [ApiUrl searchRepository: keyword];
    CCHttpClient *client = [CCHttpClient clientWithUrl: url];
    [client getJsonWithDelegate: self success: @selector(handleDoSearchSuccess:) failure: nil];
}

- (void) handleDoSearchSuccess: (NSDictionary *)json
{
    NSArray *repositories = json[@"repositories"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"fork == 0"];
    self.repositories = [repositories filteredArrayUsingPredicate: predicate];
    [self.tableView reloadData];
}

@end
