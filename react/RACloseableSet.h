//
// react-objc - a library for functional-reactive-like programming
// https://github.com/tconkling/react-objc/blob/master/LICENSE

#import <Foundation/Foundation.h>
#import "RACloseable.h"

/** Holds multiple Closeables to allow mass operations on them. */
@interface RACloseableSet : NSObject <RACloseable>

/** Adds a connection to this group. Returns the same connection, for chaining. */
- (id<RACloseable>)add:(id<RACloseable>)c;

/** Removes a connection from this group. */
- (void)remove:(id<RACloseable>)conn;

/** Closes all objects in this group, and then removes them from the group. */
- (void)close;

@end
