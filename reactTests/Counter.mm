//
// react-objc

#import <XCTest/XCTest.h>
#import "Counter.h"

@interface Counter () {
    int _count;
}
@end

@implementation Counter

@synthesize count = _count;

- (void (^)(id))triggerer {
    return ^(id _) {
        _count++;
    };
}

- (void)trigger {
    _count++;
}

- (void)reset {
    _count = 0;
}

@end
