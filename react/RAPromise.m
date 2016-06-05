//
// react-objc

#import "RAPromise.h"
#import "RATry.h"
#import "RAObjectValue.h"

@implementation RAPromise

/** Creates a new, uncompleted, promise. */
+ (instancetype)create {
    return [[RAPromise alloc] init];
}

/** Causes this promise to be completed with 'result'. */
- (void)completeWithResult:(RATry *)result {
    if (_result.value != nil) {
        [NSException raise:NSGenericException format:@"Already completed"];
    }

    @try {
        _result.value = result;
    } @finally {
        [_result disconnectAll];
    }
}

- (void)succeed {
    return [self succeedWithValue:nil];
}

- (void)succeedWithValue:(id)value {
    [self completeWithResult:[RATry success:value]];
}

- (void)failWithCause:(id)cause {
    [self completeWithResult:[RATry failure:cause]];
}

- (void (^)(RATry *))completer {
    // Do not weakify our self pointer - we need this block to retain ourselves.
    // (There is no leak here - we're not holding a reference to this block.)
    return [^(RATry *result) {
        [self completeWithResult:result];
    } copy];
}

- (void (^)(id))succeeder {
    // Do not weakify our self pointer - we need this block to retain ourselves.
    // (There is no leak here - we're not holding a reference to this block.)
    return [^(id value) {
        [self succeedWithValue:value];
    } copy];
}

- (void (^)(id))failer {
    // Do not weakify our self pointer - we need this block to retain ourselves.
    // (There is no leak here - we're not holding a reference to this block.)
    return [^(id cause) {
        [self failWithCause:cause];
    } copy];
}

@end
