//
//  VerticalHeaderView.m
//  packedlayoutdemo
//
//  Created by Guy Umbright on 8/21/15.
//  Copyright (c) 2015 Umbright Consulting, Inc. All rights reserved.
//

#import "VerticalHeaderView.h"

@implementation VerticalHeaderView

- (id) initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void) awakeFromNib
{
    self.backgroundColor = [UIColor whiteColor];
}
@end
