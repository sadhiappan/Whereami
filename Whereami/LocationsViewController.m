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
#import "Settings.h"

@interface LocationsViewController ()
@property (nonatomic, weak) IBOutlet UITableView *atlasLocations;
@property (nonatomic, weak) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) UIToolbar *toolBar;
@property (nonatomic, strong) Atlas *atlas;
@property (nonatomic, strong) Settings *settings;
@property (nonatomic, strong) UIView *popupView;
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

- (Settings *)settings
{
    if (!_settings) _settings = [[Settings alloc] init];
    return _settings;
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
 
    // application frame size
    CGRect appBound = [[UIScreen mainScreen] bounds];
    
    // Link the delegates to IBOutlets
    self.searchBar.delegate = self;
    self.atlasLocations.delegate = self;
    
    // Set the position for the tableview
    CGRect tableViewFrame = self.atlasLocations.frame;
    tableViewFrame.size.width = appBound.size.width;
    tableViewFrame.size.height = appBound.size.height - 50;
    self.atlasLocations.frame = tableViewFrame;
    
    // Get the atlas points into a data source
    atlasData = [self.atlas getLocations];
    
    // Duplicate into a mutablearray to be used in UITableView
    filteredAtlasData = [[NSMutableArray alloc] initWithArray:atlasData];
    
    // Initialize the toolbar and set style
    self.toolBar = [[UIToolbar alloc] init];
    self.toolBar.barStyle = UIBarStyleDefault;
    [self.toolBar sizeToFit];
    
    // Set Toolbar position and size
    self.toolBar.frame = CGRectMake(0, appBound.size.height - 50, appBound.size.width, 50);
    
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
    
    // Setup the options popup
    [self setupOptions];
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
    NSString *title = [[filteredAtlasData objectAtIndex:indexPath.row] title];
    NSString *mapTarget = [self.settings mapTarget];
    
    if([mapTarget isEqualToString: @"APPLE"]) {
        Class mapItemClass = [MKMapItem class];
        if (mapItemClass && [mapItemClass respondsToSelector:@selector(openMapsWithItems:launchOptions:)])
        {
            // Create an MKMapItem to pass to the Maps app
            MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:coordinate
                                                       addressDictionary:nil];
            MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
            [mapItem setName:title];
            
            // Pass the map item to the Maps app
            [mapItem openInMapsWithLaunchOptions:nil];
        }
    } else if ([mapTarget isEqualToString:@"GOOGLE"]) {
        NSURL *targetUrl = [NSURL URLWithString:
                            [NSString stringWithFormat:@"comgooglemaps://?center=%f,%f&views=streetview,traffic&zoom=14", coordinate.latitude, coordinate.longitude]];
        if (![[UIApplication sharedApplication] canOpenURL:targetUrl]) {
            NSLog(@"Google Maps app is not installed");
            //left as an exercise for the reader: open the Google Maps mobile website instead!
        }
        [[UIApplication sharedApplication] openURL:targetUrl];
    }
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

- (void)setupOptions
{
    CGRect screenRect = [[self view] bounds];
    
    // Initialize popup view to show the options
    _popupView = [[UIView alloc] initWithFrame:CGRectMake(0, screenRect.size.height, screenRect.size.width, 180)];
    UIColor * lightGrayColor = [UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:1.0];
    _popupView.backgroundColor = lightGrayColor;
    
    // Initialize the map type segmented control
    NSArray *mapTypes = [NSArray arrayWithObjects:@"Standard", @"Satellite", @"Hybrid", nil];
    UISegmentedControl *mapType = [[UISegmentedControl alloc] initWithItems:mapTypes];
    mapType.frame = CGRectMake((screenRect.size.width / 2) - 125, 15, 250, 35);

    // Get maptype from settings
    MKMapType mType = [self.settings mapType];
    if(mType == MKMapTypeStandard) // MapType standard
        mapType.selectedSegmentIndex = 0;
    else if(mType == MKMapTypeSatellite) // MapType satellite
        mapType.selectedSegmentIndex = 1;
    else if (mType == MKMapTypeHybrid) // MapType Hybrid
        mapType.selectedSegmentIndex = 2;
    
    [mapType addTarget:self action:@selector(switchMapType:) forControlEvents:UIControlEventValueChanged];
    [_popupView addSubview:mapType];
    
    CGRect frame;
    frame.origin.x = 0;
    frame.origin.y = 62.5;
    frame.size.width = screenRect.size.width;
    frame.size.height = 1;
    
    Separator *line1 = [[Separator alloc] initWithFrame:frame];
    [_popupView addSubview:line1];

    // Initialize the map view to open the locations (Google/Apple Maps)
    NSArray *mapTargets = [NSArray arrayWithObjects:@"Apple Maps", @"Google Maps", nil];
    UISegmentedControl *mapTarget = [[UISegmentedControl alloc] initWithItems:mapTargets];
    mapTarget.frame = CGRectMake((screenRect.size.width / 2) - 100, 75, 200, 35);

    // Get mapTarget from the settings
    NSString *mTarget = [self.settings mapTarget];
    if([mTarget isEqualToString:@"APPLE"])
        mapTarget.selectedSegmentIndex = 0;
    else if([mTarget isEqualToString:@"GOOGLE"])
        mapTarget.selectedSegmentIndex = 1;
             
    [mapTarget addTarget:self action:@selector(switchMapTarget:) forControlEvents:UIControlEventValueChanged];
    [_popupView addSubview:mapTarget];
    
    frame.origin.y = 122.5;
    Separator *line2 = [[Separator alloc] initWithFrame:frame];
    [_popupView addSubview:line2];
    
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [cancelBtn addTarget:self action:@selector(hideOptions:) forControlEvents:UIControlEventTouchDown];
    [cancelBtn setTitle:@"Cancel" forState:UIControlStateNormal];
    cancelBtn.frame = CGRectMake(0, 135, screenRect.size.width, 35);
    [_popupView addSubview:cancelBtn];
    
    // Add sub view to the main view
    [self.view addSubview:_popupView];
    
}

- (IBAction)switchMapType:(id)sender
{
    UISegmentedControl *switchMapType = (UISegmentedControl *) sender;
    NSInteger selectedSegment = switchMapType.selectedSegmentIndex;
    
    // Switch the map types based on the switch control
    if (selectedSegment == 0) {
        [self.settings setMapType:MKMapTypeStandard];
    } else if (selectedSegment == 1) {
        [self.settings setMapType:MKMapTypeSatellite];
    } else if (selectedSegment == 2) {
        [self.settings setMapType:MKMapTypeHybrid];
    } else {
        [self.settings setMapType:MKMapTypeStandard];
    }
}

- (IBAction)switchMapTarget:(id)sender
{
    UISegmentedControl *switchMapTarget = (UISegmentedControl *) sender;
    NSInteger selectedSegment = switchMapTarget.selectedSegmentIndex;
    
    if(selectedSegment == 0) {
        // Set map target as apple maps
        [self.settings setMapTarget:@"APPLE"];
    } else if(selectedSegment == 1) {
        // Set map target as google maps
        [self.settings setMapTarget:@"GOOGLE"];

    }
}

- (void)showOptions:(id)sender
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGRect popupRect = [_popupView bounds];
    
    // Animation to slide options from the bottom
    [sender setEnabled:NO];
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _popupView.frame = CGRectMake(0, screenRect.size.height - popupRect.size.height, screenRect.size.width, popupRect.size.height);
    }completion:^(BOOL done){
        //some completion handler
        [sender setEnabled:YES];
    }];
}

- (void)hideOptions:(id)sender
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGRect popupRect = [_popupView bounds];
    
    // Animation to slide options to hide to the bottom
    [sender setEnabled:NO];
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _popupView.frame = CGRectMake(0, screenRect.size.height, screenRect.size.width, popupRect.size.height);
    }completion:^(BOOL done){
        //some completion handler
        [sender setEnabled:YES];
    }];
}


@end
