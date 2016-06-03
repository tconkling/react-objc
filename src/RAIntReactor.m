//
// react-objc - a library for functional-reactive-like programming
// https://github.com/tconkling/react-objc/blob/master/LICENSE

#import "RAIntReactor.h"
#import "RAReactor+Protected.h"
#import "RAConnection+Package.h"
#import "RAIntReactor+Protected.h"

@implementation RAIntReactor
- (void) dispatchEvent:(int)event {
    for (RAConnection *cur = [self prepareForEmission]; cur != nil; cur = cur->next) {
        if (RA_IS_CONNECTED(cur)) {
            ((RAIntSlot)cur->block)(event);
            if (cur->oneShot) [cur disconnect];
        }
    }
    [self finishEmission];
}

- (RAConnection*)connectSlot:(RAIntSlot)block {
    return [self withPriority:RA_DEFAULT_PRIORITY connectSlot:block];
}

- (RAConnection*)withPriority:(int)priority connectSlot:(RAIntSlot)block {
    return [self connectConnection:[[RAConnection alloc] initWithBlock:block atPriority:priority onReactor:self]];
}

- (RAConnection*)connectUnit:(RAUnitBlock)block {
    return [self withPriority:RA_DEFAULT_PRIORITY connectUnit:block];
}

- (RAConnection*)withPriority:(int)priority connectUnit:(RAUnitBlock)block {
    return [self withPriority:priority connectSlot:^(int event) { block(); }];
}
@end
