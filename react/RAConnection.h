//
// react-objc - a library for functional-reactive-like programming
// https://github.com/tconkling/react-objc/blob/master/LICENSE

#import <Foundation/Foundation.h>
#import "RACloseable.h"

@class RAReactor;

/** Manages the connection between a signal and a listener. */
@interface RAConnection : NSObject <RACloseable> {
@package
    BOOL oneShot;
    RAConnection *next;
    id block;
    int priority;
    __weak RAReactor *reactor;
}

/**
 * Makes this connection one-shot. After the next notification, it will automatically disconnect.
 *
 * <p><em>NOTE:</em> if you are dispatching signals in a multithreaded environment, it is
 * possible for your connected listener to be notified before this call has a chance to mark it
 * as one-shot. Thus you could receive multiple notifications. If you require this to be
 * avoided, you must synchronize on the signal/value/etc. on which you are adding a
 * listener:</p>
 *
 * @return this RAConnection instance, for chaining
 */
- (RAConnection *)once;

/**
 * Disconnects this connection from the signal. Subsequent emissions won't be passed on to the
 * listener.
 */
- (void)close;

/** Deprecated - use close instead. */
- (void)disconnect;

@end
