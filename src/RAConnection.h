//
// react-objc - a library for functional-reactive-like programming
// https://github.com/tconkling/react-objc/blob/master/LICENSE

#import <Foundation/Foundation.h>

@class RAReactor;

/** Manages the connection between a signal and a listener. */
@interface RAConnection : NSObject {
@package
    BOOL oneShot;
    RAConnection* next;
    id block;
    int priority;
    __weak RAReactor* reactor;
}

/**
 * Makes this connection one-shot. After the next notification, it will automatically disconnect.
 */
- (RAConnection*)once;

/**
 * Disconnects this connection from the signal. Subsequent emissions won't be passed on to the
 * listener.
 */
- (void)disconnect;

@end
