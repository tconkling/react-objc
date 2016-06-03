//
// react-objc - a library for functional-reactive-like programming
// https://github.com/tconkling/react-objc/blob/master/LICENSE

#import "RAConnection.h"
#import "RAConnection+Package.h"
#import "RAReactor.h"

@implementation RAConnection

- (RAConnection*)once {
    oneShot = YES;
    return self;
}

- (void)disconnect {
    [reactor disconnect:self];
}

@end

@implementation RAConnection(package)
- (id)initWithBlock:(id)newblock atPriority:(int)newpriority onReactor:(RAReactor*)newreactor {
    if (!(self = [super init])) return nil;
    block = [newblock copy];
    priority = newpriority;
    reactor = newreactor;
    return self;
}
@end
