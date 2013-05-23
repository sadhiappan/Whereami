//
//  Location.h
//  Whereami
//
//  Created by Sivaram Adhiappan on 5/12/13.
//  Copyright (c) 2013 Sivaram Adhiappan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface Location : NSObject <MKAnnotation, NSCoding>
@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic, strong) NSString *title;
@end
