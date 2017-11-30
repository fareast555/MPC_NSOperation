//
//  MPC_CKDeleteRecordOperation.m
//  MPC_NSOperation
//
//  Created by Michael Critchley on 2017/11/21.
//  Copyright © 2017 Michael Critchley. All rights reserved.


#import "MPC_CKDeleteRecordOperation.h"

@interface MPC_CKDeleteRecordOperation()
@property (strong, atomic) CKDatabase *CKDatabase;
@end

@implementation MPC_CKDeleteRecordOperation

- (instancetype)initWithRecordID:(CKRecordID *)recordID
             usesPrivateDatabase:(BOOL)usesPrivateDatabase  //NO = PublicDB YES = PrivateDB
{
    if ((self = [[self class] MPC_Operation])) {
        self.recordID = recordID;
        self.CKDatabase = usesPrivateDatabase ?
        [[CKContainer defaultContainer]privateCloudDatabase] :
        [[CKContainer defaultContainer]publicCloudDatabase];
    }
    return self;
}

- (void) start
{
    //1. Call to super to check if previous or this current operation have been cancelled
    if (![super initializeExecution])
        return;
    
    //2. Cancel if CKRecordID has not been set
    if (!self.recordID) {
        [self exposeErrorWithMessage:@"CKRecordID not available at time of delete operation. See error messages for more."];
        [self cancel];
        [super completeOperation];
        return;
    }
    
     NSLog(@"\n\nMPC_CKDeleteRecordOperation will now try to delete the destination.");
    
    //3. Call to the CKContainer to delete the individual record
    [self.CKDatabase deleteRecordWithID:self.recordID
                      completionHandler:^(CKRecordID *deletedRecordID, NSError *deletionError)
    {
        if (deletionError) {
            //4. If error, set an error to be passed up the chain of command
            [self exposeError: deletionError];
            
            //5. Set this operation as cancelled to finish early
            [self cancel];
            
            //6. Else, set the public-facing returned (deleted) CKRecordID property
        } else
            self.deletedCKRecordID = deletedRecordID;
        
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
