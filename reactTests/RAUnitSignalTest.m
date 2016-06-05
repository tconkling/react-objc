//
// react-objc - a library for functional-reactive-like programming
// https://github.com/tconkling/react-objc/blob/master/LICENSE


#import <XCTest/XCTest.h>
#import "RAUnitSignal.h"
#import "RAConnectionGroup.h"
#import "RAConnection.h"

@interface RAUnitSignalTest : XCTestCase
@end

@implementation RAUnitSignalTest

- (void)testEmission {
    RAUnitSignal *sig = [[RAUnitSignal alloc] init];
    __block int x = 0;
    [sig connectUnit:^{ x++; }];
    [sig emit];
    [sig emit];
    XCTAssertEqual(x, 2);
}

- (void)testMultipleListeners {
    RAUnitSignal *sig = [[RAUnitSignal alloc] init];
    __block int x = 0;
    [sig connectUnit:^{ x++; }];
    [sig connectUnit:^{ x++; }];
    [sig emit];
    XCTAssertEqual(x, 2);
}

- (void)testDisconnecting {
    RAUnitSignal *sig = [[RAUnitSignal alloc] init];
    __block int x = 0;
    __block int y = 0;
    [[sig connectUnit:^{ x++; }] once];
    [sig connectUnit:^{ y++; }];
    RAConnection *conn = [sig connectUnit:^{ x++; }];
    [sig emit];
    XCTAssertEqual(x, 2);
    XCTAssertEqual(y, 1);
    [sig emit];
    XCTAssertEqual(x, 3);
    XCTAssertEqual(y, 2);
    [conn disconnect];
    [sig emit];
    XCTAssertEqual(x, 3);
    XCTAssertEqual(y, 3);
}

- (void)testGroup {
    RAConnectionGroup *group = [[RAConnectionGroup alloc] init];
    RAUnitSignal *sig = [[RAUnitSignal alloc] init];
    __block int x = 0;
    [group add:[sig connectUnit:^{
        x++;
    }]];
    [group add:[sig connectUnit:^{
        x++;
    }]];
    [sig connectUnit:^{ x++; }];
    [sig emit];
    XCTAssertEqual(x, 3);
    [group disconnectAll];
    [sig emit];
    XCTAssertEqual(x, 4);
}

- (void)testAddInEmission {
    RAUnitSignal *sig = [[RAUnitSignal alloc] init];
    __block int x = 0;
    [sig connectUnit:^{ x++; }];
    [[sig connectUnit:^{
        x++;
        [[sig connectUnit:^{ x++; }] once];
    }] once];
    [[sig connectUnit:^{ x++; }] once];
    [sig emit];
    XCTAssertEqual(x, 3, @"3 initially added fired");
    [sig emit];
    XCTAssertEqual(x, 5, @"Added in block and new added fired");
    [sig emit];
    XCTAssertEqual(x, 6, @"Block adder fires");
}

- (void)testPriority {
    RAUnitSignal *sig = [[RAUnitSignal alloc] init];
    __block int x = 0;
    [sig withPriority:2 connectUnit:^{ XCTAssertEqual(x++, 0); }];
    [sig connectUnit:^{ x++; }];
    [sig withPriority:1 connectUnit:^{ XCTAssertEqual(x++, 1); }];
    [sig emit];
    XCTAssertEqual(x, 3);
}

- (void)testDisconnectDuringEmission {
    RAUnitSignal *sig = [[RAUnitSignal alloc] init];
    __block int x = 0;

    RAConnection* conn = [sig connectUnit:^{ x++; }];
    [sig withPriority:1 connectUnit:^{ [conn disconnect]; }];
    [sig emit];
    XCTAssertEqual(x, 0);
    [sig disconnectAll];

    [sig connectUnit:^{ [sig disconnectAll]; }];
    [sig connectUnit:^{ x++; }];
    [sig emit];
    XCTAssertEqual(x, 0);
}

@end