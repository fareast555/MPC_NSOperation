//
//  MPC_CloudKitManager.h
//  MPC_NSOperation
//
//  Created by Michael Critchley on 2017/11/18.
//  Copyright © 2017 Michael Critchley. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, DLType) {
    DLTypeAllDestinations = 0,
    DLTypeMyDestinations,
};


@class Destination;

@interface MPC_CloudKitManager : NSObject

- (void)downloadDestinationsType:(DLType)destinationType;

- (void)saveMyDestination:(Destination *)destination;

+ (void)deleteMyDestination:(Destination *)destination;

- (void)initializeDestinations;

@property (strong, nonatomic) NSArray <Destination *>* destinations;

@property (strong, nonatomic) NSArray <Destination *>* MyDestinations;

@end
