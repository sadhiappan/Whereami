//
//  Location.m
//  Whereami
//
//  Created by Sivaram Adhiappan on 5/12/13.
//  Copyright (c) 2013 Sivaram Adhiappan. All rights reserved.
//

#import "Location.h"

@implementation Location

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeDouble:self.coordinate.latitude forKey:@"locLatitude"];
    [encoder encodeDouble:self.coordinate.longitude forKey:@"locLongitude"];
    [encoder encodeObject:self.title forKey:@"title"];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if (self) {
        self.coordinate = CLLocationCoordinate2DMake([decoder decodeDoubleForKey:@"locLatitude"],
                                                     [decoder decodeDoubleForKey:@"locLongitude"]);
        self.title = [decoder decodeObjectForKey:@"title"];
    }    return self;
}


@end
