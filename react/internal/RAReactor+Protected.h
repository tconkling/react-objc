//
// react-objc - a library for functional-reactive-like programming
// https://github.com/tconkling/react-objc/blob/master/LICENSE

#import "RAReactor.h"

@class RAConnection;

#define RA_IS_CONNECTED(connection) (connection->reactor != nil)

@interface RAReactor (Protected)

/** Adds a new connection to this Reactor. */
- (RAConnection *)addConnection:(RAConnection *)connection;

/** Subclasses must call this to prepare the Reactor for an event emission. */
- (RAConnection *)prepareForEmission;

/** Subclasses msut call this when an event emission has completed. */
- (void)finishEmission;

/** Called when a new connection has been added to this Reactor. */
- (void)connectionAdded;

/** Called when a connection has been removed from this Reactor. */
- (void)connectionRemoved;

@end
