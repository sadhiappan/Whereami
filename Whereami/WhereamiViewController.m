//
//  WhereamiViewController.m
//  Whereami
//
//  Created by Sivaram Adhiappan on 5/12/13.
//  Copyright (c) 2013 Sivaram Adhiappan. All rights reserved.
//

#import "WhereamiViewController.h"
#import <MapKit/MapKit.h>
#import "Location.h"
#import "Atlas.h"

@interface WhereamiViewController ()
@property (nonatomic, weak) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) Atlas *atlas;
@end

@implementation WhereamiViewController

- (Atlas *)atlas
{
    if (!_atlas) _atlas = [[Atlas alloc] init];
    return _atlas;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Where Am I";
    
    // Setup Map
    [self.mapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
    self.mapView.delegate = self;
    self.mapView.mapType = MKMapTypeSatellite;
    
    NSMutableArray *locations = [self.atlas getLocations];
    for (id loc in locations) {
        [self.mapView addAnnotation:loc];
    }
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    NSLog(@"(%f, %f)", userLocation.location.coordinate.latitude, userLocation.location.coordinate.longitude);
}

- (IBAction)saveLocation:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Save Location"
                                                    message:@"Enter location name"
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Save", nil];
    
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
}

- (void)performSaveLocation:(CLLocationCoordinate2D)coordinate
                   withName:(NSString *)name
{    
    Location *currentLocation = [[Location alloc] init];
    currentLocation.coordinate = coordinate;
    currentLocation.title = name;
    
    // Save this location to our atlas
    [self.atlas addLocation:currentLocation];
    
    // Add this location to our map as an anotation
    [self.mapView addAnnotation:currentLocation];
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        CLLocationCoordinate2D userLocation = self.mapView.userLocation.coordinate;
        NSString *locationName = [alertView textFieldAtIndex:0].text;
        [self performSaveLocation:userLocation withName:locationName];
    }
}

@end
