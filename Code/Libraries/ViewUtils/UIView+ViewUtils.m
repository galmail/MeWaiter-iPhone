//
//  UIView+ViewUtils.m
//  bootstrap-ios
//
//  Created by Marcos Pinazo on 3/7/13.
//  Copyright (c) 2013 [WE ARE] DEVELAPPERS. All rights reserved.
//

#import "UIView+ViewUtils.h"

@implementation UIView (ViewUtils)

- (void)removeAllSubviews
{
    for (UIView *subview in self.subviews) {
        [subview removeFromSuperview];
    }
}

@end
