//
// react-objc - a library for functional-reactive-like programming
// https://github.com/tconkling/react-objc/blob/master/LICENSE

#import "RAFloatReactor.h"
#import "RAReactor+Protected.h"
#import "RAConnection+Package.h"
#import "RAFloatReactor+Protected.h"

@implementation RAFloatReactor
- (void)dispatchEvent:(float)event {
    for (RAConnection *cur = [self prepareForEmission]; cur != nil; cur = cur->next) {
        if (RA_IS_CONNECTED(cur)) {
            ((RAFloatSlot)cur->block)(event);
            if (cur->oneShot) {
                [cur disconnect];
            }
        }
    }
    [self finishEmission];
}

- (RAConnection *)connectSlot:(RAFloatSlot)block {
    return [self withPriority:RA_DEFAULT_PRIORITY connectSlot:block];
}

- (RAConnection *)withPriority:(int)priority connectSlot:(RAFloatSlot)block {
    return [self connectConnection:[[RAConnection alloc] initWithBlock:block atPriority:priority onReactor:self]];
}

- (RAConnection *)connectUnit:(RAUnitBlock)block {
    return [self withPriority:RA_DEFAULT_PRIORITY connectUnit:block];
}

- (RAConnection *)withPriority:(int)priority connectUnit:(RAUnitBlock)block {
    return [self withPriority:priority connectSlot:^(float event) { block(); }];
}
@end
