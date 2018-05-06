//
//  MPC_CKQueryOperation.m
//  ElectLiberalUSA
//
//  Created by Michael Critchley on 2017/11/14.
//  Copyright © 2017 Michael Critchley. All rights reserved.
//

#import "MPC_CKQueryOperation.h"

@interface MPC_CKQueryOperation ()

@property (strong, atomic) NSString *recordType;
@property (strong, atomic) CKDatabase *CKDatabase;
@property (strong, atomic) NSArray *desiredKeys;
@property (assign, atomic) NSUInteger resultsLimit;
@property (assign, atomic) NSUInteger timeOutIntervaleForRequest;

//Holder array
@property (strong, nonatomic) NSMutableArray *receivedRecords;

@end

@implementation MPC_CKQueryOperation

- (instancetype)initWithCKRecordType:(NSString *)CKRecordType
                 usesPrivateDatabase:(BOOL)usesPrivateDatabase //Public or Private
                           predicate:(NSPredicate *)predicate
                         desiredKeys:(NSArray *)desiredKeys
                        resultsLimit:(NSUInteger)resultsLimit
           timeoutIntervalForRequest:(NSUInteger)timeoutIntervalForRequest
{
    if ((self = [[self class] MPC_Operation])) {
        self.recordType = CKRecordType;
        self.CKDatabase = usesPrivateDatabase ?
                [[CKContainer defaultContainer]privateCloudDatabase] :
                [[CKContainer defaultContainer]publicCloudDatabase];
        self.predicate = predicate;
        self.desiredKeys = desiredKeys;
        self.resultsLimit = resultsLimit;
        self.timeOutIntervaleForRequest = timeoutIntervalForRequest;
    }
    
    NSAssert(self.recordType != nil, @"CKRecordType must not be nil!");
    return self;
}

- (void) start
{
    //1. Call to super to check if previous or this current operation have been cancelled
    if (![super initializeExecution])
        return;
    
    //2. Cancel if predicate or CKRecordType has not been sent
    if (!self.recordType || !self.predicate) {
        [self exposeErrorWithMessage:@"Query canceled. Predicate or Record Type not set. See error messages for more."];
        [self cancel];
        [super completeOperation];
        return;
    }
    
    //3. Create an array to keep records as they arrive
    self.receivedRecords = [[NSMutableArray alloc]init];
    
    //4. Create query
    CKQuery *query = [[CKQuery alloc]initWithRecordType:self.recordType predicate:self.predicate];
    
    //5. Create query Operation
    CKQueryOperation *queryOp = [[CKQueryOperation alloc]initWithQuery:query];
    
    //6. Set results limits, timeout interval, and desired keys as required
    if (self.resultsLimit > 0)
        queryOp.resultsLimit = self.resultsLimit;
    
    if (self.timeOutIntervaleForRequest > 0)
            if (@available(iOS 10.0, *)) {
                [queryOp setTimeoutIntervalForRequest:self.timeOutIntervaleForRequest];
            }
    //Add user initiated QOS to get immediate failure if no internet connection
    queryOp.qualityOfService = NSQualityOfServiceUserInitiated;
    
    if (self.desiredKeys)
        queryOp.desiredKeys = self.desiredKeys;
    
    //7. Set a block to catch each record, which are passed in individual calls
    queryOp.recordFetchedBlock = ^(CKRecord *record){
        
        //8. Add the record to the holder array
        [self.receivedRecords addObject:record];
        
        //9. Update exposed KVO property
        [self updateRecordWithRecord:[record copy]];
    };
    
    //10. Set completion block, called after query returns
    queryOp.queryCompletionBlock = ^(CKQueryCursor *cursor, NSError *error){
        
        if (error) {
            //11. If error, set an error to be passed up the chain of command
            [self exposeError:error];
            
            //12. Set this operation as cancelled to finish early
            [self cancel];
            
            //13. Else, set the public-facing array of downloaded CKRecords
        } else {
            self.records = [self.receivedRecords copy];
        }
    
        //14. Call to super to mark operation as finished
        [super completeOperation];
    };
    
    //15. Initiate the query
    [self.CKDatabase addOperation:queryOp];
    
}

- (void)updateRecordWithRecord:(CKRecord *)record
{
    dispatch_async(dispatch_get_main_queue(),^{
        [self setValue:record forKey:@"individualRecord"];
    });
}

- (void)exposeError:(NSError *)error
{
    self.error = error;
}

- (void)exposeErrorWithMessage:(NSString *)message //Implemented by super
{
    
}

@end
