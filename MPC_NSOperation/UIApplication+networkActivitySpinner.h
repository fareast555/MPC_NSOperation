//
//  UIApplication+networkActivitySpinner.h
//  MPC_NSOperation
//
//  Created by Michael Critchley on 2017/11/23.
//  Copyright © 2017 Michael Critchley. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIApplication (networkActivitySpinner)

+ (void)startNetworkActivityIndicator;
+ (void)stopNetworkActivityIndicator;

@end
