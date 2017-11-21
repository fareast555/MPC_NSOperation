//
//  MPC_CloudKitManager.h
//  MPC_NSOperation
//
//  Created by Michael Critchley on 2017/11/18.
//  Copyright © 2017 Michael Critchley. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MPC_CloudKitManager;

typedef NS_ENUM(NSInteger, DLType) {
    DLTypeAllDestinations = 0,
    DLTypeMyDestinations,
};

@protocol MPC_CloudKitManagerDelegate
@optional
- (void)databaseInitializationDidSucceeedInMPC_CloudKitManager:(MPC_CloudKitManager *)manager;
- (void)databaseInitializationDidFailWithError:(NSError *)error
                         inMPC_CloudKitManager:(MPC_CloudKitManager *)manager;

- (void)saveDestinationSaved:(BOOL)saved destinationPreviouslySaved:(BOOL)previouslySaved error:(NSError *)saveError MPC_CloudKitManager:(MPC_CloudKitManager*)manager;
@end

extern NSString * const kDatabaseInitialized;
extern NSString * const kFirstDownloadOfDestinationsComplete;

@class Destination;

@interface MPC_CloudKitManager : NSObject

- (void)downloadDestinationsType:(DLType)destinationType;

- (void)saveMyDestination:(Destination *)destination;

- (void)deleteMyDestination:(Destination *)destination;

- (void)initializeDestinations;

@property (strong, nonatomic) NSArray <Destination *>* destinations;
@property (strong, nonatomic) NSArray <Destination *>* MyDestinations;
@property (weak, nonatomic) id<MPC_CloudKitManagerDelegate> delegate;

@end
