//
// react-objc

#import <Foundation/Foundation.h>
#import <XCTest/XCTestAssertions.h>

@interface Counter : NSObject
@property (nonatomic, readonly) int count;
@property (nonatomic, readonly) void (^triggerer)(id);
- (void)trigger;
- (void)reset;
@end

#define CHECK_COUNTER(counter, expected, ...) \
    XCTAssertEqual(counter.count, expected, __VA_ARGS__)
