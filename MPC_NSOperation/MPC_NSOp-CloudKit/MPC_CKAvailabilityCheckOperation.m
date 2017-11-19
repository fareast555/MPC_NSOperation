//
//  CKAvailabilityCheckBlockOperation.m
//  ElectLiberalUSA
//
//  Created by Michael Critchley on 2017/11/14.
//  Copyright © 2017 Michael Critchley. All rights reserved.
//

#import "MPC_CKAvailabilityCheckOperation.h"

@implementation MPC_CKAvailabilityCheckOperation

- (void) start
{
    //1. Call to super to check if previous or this current operation have been cancelled
    if (![super initializeExecution])
        return;
    
    //2. Call to CKContainer to check account status
    [[CKContainer defaultContainer] accountStatusWithCompletionHandler:^(CKAccountStatus accountStatus, NSError *error) {
        
        if (error) {
            //3. If error, set an error to be passed up the chain of command
            [self exposeError:error];
            
            //4. Set this operation as cancelled to finish early
            [self cancel];
        }
        //5. Else, set the public-facing CKAccountStatus property
        else
            self.status = accountStatus;
        
        //6. Call to super to mark operation as finished
        [super completeOperation];
            
    }];
    
}

- (void)exposeError:(NSError *)error
{
    self.error = error;
}

- (void)exposeErrorWithMessage:(NSString *)message //Implemented by super
{
    
}



@end
