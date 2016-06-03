//
// react-objc - a library for functional-reactive-like programming
// https://github.com/tconkling/react-objc/blob/master/LICENSE

#import "RADefs.h"

@class RAConnection;

/**
 * Handles the basics of connection and dispatching management.
 */
@interface RAReactor : NSObject

/** YES if this Reactor has at least one connection */
@property (nonatomic, readonly) BOOL hasConnections;

/** Keeps the given connection from receiving further emissions. */
- (void)disconnect:(RAConnection *)conn;

/** Disconnects all connections. */
- (void)disconnectAll;

/** Connects the given unit at the default priority.  */
- (RAConnection *)connectUnit:(void (^)())slot;

/** Connects the given unit at the given priority.  */
- (RAConnection *)withPriority:(int)priority connectUnit:(void (^)())slot;
@end
