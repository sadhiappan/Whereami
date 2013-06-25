//
//  Separator.m
//  Whereami
//
//  Created by Sivaram Adhiappan on 6/19/13.
//  Copyright (c) 2013 Sivaram Adhiappan. All rights reserved.
//

#import "Separator.h"

@implementation Separator

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();

//    CGContextSetStrokeColorWithColor(context, redColor.CGColor);
//    
//    // Draw them with a 2.0 stroke width so they are a bit more visible.
//    CGContextSetLineWidth(context, 1.0);
//    
//    CGContextMoveToPoint(context, 0,0); //start at this point
//    
//    CGContextAddLineToPoint(context, 20, 20); //draw to this point
//    
//    // and now draw the Path!
//    CGContextStrokePath(context);

    CGContextSetFillColorWithColor(context, [UIColor lightGrayColor].CGColor);
    CGContextFillRect(context, self.bounds);
}

@end
