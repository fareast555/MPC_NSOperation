//
//  NSOperationQueue+MPC_NSOperationQueue.h
//  ElectLiberalUSA
//
//  Created by Michael Critchley on 2017/11/15.
//  Copyright © 2017 Michael Critchley. All rights reserved.

/*****************
This category has a convenience instance method for NSOperationQueue that packages
 MPC_NSOperations and intermediate adapter blocks. Specificially, the method
 1. Puts a small, intermediate block of code between two MPC_NSOperation subclasses
    to carry forward errors and .isCancelled state.
 2. Creates a depenency chain starting from array[0] down to array[n]
 3. Adds the operations to the receiving NSOperationQueue object that called the method
 
 ** Do not use this with regular NSOperation objects. It will break.
 ** Add your ops to your array in the order they should be performed
 ** You  can add blockOperationWithBlock^() operations, but in the code you write in the
    block, be sure to pass forward the error and is.Cancelled state information to the
    next op in the queue (See MPC_NSOperation.h) for an example
 
******************/

#import <Foundation/Foundation.h>

@interface NSOperationQueue (MPC_NSOperationQueue)

//CREATES AND ADDS TO queue a dependency chain starting from array[0] (ie, array[0]will be the first op performed
//If array[i] and array[i+1] are both subclasses of MPC_NSOperation, it will add a default NSBlockOperation
//that passes errors forward.
- (void )addDependenciesAndDefaultAdapterBlocksBetweenMPC_NSOperationsArray:(NSArray *)operationsArray;

@end
