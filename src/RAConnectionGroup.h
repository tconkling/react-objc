//
// react-objc - a library for functional-reactive-like programming
// https://github.com/tconkling/react-objc/blob/master/LICENSE

#import <Foundation/Foundation.h>
#import "RADefs.h"

@class RAConnection;

/** Holds on to multiple connections to allow for simultaneous disconnection. */
@interface RAConnectionGroup : NSObject

/** Adds a connection to this group. Returns the same connection, for chaining. */
- (RAConnection *)add:(RAConnection *)conn;

/** Removes a connection from this group. Returns the same connection, for chaining. */
- (RAConnection *)remove:(RAConnection *)conn;

/** Disconnects all connections in this group, and then removes them from the group. */
- (void)disconnectAll;

@end
