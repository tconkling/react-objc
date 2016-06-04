//
// react-objc - a library for functional-reactive-like programming
// https://github.com/tconkling/react-objc/blob/master/LICENSE

#import "RAConnectionGroup.h"
#import "RAConnection.h"

@interface RAConnectionGroup () {
    NSMutableSet *_conns;
}
@end

@implementation RAConnectionGroup

- (instancetype)init {
    if (!(self = [super init])) return nil;
    _conns = [[NSMutableSet alloc] init];
    return self;
}

- (void)disconnectAll {
    for (RAConnection *conn in _conns) {
        [conn disconnect];
    }
    [_conns removeAllObjects];
}

- (RAConnection *)add:(RAConnection *)conn {
    [_conns addObject:conn];
    return conn;
}

- (RAConnection *)remove:(RAConnection *)conn {
    [_conns removeObject:conn];
    return conn;
}

@end
