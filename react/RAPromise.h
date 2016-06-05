//
// react-objc

#import <Foundation/Foundation.h>
#import "RAFuture.h"

/**
 * Provides a concrete implementation of RAFuture that can be updated with a success or failure
 * result when it becomes available.
 *
 * This implementation also guarantees a useful behavior, which is that all listeners added
 * prior to the completion of the promise will be cleared when the promise is completed, and no
 * further listeners will be retained. This allows the promise to be retained after is has been
 * completed as a useful "box" for its underlying value, without concern that references to long
 * satisfied listeners will be inadvertently retained.
 */
@interface RAPromise : RAFuture

/** Creates a new, uncompleted, promise. */
+ (instancetype)create;

/** Causes this promise to be completed with 'result'. */
- (void)completeWithResult:(RATry *)result;

/** Causes this promise to be completed successfully with a nil value. */
- (void)succeed;

/** Causes this promise to be completed successfully with 'value'. */
- (void)succeedWithValue:(id)value;

/** Causes this promise to be completed with failure caused by 'cause'.
 * cause can be an NSException, an NSError, or anything that can be converted to an NSString. */
- (void)failWithCause:(id)cause;

/** Returns a block that can be used to complete this promise. */
- (void (^)(RATry *result))completer;

/** Returns a block that can be used to succeed this promise. */
- (void (^)(id value))succeeder;

/** Returns a block that can be used to fail this promise.
 * (The returned block is heap-allocated, so it can safely be stored.) */
- (void (^)(id cause))failer;

@end
