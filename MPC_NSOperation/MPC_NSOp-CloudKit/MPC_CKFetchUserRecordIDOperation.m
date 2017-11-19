//
//  MPC_CKFetchUserRecordIDOperation.m
//  ElectLiberalUSA
//
//  Created by Michael Critchley on 2017/11/14.
//  Copyright © 2017 Michael Critchley. All rights reserved.
//

#import "MPC_CKFetchUserRecordIDOperation.h"

@implementation MPC_CKFetchUserRecordIDOperation

- (void) start
{
    //1. Call to super to check if previous or this current operation have been cancelled
    if (![super initializeExecution])
        return;
    
    //2. Call to CKContainer to fetch the unique, cloudKit "User" record
    [[CKContainer defaultContainer] fetchUserRecordIDWithCompletionHandler:^(CKRecordID *recordID, NSError *error){
        
        if (error || !recordID) {
            //3. If error, set an error to be passed up the chain of command
            [self exposeError: error];
            
            //4. Set this operation as cancelled to finish early
            [self cancel];
        }
        else {
            //5. Create a CKReference as a convenience step
            CKRecord *record = [[CKRecord alloc]initWithRecordType:@"Users" recordID:recordID];
            CKReference *toCKUser = [[CKReference alloc]initWithRecord:record action:CKReferenceActionNone];
            
            //6. Save variables to public facing properties
            self.recordID = recordID;
            self.referenceToUniqueUserOfCKReferenceTypeUser = toCKUser;
            
        }
        //7. Call to super to mark operation as finished
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
