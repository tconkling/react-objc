//
// react-objc

#import <Foundation/Foundation.h>
#import "RAReactor.h"

@class RAObjectValue;
@class RATry;

/**
 * Represents an asynchronous result.
 * You can {@link #map} or {@link #flatMap} it, and listen for success or failure via the
 * {@link #success} and {@link #failure} signals.
 */
@interface RAFuture : NSObject {
@protected
    RAObjectValue *_result;
}

/** YES if the Future has at least one connection */
@property (nonatomic, readonly) BOOL hasConnections;

/** Returns a future with a pre-existing success value. */
+ (instancetype)successWithValue:(id)value;

/** Returns a future result with a nil value. */
+ (instancetype)success;

/** Returns a future with a pre-existing failure value. */
+ (instancetype)failureWithCause:(id)cause;

/** Returns a future with a nil failure value. */
+ (instancetype)failure;

/** Returns a future with an already-computed result. */
+ (instancetype)futureWithResult:(RATry *)result;

/**
 * Returns a future containing an NSArray of all success results from {@code futures} if all of
 * the futures complete successfully, or a MultiFailureError aggregating all
 * failures, if any of the futures fails.
 *
 * <p>The result array is in {@code futures}' iteration order.</p>
 */
+ (RAFuture *)sequence:(NSArray *)futures;

/** Causes 'successHandler' to be notified if/when this future is completed with success. If it has
 * already succeeded, the handler will be notified immediately.
 * @return this future for chaining. */
- (RAFuture *)onSuccess:(void (^)(id value))successHandler;

/** Causes 'failureHandler' to be notified if/when this future is completed with failure. If it has
 * already failed, the handler will be notified immediately.
 * @return this future for chaining. */
- (RAFuture *)onFailure:(void (^)(id cause))failureHandler;

/** Causes 'completionHandler' to be notified when this future is completed. If it has already
 * completed, the handler will be notified immediately.
 * @return this future for chaining. */
- (RAFuture *)onComplete:(void (^)(RATry *result))completionHandler;

/** @return true if the future is complete */
- (BOOL)isComplete;

/** Transforms this future by mapping its result upon arrival. */
- (RAFuture *)transform:(RATry *(^)(RATry *result))func;

/** Maps the value of a successful result using 'func' upon arrival.
 * (This is similar to transform, but the function must return a value rather than a Try.) */
- (RAFuture *)map:(id (^)(id value))map;

/** Maps the value of a failed result using {@code func} upon arrival. Ideally one could
 * generalize the type {@code T} here but Java doesn't allow type parameters with lower
 * bounds. */
- (RAFuture *)recover:(id (^)(id failureCause))recover;

/** Maps a successful result to a new result using 'func' when it arrives. Failure on the
 * original result or the mapped result are both dispatched to the mapped result. This is
 * useful for chaining asynchronous actions. It's also known as monadic bind. */
- (RAFuture *)flatMap:(RAFuture *(^)(id))func;

@end
