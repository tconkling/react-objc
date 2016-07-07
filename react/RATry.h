//
// react-objc

#import <Foundation/Foundation.h>

/**
 * Represents a computation that either provided a result, or failed with an exception. Monadic
 * methods are provided that allow one to map and compose tries in ways that propagate failure.
 * This class is not itself "reactive", but it facilitates a more straightforward interface and
 * implementation for {@link Future} and {@link Promise}.
 */
@interface RATry : NSObject

/** Creates a successful try. */
+ (RATry *)success:(id)value;

/**
 * Creates a failed try.
 * 'cause' can be an NSError, NSException, or NSString.
 * (It will be converted to an NSException if the error is rethrown.)
 */
+ (RATry *)failure:(id)cause;

/** Lifts {@code func}, a function on values, to a function on tries. */
+ (RATry * (^)(RATry *))lift:(id (^)(id))map;

/** The value associated with a successful try, or rethrows the exception if the try
 * failed. */
@property (nonatomic, readonly) id value;

/** The cause of failure for a failed try. Throws {@link IllegalOperationError} if
 * called on a successful try. */
@property (nonatomic, readonly) id failure;

/** YES if this is a successful try, NO if it is a failed try. */
@property (nonatomic, readonly) BOOL isSuccess;

/** YES if this is a failed try, NO if it is a successful try. */
@property (nonatomic, readonly) BOOL isFailure;

/** Maps successful tries through {@code func}, passes failure through as is. */
- (RATry *)map:(id (^)(id value))map;

/** Maps failed tries through {@code func}, passes success through as is. Note: if {@code func}
  * throws an exception, you will get back a failure try with the new failure. Ideally one
  * could generalize the type {@code T} here but Java doesn't allow type parameters with lower
  * bounds. */
- (RATry *)recover:(id (^)(id failureCause))recover;

/** Maps successful tries through {@code func}, passes failure through as is. */
- (RATry *)flatMap:(RATry * (^)(id value))flatMap;

@end
