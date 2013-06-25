//
//  Settings.h
//  Whereami
//
//  Created by Sivaram Adhiappan on 6/20/13.
//  Copyright (c) 2013 Sivaram Adhiappan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface Settings : NSObject
@property (nonatomic) MKMapType mapType;
@property (nonatomic, copy) NSString *mapTarget;
+ (Settings *)sharedSettings; // Used to make the singleton
@end
