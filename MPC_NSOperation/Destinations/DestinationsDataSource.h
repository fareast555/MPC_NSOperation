//
//  DestinationsDataSource.h
//  MPC_NSOperation
//
//  Created by Michael Critchley on 2017/11/19.
//  Copyright © 2017 Michael Critchley. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;
@class Destination;

@interface DestinationsDataSource : NSObject<UITableViewDataSource>

- (instancetype)initWithDataArray:(NSArray <Destination *>*)dataArray
                         editable:(BOOL)editable;

- (void)cellWasTappedWithDestinationUUID:(NSString *)UUID bounds:(CGRect)bounds sizeShouldIncrease:(BOOL)increase;

@property (strong, nonatomic) NSArray <Destination *>* destinations;

@end
