//
//  LocationsViewController.m
//  Whereami
//
//  Created by Sivaram Adhiappan on 5/13/13.
//  Copyright (c) 2013 Sivaram Adhiappan. All rights reserved.
//

#import "LocationsViewController.h"
#import "Atlas.h"
#import "Separator.h"

@interface LocationsViewController ()
@property (nonatomic, weak) IBOutlet UITableView *atlasLocations;
@property (nonatomic, weak) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) UIToolbar *toolBar;
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
    
    // Initialize the toolbar and set style
    self.toolBar = [[UIToolbar alloc] init];
    self.toolBar.barStyle = UIBarStyleDefault;
    [self.toolBar sizeToFit];
    
    // Set Toolbar position and size
    self.toolBar.frame = CGRectMake(0, 430, 320, 50);
    
    // Initialize toolbar items
    // Empty button to add space and center align options
    UIBarButtonItem *flexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                              target:nil
                                                                              action:nil];
    // Initialize an info button and add to the tool bar item
    UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
    [infoButton addTarget:self action:@selector(showOptions:) forControlEvents:UIControlEventTouchUpInside];

    // Initialize option info item with custom view and info button
    UIBarButtonItem *infoItem = [[UIBarButtonItem alloc] initWithCustomView:infoButton];
    
    // Add button items into array
    NSArray *items = [NSArray arrayWithObjects:flexItem, infoItem, flexItem, nil];
    
    // Add button item array to the toolbar
    [self.toolBar setItems:items animated:NO];

    // Add the toolbar to the view
    [self.view addSubview:self.toolBar];
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

- (void)showOptions:(id)sender
{
    CGRect screenRect = [[self view] bounds];
    
    // Initialize popup view to show the options
    UIView *popupView = [[UIView alloc] initWithFrame:CGRectMake(0, 300, screenRect.size.width, screenRect.size.height / 2)];
    popupView.backgroundColor = [UIColor whiteColor];
    
    // Initialize the map type segmented control
    NSArray *mapTypes = [NSArray arrayWithObjects:@"Standard", @"Satellite", @"Hybrid", nil];
    UISegmentedControl *mapType = [[UISegmentedControl alloc] initWithItems:mapTypes];
    mapType.frame = CGRectMake((screenRect.size.width / 2) - 125, 10, 250, 35);
    mapType.selectedSegmentIndex = 0;
    [mapType addTarget:self action:@selector(switchMapType:) forControlEvents:UIControlEventValueChanged];
    [popupView addSubview:mapType];
    
    // Initialize lineView
//    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 57.5, self.view.bounds.size.width, 1)];
//    lineView.backgroundColor = [UIColor lightGrayColor];
//    [popupView addSubview:lineView];
    Separator *line1 = [[Separator alloc] init];
    CGRect frame = line1.frame;
    frame.origin.x = 0;
    frame.origin.y = 57.5;
    line1.frame = frame;
    [popupView addSubview:line1];

    // Initialize the map view to open the locations (Google/Apple Maps)
    NSArray *mapTargets = [NSArray arrayWithObjects:@"Apple Maps", @"Google Maps", nil];
    UISegmentedControl *mapTarget = [[UISegmentedControl alloc] initWithItems:mapTargets];
    mapTarget.frame = CGRectMake((screenRect.size.width / 2) - 100, 70, 200, 35);
    mapTarget.selectedSegmentIndex = 0;
    [mapTarget addTarget:self action:@selector(switchMapTarget:) forControlEvents:UIControlEventValueChanged];
    [popupView addSubview:mapTarget];
    
    // Add sub view to the main view
    [self.view addSubview:popupView];
    
}

- (IBAction)switchMapType:(id)sender
{
    UISegmentedControl *switchMapType = (UISegmentedControl *) sender;
    NSInteger selectedSegment = switchMapType.selectedSegmentIndex;
    
    // Switch the map types based on the switch control
    if (selectedSegment == 0) {
        
        
    } else if (selectedSegment == 1) {
        
    } else if (selectedSegment == 2) {
        
    } else {
        
    }
}

- (IBAction)switchMapTarget:(id)sender
{
    
}


@end
