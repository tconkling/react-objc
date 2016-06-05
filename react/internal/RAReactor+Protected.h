//
// react-objc - a library for functional-reactive-like programming
// https://github.com/tconkling/react-objc/blob/master/LICENSE

#import "RAReactor.h"

@class RAConnection;

#define RA_IS_CONNECTED(connection) (connection->reactor != nil)

@interface RAReactor (Protected)
- (RAConnection *)addConnection:(RAConnection *)connection;
- (RAConnection *)prepareForEmission;
- (void)finishEmission;
@end
