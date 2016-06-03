//
// react-objc - a library for functional-reactive-like programming
// https://github.com/tconkling/react-objc/blob/master/LICENSE

#import <XCTest/XCTest.h>
#import "RAObjectSignal.h"

@interface RASignalTest : XCTestCase
@end

@implementation RASignalTest
- (void)testEmission {
    RAObjectSignal *sig = [[RAObjectSignal alloc] init];
    __block int x = 0;
    [sig connectUnit:^{ x++; }];
    [sig connectSlot:^(id value) {
        XCTAssertEqual(value, @"Hello"); x++;
    }];
    [sig emitEvent:@"Hello"];
    XCTAssertEqual(x, 2);
}

@end
