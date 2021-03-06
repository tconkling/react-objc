//
// react-objc - a library for functional-reactive-like programming
// https://github.com/tconkling/react-objc/blob/master/LICENSE

#import "RAFloatReactor.h"
#import "RAReactor+Protected.h"
#import "RAConnection+Package.h"

@implementation RAFloatReactor
- (void)dispatchEvent:(float)event {
    for (RAConnection *cur = [self prepareForEmission]; cur != nil; cur = cur->next) {
        if (RA_IS_CONNECTED(cur)) {
            ((void (^)(float))cur->block)(event);
            if (cur->oneShot) {
                [cur disconnect];
            }
        }
    }
    [self finishEmission];
}

- (RAConnection *)connect:(void (^)(float))slot {
    return [self withPriority:RA_DEFAULT_PRIORITY connect:slot];
}

- (RAConnection *)withPriority:(int)priority connect:(void (^)(float))slot {
    return [self addConnection:[[RAConnection alloc] initWithBlock:slot atPriority:priority onReactor:self]];
}

- (RAConnection *)connectUnit:(void (^)())slot {
    return [self withPriority:RA_DEFAULT_PRIORITY connectUnit:slot];
}

- (RAConnection *)withPriority:(int)priority connectUnit:(void (^)())slot {
    return [self withPriority:priority connect:^(float event) {
        slot();
    }];
}
@end
