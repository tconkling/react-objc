//
// react-objc - a library for functional-reactive-like programming
// https://github.com/tconkling/react-objc/blob/master/LICENSE

#import "RAStringReactor.h"
#import "RAReactor+Protected.h"
#import "RAConnection+Package.h"
#import "RAStringReactor+Protected.h"

@implementation RAStringReactor
- (void)dispatchEvent:(NSString *)event {
    for (RAConnection *cur = [self prepareForEmission]; cur != nil; cur = cur->next) {
        if (RA_IS_CONNECTED(cur)) {
            ((void (^)(NSString *))cur->block)(event);
            if (cur->oneShot) {
                [cur disconnect];
            }
        }
    }
    [self finishEmission];
}

- (RAConnection *)connect:(void (^)(NSString *))slot {
    return [self withPriority:RA_DEFAULT_PRIORITY connect:slot];
}

- (RAConnection *)withPriority:(int)priority connect:(void (^)(NSString *))slot {
    return [self addConnection:[[RAConnection alloc] initWithBlock:slot atPriority:priority onReactor:self]];
}

- (RAConnection *)connectUnit:(void (^)())block {
    return [self withPriority:RA_DEFAULT_PRIORITY connectUnit:block];
}

- (RAConnection *)withPriority:(int)priority connectUnit:(void (^)())block {
    return [self withPriority:priority connect:^(NSString *event) {
        block();
    }];
}
@end
