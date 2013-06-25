//
//  Settings.m
//  Whereami
//
//  Created by Sivaram Adhiappan on 6/20/13.
//  Copyright (c) 2013 Sivaram Adhiappan. All rights reserved.
//

#import "Settings.h"

@implementation Settings

- (id)init
{
    self = [super init];
    
    if (self) {
        
        // Get Map Type as object as it is stored as NSNumber Object in NSUserDefault
        NSNumber *storedMapTypeObject = [[NSUserDefaults standardUserDefaults] objectForKey:@"mapType"];

        // Get unsigned value from NSNumber
        MKMapType storedMapType = [storedMapTypeObject unsignedIntValue];
        
        // Get Map Target from NSUserDefaults
        NSString *storedMapTarget = [[NSUserDefaults standardUserDefaults] objectForKey:@"mapTarget"];
        
        // Set initial value for map type
        if(storedMapType) {
            [self setMapType:storedMapType];
        } else {
            // Set default map type as STANDARD
            [self setMapType:MKMapTypeStandard];
        }
        
        // Set initial value for map target
        if(storedMapTarget) {
            [self setMapTarget:storedMapTarget];
        } else {
            // Set default map target type as APPLE MAPS
            [self setMapTarget:@"APPLE"];
        }
    }
    
    return  self;
}

+ (Settings *)sharedSettings
{
    static Settings *sharedSettings = nil;
    
    if(!sharedSettings) {
        sharedSettings = [[super allocWithZone:nil] init];
    }
    
    return sharedSettings;
}

+ (id)allocWithZone:(struct _NSZone *)zone
{
    // This overrides the init and returns the already created sharedSettings
    return [self sharedSettings];
}

- (void)setMapType:(MKMapType)mapType
{
    // Store the Map Type as NS Number and decode it on return
    [[NSUserDefaults standardUserDefaults]  setObject:[NSNumber numberWithUnsignedInt:mapType] forKey:@"mapType"];
    _mapType = mapType;
}

- (void)setMapTarget:(NSString *)mapTarget
{
    // Store map target in NS User Defaults
    [[NSUserDefaults standardUserDefaults]  setObject:mapTarget forKey:@"mapTarget"];
    _mapTarget = mapTarget;
}

@end
