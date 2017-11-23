//
//  UIApplication+networkActivitySpinner.m
//  MPC_NSOperation
//
//  Created by Michael Critchley on 2017/11/23.
//  Copyright © 2017 Michael Critchley. All rights reserved.
//

#import "UIApplication+networkActivitySpinner.h"

@implementation UIApplication (networkActivitySpinner)

+ (void)startNetworkActivityIndicator
{
    [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:YES];
}
+ (void)stopNetworkActivityIndicator
{
    [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:NO];
}

@end
