//
//  MPC_CloudKitManager.h
//  MPC_NSOperation
//
//  Created by Michael Critchley on 2017/11/18.
//  Copyright © 2017 Michael Critchley. All rights reserved.

//*****************
//This class is the executive manager / interface when other classes need to
//query, save, or delete objects stored on CloudKit.

//One issue of cloudkit, or many systems, is that one operation will a producer of data,
//(saved data, text, or other objects) and a consumer operation that will need to work
//with objects recovered. This demo is an example of how to chain multiple operations,
//passing forward objects via "adapter blocks".
//*****************

#import <Foundation/Foundation.h>

@class MPC_CloudKitManager;

typedef NS_ENUM(NSInteger, DestinationType) {
    DestinationTypeAllDestinations = 0,
    DestinationTypeMyDestinations,
};

@protocol MPC_CloudKitManagerDelegate

- (void)saveDestinationSaved:(BOOL)saved
  destinationPreviouslySaved:(BOOL)previouslySaved
                       error:(NSError *)saveError
         MPC_CloudKitManager:(MPC_CloudKitManager*)manager;
@end


@class Destination;

@interface MPC_CloudKitManager : NSObject

- (void)downloadDestinationsType:(DestinationType)destinationType;
- (void)saveMyDestination:(Destination *)destination;
- (void)deleteMyDestination:(Destination *)destination;

@property (strong, nonatomic) NSArray <Destination *>* destinations;
@property (strong, nonatomic) NSArray <Destination *>* myDestinations;

//Subscribe to delegate for callbacks of save / deletion success
@property (weak, nonatomic) id<MPC_CloudKitManagerDelegate> delegate;

- (void)_informDelegateOfSaveSuccess:(BOOL)success previouslySaved:(BOOL)previouslySaved error:(NSError *)error;
- (void)_netWorkActivityIndicatorVisible:(BOOL)visible;
- (void)_updateDestinationWithRecords:(NSArray *)records
                      destinationType:(DestinationType)destinationType;

@end
