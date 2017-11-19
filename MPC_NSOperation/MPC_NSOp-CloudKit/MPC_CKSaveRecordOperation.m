//
//  MPC_CKSaveRecordOperation.m
//  ElectLiberalUSA
//
//  Created by Michael Critchley on 2017/11/15.
//  Copyright © 2017 Michael Critchley. All rights reserved.
//

#import "MPC_CKSaveRecordOperation.h"

@interface MPC_CKSaveRecordOperation ()
@property (strong, atomic) CKDatabase *CKDatabase;
@end

@implementation MPC_CKSaveRecordOperation

- (instancetype)initWithRecord:(CKRecord *)record
           usesPrivateDatabase:(BOOL)usesPrivateDatabase  //NO = PublicDB YES = PrivateDB
{
    if ((self = [[self class] MPC_Operation])) {
        self.record = record;
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
    
    //2. Cancel if CKRecord or RecordType has not been sent
    if (!self.record) {
        [self exposeErrorWithMessage:@"CKRecord not available at time of save. See error messages for more."];
        [self cancel];
        [super completeOperation];
        return;
    }

    //3. Call to the CKContainer to save the individual record
    [self.CKDatabase saveRecord:self.record
              completionHandler:^(CKRecord *record, NSError *error)
    {
        if (error) {

            //4. If error, set an error to be passed up the chain of command
            [self exposeError: error];
            
            //5. Set this operation as cancelled to finish early
            [self cancel];
            
            //6. Else, set the public-facing downloaded CKRecord property
        } else {
            self.savedCKRecord = [record copy];
            NSLog(@"In save op, says saved record is %@", self.savedCKRecord ? @"Available." : @"NOT available.");

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
