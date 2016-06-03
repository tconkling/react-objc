//
// react-objc - a library for functional-reactive-like programming
// https://github.com/tconkling/react-objc/blob/master/LICENSE

#import "RAUnitSignal.h"
#import "RAReactor+Protected.h"
#import "RAConnection+Package.h"

@implementation RAUnitSignal

- (void)emit {
    for (RAConnection *cur = [self prepareForEmission]; cur != nil; cur = cur->next) {
        if (RA_IS_CONNECTED(cur)) {
            ((void (^)())cur->block)();
            if (cur->oneShot) {
                [cur disconnect];
            }
        }
    }
    [self finishEmission];
}

- (RAConnection *)connectUnit:(void (^)())block {
    return [self withPriority:RA_DEFAULT_PRIORITY connectUnit:block];
}

- (RAConnection *)withPriority:(int)priority connectUnit:(void (^)())block {
    return [self addConnection:[[RAConnection alloc] initWithBlock:block atPriority:priority onReactor:self]];
}

@end
