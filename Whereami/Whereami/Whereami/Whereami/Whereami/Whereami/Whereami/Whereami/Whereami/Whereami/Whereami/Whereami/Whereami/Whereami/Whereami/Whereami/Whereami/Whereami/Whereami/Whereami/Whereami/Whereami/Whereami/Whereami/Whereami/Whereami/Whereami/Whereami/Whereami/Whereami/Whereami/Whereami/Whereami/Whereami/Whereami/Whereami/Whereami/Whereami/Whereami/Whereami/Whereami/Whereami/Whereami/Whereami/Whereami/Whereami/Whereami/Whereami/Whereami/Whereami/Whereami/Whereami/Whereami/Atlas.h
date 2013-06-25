//
//  Atlas.h
//  Whereami
//
//  Created by Sivaram Adhiappan on 5/13/13.
//  Copyright (c) 2013 Sivaram Adhiappan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Location.h"

@interface Atlas : NSObject
- (NSMutableArray *)getLocations;
- (void)addLocation:(Location *)location;
+ (Atlas *)sharedStore; // Used to make the class singleton
@end
