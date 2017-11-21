//
//  CloudKitSetUpManager.h
//  MPC_NSOperation
//
//  Created by Michael Critchley on 2017/11/21.
//  Copyright © 2017 Michael Critchley. All rights reserved.
//

#import <Foundation/Foundation.h>
@class CloudKitSetUpManager;

@protocol CloudKitSetUpManagerDelegate

- (void)databaseInitializationDidSucceeedInMPC_CloudKitManager:(CloudKitSetUpManager *)manager;
- (void)databaseInitializationDidFailWithError:(NSError *)error
                         CloudKitSetUpManager:(CloudKitSetUpManager *)manager;

@end

@interface CloudKitSetUpManager : NSOperation

- (void)initializeDestinations;

@property (weak, nonatomic) id<CloudKitSetUpManagerDelegate> delegate;

@end
