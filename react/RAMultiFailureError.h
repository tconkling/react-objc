//
// react

#import <Foundation/Foundation.h>

/** Aggregates multiple errors together */
@interface RAMultiFailureError : NSObject

/** A list of all error objects (NSExceptions, NSErrors, NSStrings) in this error. */
@property (nonatomic, readonly) NSArray *failures;

/** Adds a failure (an NSException, NSError, or NSString) to the aggregation. */
- (void)addFailure:(id)failure;

/** Returns a string with all of the failure explanations concatenated together. */
- (NSString *)description;

/** Raises an NSException for the multi-failure error. */
- (void)raise;

@end
