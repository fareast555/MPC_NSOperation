//
//  MPC_CloudKitManager.h
//  MPC_NSOperation
//
//  Created by Michael Critchley on 2017/11/18.
//  Copyright © 2017 Michael Critchley. All rights reserved.

/*****************
This class is the executive manager / interface for other classes that need to
query, save, or delete objects stored on CloudKit. Any class using CloudKit can
create and hold a copy of this and subscribe to callbacks if necessary.

One challenge with cloudkit, or any complex, asynchronous system, is that some operations will produce data,
(downloaded or manipulated data, text, or other objects) and others will be consumer operations that need to work
with these objects. In cases where the failure of one operation in this chain of events
means failure for the entire task, using NSOperationQueue is the best way to manage
these dependencies. But passing information between operations is not entirely straightforward.
This demo is an example of how to chain multiple operations performed with NSOperation subclasses,
passing forward data objects, error objects, and state information via "adapter blocks".

This class is primarily concerned with:
1. Instantiating the operations required for each step of a complex operation.
   The operations are MPC_NSOperation subclasses for operations that
   involve lengthy block operations AND REQUIRE NO APP-SPECIFIC LOGIC,
   and NSBlockOperations to inject app-specific logic either between operations
   or as terminal operations in a chain.

2. Packing operations and outsourcing the dependency chaining to the
   MPC_CloudkitManager+TerminalBlocks category.
 
3. Informing delegate classes of operation results.

** In a more complicated application, you would likely need to split up specific
** app-specific network operations into smaller managers to avoid having this class
** become too messy (which it already is, truth be told).

In this example, look to MPC_Block for an example of an adapter block between operations.
Look to MPC_CloudKitManager+TerminalBlocks to see adapter blocks that are used to
'wrap up' a sequence of chained operations.
*****************/

#import <Foundation/Foundation.h>

@class MPC_CloudKitManager;

//Set an enum to distinguish between public and private CloudKit operations
typedef NS_ENUM(NSInteger, DestinationType) {
    DestinationTypeAllDestinations = 0,
    DestinationTypeMyDestinations,
};

#pragma TODO: REFACTOR INTO SEPARATE CONCERNS
//Create a delegate for listeners to get callbacks when an operation queue ends
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

@end
