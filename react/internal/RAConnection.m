//
// react-objc - a library for functional-reactive-like programming
// https://github.com/tconkling/react-objc/blob/master/LICENSE

#import "RAConnection.h"
#import "RAConnection+Package.h"
#import "RAReactor.h"

@implementation RAConnection

- (RAConnection *)once {
    oneShot = YES;
    return self;
}

- (void)disconnect {
    [self close];
}

- (void)close {
    [reactor disconnect:self];
}

@end

@implementation RAConnection(package)
- (instancetype)initWithBlock:(id)newBlock atPriority:(int)newPriority onReactor:(RAReactor *)newReactor {
    if ((self = [super init])) {
        block = [newBlock copy];
        priority = newPriority;
        reactor = newReactor;
    }
    return self;
}
@end
