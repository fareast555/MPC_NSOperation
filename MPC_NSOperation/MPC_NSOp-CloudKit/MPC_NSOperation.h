//
//  MPC_NSOperations.h
//  ElectLiberalUSA
//
//  Created by Michael Critchley on 2017/11/14.
//  Share as required

/**
 This class and the chaining structure using adapter blocks implemented in this app was build up based on the solution presented on the Apple forums by Quinn The Eskimo, here:
   https://forums.developer.apple.com/thread/25761
 */

//*****************
//This is the parent class for all MPC_NSOperations objects.
//To use:
//1. Subclass this method
//2. Implement the -(void)start {} method
//3. Subclasses must call  if (![super initializeExecution]) return; at the top of the start method
     //This is because the parent class checks and cancels execution if previous MPC_NSOperation op was cancelled
//4. **IMPORTANT**
     //Subclasses must call [super completeOperation] when the operation work is done so queue can be removed
     //Even if you call [myOp cancel], you mus still call [super completeOperation] somewhere in the executing code
     //or you will experience more blockage than eating a pound of fiber.

//5. **IMPORTANT**
  //If using blockOperationWithBlock^() as an intermediate step between two MPC_NSOperations,
  //you should forward error objects, and you must manually check if the previous block
  //was cancelled, and if so, cancel the next in the queue. For
  //example, if between MPC_NSOperation1 and MPC_NSOperation2 we put a block...

  //    NSBlockOperation *blockOp = [NSBlockOperation blockOperationWithBlock:^{
  //       if (MPC_Operation1.isCancelled) {
  //           [MPC_Operation2 cancel];
  //       }
  //       MPC_Operation2.error = MPC_Operation1.error;
  //       ...
  //     }

  //      [blockOp addDependency:MPC_Operation1];
  //      [MPC_Operation2 addDependency:blockOp];
  //
  //

//6. Convenience method available for creating depency chains of ops
//   Import the "NSOperationQueue+MPC_NSOperationQueue.h" file
//   Package IN ORDER OF EXECUTION all MPC_NSOperation instances or blockOperations in an NSArray
//   Then call the following method on your NSOperationQueue instance
//   [myOpqueue addDependenciesAndDefaultAdapterBlocksBetweenMPC_NSOperationsArray:myOperationsArray];
//   This will 1) Add intermediate blocks between MPC_NSOperations to pass forward any errors
//             2) Set a chain of dependencies between all objects
//             3) Add all operations to the operationQueue instance that called the method, which begins execution

//7. Call to [self errorWithMessage:] to pass a custom error message if there is some unexpected break in variables being passed forward by the proceding class. The error creation and setting will be handled in the parent class.
//*****************

#import <Foundation/Foundation.h>
@import CloudKit;

@interface MPC_NSOperation : NSOperation

+ (instancetype)MPC_Operation;

- (BOOL)initializeExecution;
- (void)completeOperation;

//Flags used internally (.executing and .finished are readOnly)
@property (nonatomic, assign) BOOL nowExecuting;

//@property (atomic, assign) BOOL nowExecuting;
@property (atomic, assign) BOOL nowFinished;

//All MPC_NSOperations should present an error on error
@property (strong, atomic) NSError *error;

@end
