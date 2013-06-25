//
//  Atlas.m
//  Whereami
//
//  Created by Sivaram Adhiappan on 5/13/13.
//  Copyright (c) 2013 Sivaram Adhiappan. All rights reserved.
//

#import "Atlas.h"

@interface Atlas()
@property (nonatomic, strong) NSMutableArray *atlasPoints;
@end

@implementation Atlas

- (id)init
{
    self = [super init];
    
    if (self) {
        // Grab the atlas data from NSUserDefaults.  If there is no AtlastData create an empty NSMutableArray.
        NSData *archivedAtlasData = [[NSUserDefaults standardUserDefaults] objectForKey:@"atlasData"];
        if (archivedAtlasData) {
             NSArray *immutableAtlasData = [NSKeyedUnarchiver unarchiveObjectWithData:archivedAtlasData];
            _atlasPoints = [NSMutableArray arrayWithArray:immutableAtlasData];
        } else {
            _atlasPoints = [[NSMutableArray alloc] init];
        }
    }
    return self;
}

+ (Atlas *)sharedStore
{
    static Atlas *sharedStore = nil;
    if(!sharedStore) {
        sharedStore = [[super allocWithZone:nil] init];
    }
    
    return sharedStore;
}

+ (id)allocWithZone:(NSZone *)zone
{
    // Bypass init from creating new instance of Atlas
    return [self sharedStore];
}

- (NSMutableArray *)getLocations
{
    return self.atlasPoints;
}

- (void)addLocation:(Location *) location
{
    
    // Add the point to our NSMutableArray and replace the atlasData in NSUserDefaults with our updated array
    [self.atlasPoints addObject:location];
    NSArray *immutableAtlasData = [NSArray arrayWithArray:self.atlasPoints];
    NSData *archivedAtlasData = [NSKeyedArchiver archivedDataWithRootObject:immutableAtlasData];
    [[NSUserDefaults standardUserDefaults]  setObject:archivedAtlasData forKey:@"atlasData"];
}

@end
