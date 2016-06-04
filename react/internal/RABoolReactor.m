//
// react-objc - a library for functional-reactive-like programming
// https://github.com/tconkling/react-objc/blob/master/LICENSE

#import "RABoolReactor.h"
#import "RAReactor+Protected.h"
#import "RAConnection+Package.h"

@implementation RABoolReactor
- (void)dispatchEvent:(BOOL)event {
    for (RAConnection *cur = [self prepareForEmission]; cur != nil; cur = cur->next) {
        if (RA_IS_CONNECTED(cur)) {
            ((void (^)(BOOL))cur->block)(event);
            if (cur->oneShot) {
                [cur disconnect];
            }
        }
    }
    [self finishEmission];
}

- (RAConnection *)connect:(void (^)(BOOL))slot {
    return [self withPriority:RA_DEFAULT_PRIORITY connect:slot];
}

- (RAConnection *)withPriority:(int)priority connect:(void (^)(BOOL))slot {
    return [self addConnection:[[RAConnection alloc] initWithBlock:slot atPriority:priority onReactor:self]];
}

- (RAConnection *)connectUnit:(void (^)())func {
    return [self withPriority:RA_DEFAULT_PRIORITY connectUnit:func];
}

- (RAConnection *)withPriority:(int)priority connectUnit:(void (^)())func {
    return [self withPriority:priority connect:^(BOOL event) {
        func();
    }];
}
@end
