## MPC_NSOperation with CloudKit
The demo app in this repository uses the MPC_NSOperation class (an Objective-C subclass of NSOperation) to construct chained asynchronous operations to handle time-consuming rendering of objects in the background, or saving, deletion, or querying of objects on a remote server, in this case, iCloud via the CloudKit framework. 

## Why MPC_NSOperation?
MPC_NSOperation can be subclassed to do ANY ansynchronous task and gives you control of when the task will terminate so that you can have downloaded or processed data publicly availble for the next operation to use, all from within one, continuous operation queue. The other convenience is the NSOperationQueue+MPC_NSOperation category, also included in the project. This will intelligently stitch together multiple operations and blocks, add dependencies, and run them for you, reducing easy-to-make errors in dependency construction. 


## Just the facts, ma'am...just the facts!
To go to the meat-and-potatoes code, either check out the [MPC_NSOperation gist](https://gist.github.com/fareast555/2b456b8484f19fff71d01d25322174ec/), or dig into the MPC_NSOperation/MPC_NSOp-CloudKit/ folder in this repo. The files doing the heavy lifting are:

1. MPC_NSOperation  
This is the class that you sublclass. It has an class factory initializer, +(instanceType)MPC_NSOperation

2. MPC_CK---Operation  
These are subclasses of MPC_NSOperation that do saves, queries, deletes, etc. specific to CloudKit. They have zero app-specific logic in them. Most will take a predicate or a record either during or after initialization, and they will usually produce a result that, if successful, will be available as a public property for the subsequent operation.

3. NSOperationQueue+MPC_NSOperation  
This is a category of NSOperationQueue. If you send it an array of MPC_NSOperation subclasses and connecting block operations (only needed between blocks that produce data / objects and those that need to consume them), it will create mini blocks to carry forward errors and state information when required and add them to the array, add dependencies between all operations, then add them to the operationQueue. 

4. MPC_CloudKitManager+TerminalBlocks
This category of MPC_NSOperation resides one directory up. It is acutally very specific to the app. In fact, all NSBlockOperations used after or between operations may need to contain app-specific logic to determine if a operation queue can or should terminate early, or to harvest the final results of a longer operation. *This is not something you should copy and paste. But they are useful to look at to see how operations are passed into blocks.

5. MPC_Block  
This class has only one block, but it is an example of an intermediate adapter block that takes results of one operation, a CKRecord result, and performs some app-specific logic to cancel the subsequent save operation to avoid overwriting or duplicating a unique object. This kind of block is useful also in the CloudKit first-time user creation sequence, when you first need to fetch the unique User type object, and if it exists, add a CKReference to it to be saved on your own local object, then save that custom user to the cloud. (The CKReference allows you to re-find existing custom objects in the case of re-installs or users working from multiple devices).  

## Demo QuickStart

1. Download this demo and run the app. There are some set up instructions in the app, which are:
2. Go to the MPC_NSOperation target window > General and set a new bundle ID and set it to your own team
3. Click on Capabilities and make sure iCloud is turned on. Be sure to check "Key-value storage" and CloudKit.
4. This demo requires that you are a registered developer using a device. 
5. Make sure that you have iCloud enabled on your device, and iCloud Drive switched on.
6. Back in the app, tap "Set up CloudKit" to save a few test "Destination" objects into the public container.

In the app, you'll be able to download (CloudKit Query) some destination images, add them to "My Destinations" (CloudKit save to the private database), and delete them. Simple log statements will indicate the pathway the data is taking.


## Requirements

* iOS 9.0+
* ARC

 
<h3>To use:</h3>
 
  1. Import the MPC_NSOperation{.h/.m} and NSOperationQueue+MPC_NSOperation{.h/.m} files into your project.
 
  2. File > New > File > Cocoa Touch Class > Subclass of MPC_NSOperation

  3. Either copy and paste from any of the MPC_CKOperations in this file for the necessary methods, or implement the following in your subclasses:

```objectivec
   
- (void) start
{
    //REQUIRED CALL TO PARENT
    if (![super initializeExecution])
        return;
    
    //Other custom state checks here. If this operation
    //depends on data from a previous op that was not set, 
    //cancel everything as follows:

    if (!necessaryDataToProceed) {
       [self exposeErrorWithMessage:@"MyOp canceled. Data not set."];
       [self cancel];
       [super completeOperation];
       return;
    }


      //Your code to do cool stuff here!
    

    if (success)
       //Set public properties to be picked up by subsequent MPC_NSOp or blockOp
    else {
       //Set this operation as cancelled to finish early
       [self cancel];
       
       //Set the public error property (held on the parent .h file)
       //Error will then propagate down the line
       [self exposeError:error];
    }

    //REQUIRED CALL TO PARENT - If you don't call this, the thread will never be released
    [super completeOperation];
}

- (void)exposeError:(NSError *)error
{
    self.error = error;
}

- (void)exposeErrorWithMessage:(NSString *)message //Implemented by super
{
    //This convenience method, if called, will be implemented by
    //the parent class. The parent will construct a valid NSError object 
    //and set the public error property
}
```

  4. Use blocks to connect operations that require data to be passed forward. For example, if we make two subclasses, one to query and one to process some data from the query, Query_Op1 and DataOperation2, we could use a block like this...

```objectivec
    NSBlockOperation *blockOp = [NSBlockOperation blockOperationWithBlock:^{

         //Pass state forward
         if (Query_Op1.isCancelled)
             [DataOperation2 cancel];

        //Pass errors forward
         DataOperation2.error = Query_Op1.error

        //Custom object handling
        if (Query_Op1.downloadedRecords)

           DataOperation.recordsToProcess = [Query_Op1.downloadedRecords copy];

        else {

          [DataOperation2 cancel]; 

          DataOperation2.error = <Your custom error object here>
        }

    }
```
     
  4. Add a similar block after the final operation to handle the success or failure of the entire operation.

  5. Package all of your MPC_NSOperation subclass objects and connecting / terminal blocks into an NSArray IN THE ORDER OF EXECUTION.

  6. Import the NSOperationQueue+MPC_NSOperation into your file, create an instance of NSOperationQueue and send the category method this array to be packaged as described at the top of this README. 

```objectivec
   #import NSOperationQueue+MPC_NSOperation.h
     ...
     //The final step after creating and packaging your operations.
     //This will begin the operations sequence.
   [myOperationQueue addDependenciesAndDefaultAdapterBlocksBetweenMPC_NSOperationsArray:myOperationsArray];
```
