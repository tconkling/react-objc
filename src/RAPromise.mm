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

- (void)succeedWithValue:(id)value {
    [self completeWithResult:[RATry success:value]];
}

- (void)failWithCause:(id)cause {
    [self completeWithResult:[RATry failure:cause]];
}

- (void (^)(RATry *))completer {
    __weak RAPromise *weakSelf = self;
    return [^(RATry *result) {
        RAPromise *strongSelf = weakSelf;
        [strongSelf completeWithResult:result];
    } copy];
}

- (void (^)(id))succeeder {
    __weak RAPromise *weakSelf = self;
    return [^(id value) {
        RAPromise *strongSelf = weakSelf;
        [strongSelf succeedWithValue:value];
    } copy];
}

- (void (^)(id))failer {
    __weak RAPromise *weakSelf = self;
    return [^(id cause) {
        RAPromise *strongSelf = weakSelf;
        [strongSelf failWithCause:cause];
    } copy];
}

@end
