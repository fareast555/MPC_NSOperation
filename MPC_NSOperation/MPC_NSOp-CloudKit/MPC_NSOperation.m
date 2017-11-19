//
//  MPC_CKOperations.m
//  ElectLiberalUSA
//
//  Created by Michael Critchley on 2017/11/14.
//  Copyright © 2017 Michael Critchley. All rights reserved.


#import "MPC_NSOperation.h"
@interface MPC_NSOperation ()

@property (assign, nonatomic) BOOL isFinishedParentHolderProperty;
@property (assign, nonatomic) BOOL isExecutingHolderProperty;
@end

@implementation MPC_NSOperation

#pragma mark - Factory init
+ (instancetype)MPC_Operation
{
    return [[self alloc]init];
}

- (instancetype)init
{
    self = [super init];
    return self;
}

#pragma mark - Implementations for subclasses
- (BOOL)initializeExecution //A required call from subclasses
{
    //1. Check if dependency[0] was cancelled
    for (NSOperation *op in [self dependencies]) {
        
        //2. If dependency was cancelled, also cancel this op
        if (op.isCancelled)
             [self cancel];
    }
    
    //3. If we are cancelled, set this op as finished
    if ([self isCancelled])
    {
        //4. Inform the op that we are going to change state
        [self willChangeValueForKey:@"isFinished"];
        
        //5. Set the local holder flags
        self.nowFinished = YES;
        
        //6. Inform the op to call to get the current status from the official getters
        [self didChangeValueForKey:@"isFinished"];
        
        //7. Inform the subclass to NOT continue with its workblock
        return NO;
    }
    
    //8. If the operation is not canceled, inform the op we will change state.
    [self willChangeValueForKey:@"isExecuting"];
        
    //9. Set the local holder flag status
    self.nowExecuting = YES;
        
    //10. Inform the op to call to get the current execution status from the official getters
    [self didChangeValueForKey:@"isExecuting"];
    
    //11. Inform the subclass to continue with its workblock
    return YES;
}

//Delegate getters
- (BOOL)isExecuting {
    return self.nowExecuting;
}

- (BOOL)isFinished {
    return self.nowFinished;
}

- (BOOL)isAsynchronous {
    return YES;
}

//Setters that implement subclass property setting via self.
- (void)setNowFinished:(BOOL)nowFinished
{
    self.isFinishedParentHolderProperty = nowFinished;
}

- (BOOL)nowFinished
{
    return self.isFinishedParentHolderProperty;
}

- (void)setNowExecuting:(BOOL)nowExecuting
{
    self.isExecutingHolderProperty = nowExecuting;
}

- (BOOL)nowExecuting
{
    return self.isExecutingHolderProperty;
}

//Mark the subclassed operation as complete
- (void)completeOperation {

    [self willChangeValueForKey:@"isFinished"];
    [self willChangeValueForKey:@"isExecuting"];
    
    self.nowExecuting = NO;
    self.nowFinished = YES;
    
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}

#pragma mark - Error handling
- (void)exposeErrorWithMessage:(NSString *)message
{
    NSLog(@"%s called", __FUNCTION__);
    if (!message)
        message = @"";
    
    self.error = [[NSError alloc]initWithDomain:@"MPC_NSOperationDomain"
                                           code:-1
                                       userInfo:@{NSLocalizedDescriptionKey : message,
                                                  NSLocalizedFailureReasonErrorKey : @"Likely issue with required parameters being passed as nil (or not at all)",
                                                  NSLocalizedRecoverySuggestionErrorKey : @"Use adapter blocks (blockOperationWithBlock^() between operations to set variables on upcoming operations. See MPC_NSOperation.h for more."}];
}


@end
