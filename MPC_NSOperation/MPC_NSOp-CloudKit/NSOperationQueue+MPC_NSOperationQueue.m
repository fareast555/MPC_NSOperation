//
//  NSOperationQueue+MPC_NSOperationQueue.m
//  ElectLiberalUSA
//
//  Created by Michael Critchley on 2017/11/15.
//  Copyright © 2017 Michael Critchley. All rights reserved.
//

#import "NSOperationQueue+MPC_NSOperationQueue.h"
#import "MPC_NSOperation.h"

@implementation NSOperationQueue (MPC_NSOperationQueue)


- (void)addDependenciesAndDefaultAdapterBlocksBetweenMPC_NSOperationsArray:(NSArray *)operationsArray
{
    if (!operationsArray) return;
    if (operationsArray.count < 2) return;
    
    //1. Add default blocks to pass forward errors / isCancelled
    NSArray *arrayWithBlockOps = [NSOperationQueue _arrayWithAddedDefaultNSBlockOperationsFromOperationsArray:operationsArray];
    
    //2. Set dependencies
    NSArray *arrayWithDependencies = [self configureDependenciesForNSOperationsArray:arrayWithBlockOps];
    
    //3. Add all of these ops to the operationQueue
    [self addOperations:arrayWithDependencies waitUntilFinished:NO];
}

+ (NSArray *)_arrayWithAddedDefaultNSBlockOperationsFromOperationsArray:(NSArray *)operationsArray
{
    //1. Create iVars
    Class checkClass = [MPC_NSOperation class];
    NSMutableArray *holder = [NSMutableArray new];
    
    //2. Iterate through initial array to add small adapter blocks that will
    //pass the error object and .isCancelled flag from Op1 (before block) over to Op2 (after block)
    for (NSOperation *op in operationsArray) {
        
        //3. Add each object from original array
        [holder addObject:op];
        
        //4. End if we are on the final object
        if ([op isEqual:operationsArray.lastObject])
            break;
        
        //5. Check if both this object and the next are MPC_Operation subclasses
        NSInteger index1 = [operationsArray indexOfObject:op];
        NSOperation *op2 = operationsArray[index1 + 1];
        
        if ([op isKindOfClass:checkClass] &&
            [op2 isKindOfClass:checkClass]) {

            //6. If so, create a block that forwards the state variables of Op1 to Op2
            NSBlockOperation *passForward = [NSBlockOperation blockOperationWithBlock:^{
                
                //7. Cancel subsequent op if previous was in a cancelled state
                if (op.isCancelled) 
                    [op2 cancel];
                
                //8. Pass forward errors (nil or otherwise)
                ((MPC_NSOperation *)op2).error = ((MPC_NSOperation *)op).error;
            }];
            
            //9. Add the block to the holder
            [holder addObject:passForward];
            
        }
        
    }
    return [holder copy];
}

- (NSArray *)configureDependenciesForNSOperationsArray:(NSArray *)operationsArray
{
    NSInteger i = 0;
    
    for (NSOperation *op in operationsArray) {
        
        //End if we are on the final object
        if ([op isEqual:operationsArray.lastObject])
            break;
        
        //Add a depency from the earlier op to the next one in the chain
        NSInteger index1 = [operationsArray indexOfObject:op];
        NSOperation *op2 = operationsArray[index1 + 1];
        [op2 addDependency:op];
        i++;
    }
    return operationsArray;
}


@end
