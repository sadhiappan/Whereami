//
//  LocationsViewController.m
//  Whereami
//
//  Created by Sivaram Adhiappan on 5/13/13.
//  Copyright (c) 2013 Sivaram Adhiappan. All rights reserved.
//

#import "LocationsViewController.h"
#import "Atlas.h"

@interface LocationsViewController ()
@property (nonatomic, weak) IBOutlet UITableView *atlasLocations;
@property (nonatomic, weak) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) Atlas *atlas;
@end

@implementation LocationsViewController
{
    // Local array to store the atlas points
    NSArray *atlasData;
    NSMutableArray *filteredAtlasData;
}

- (Atlas *)atlas
{
    if (!_atlas) _atlas = [[Atlas alloc] init];
    return _atlas;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Locations";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    
    // Link the delegates to IBOutlets
    self.searchBar.delegate = self;
    self.atlasLocations.delegate = self;
    
    // Get the atlas points into a data source
    atlasData = [self.atlas getLocations];
    
    // Duplicate into a mutablearray to be used in UITableView
    filteredAtlasData = [[NSMutableArray alloc] initWithArray:atlasData];
}

- (void)viewDidAppear:(BOOL)animated
{
    // Reload data from NSDefaults to capture any changes
    atlasData = [self.atlas getLocations];
    
    // Duplicate into a mutablearray to be used in UITableView
    filteredAtlasData = [[NSMutableArray alloc] initWithArray:atlasData];
    
    // Reload UITableView
    [self.atlasLocations reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [filteredAtlasData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *listIdentifier = @"Locations";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:listIdentifier];
    
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:listIdentifier];
    }
    
    cell.textLabel.text = [[filteredAtlasData objectAtIndex:indexPath.row] title];
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CLLocationCoordinate2D coordinate = [[filteredAtlasData objectAtIndex:indexPath.row] coordinate];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:
                                                [NSString stringWithFormat:@"comgooglemaps://?center=%f,%f&zoom=14&views=traffic", coordinate.latitude, coordinate.longitude]]];
}


- (NSArray *)filterSearchResults:(NSString *)searchText
{
    // Check if searchText is empty
    if ([searchText length] > 0) {
        // Filter the location array using searchText predicate
        NSPredicate *resultPredicate = [NSPredicate
                                        predicateWithFormat:@"title contains[cd] %@",
                                        searchText];
        // Load results into NSArray results with predicate filter on master data source
        NSArray *results = [atlasData filteredArrayUsingPredicate:resultPredicate];
        
        return results;
    } else {
        // If the search text is empty then return original data source
        return  atlasData;
    }
    
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    // Reload filteredAtlasData with filtered results
    filteredAtlasData = [[NSMutableArray alloc] initWithArray:[self filterSearchResults:searchText]];
    [searchBar setShowsCancelButton:YES animated:NO];
    
    self.atlasLocations.allowsSelection = YES;
    self.atlasLocations.scrollEnabled = YES;
    
    [self.atlasLocations reloadData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    searchBar.text = @"";
    [searchBar setShowsCancelButton:NO animated:NO];
    [searchBar resignFirstResponder];
    self.atlasLocations.allowsSelection = YES;
    self.atlasLocations.scrollEnabled = YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:NO animated:NO];
    [searchBar resignFirstResponder];
}

@end
