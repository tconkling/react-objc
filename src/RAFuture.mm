//
// react-objc

#import "RAFuture.h"
#import "RATry.h"
#import "RAObjectValue.h"
#import "RAPromise.h"

@implementation RAFuture

+ (instancetype)successWithValue:(id)value {
    return [RAFuture futureWithResult:[RATry success:value]];
}

+ (instancetype)success {
    return [RAFuture futureWithResult:[RATry success:nil]];
}

+ (instancetype)failureWithCause:(id)cause {
    return [RAFuture futureWithResult:[RATry failure:cause]];
}

+ (instancetype)futureWithResult:(RATry *)result {
    RAFuture *future = [[RAFuture alloc] init];
    future->_result.value = result;
    return future;
}

- (instancetype)init {
    if ((self = [super init])) {
        _result = [[RAObjectValue alloc] init];
    }
    return self;
}

- (BOOL)hasConnections {
    return _result.hasConnections;
}

- (RAFuture *)onSuccess:(void (^)(id))successHandler {
    return [self onComplete:^(RATry *result) {
        if (result.isSuccess) {
            successHandler(result.value);
        }
    }];
}

- (RAFuture *)onFailure:(void (^)(id))failureHandler {
    return [self onComplete:^(RATry *result) {
        if (!result.isSuccess) {
            failureHandler(result.failure);
        }
    }];
}

- (RAFuture *)onComplete:(void (^)(RATry *))completionHandler {
    RATry *result = _result.value;
    if (result != nil) {
        completionHandler(result);
    } else {
        [_result connect:completionHandler];
    }
    return self;
}

- (BOOL)isComplete {
    return _result.value != nil;
}

- (RAFuture *)transform:(RATry *(^)(RATry *))func {
    RAPromise *xf = [RAPromise create];
    [self onComplete:^(RATry *result) {
        @try {
            [xf completeWithResult:func(result)];
        } @catch (NSException *e) {
            [xf failWithCause:e];
        }
    }];

    return xf;
}

- (RAFuture *)map:(id (^)(id))map {
    return [self transform:[RATry lift:map]];
}

- (RAFuture *)recover:(id (^)(id failureCause))recover {
    return [self transform:^RATry *(RATry *result) {
        return [result recover:recover];
    }];
}

- (RAFuture *)flatMap:(RAFuture *(^)(id))func {
    RAPromise *mapped = [RAPromise create];
    [self onComplete:^(RATry *result) {
        if (result.isFailure) {
            [mapped failWithCause:result.failure];
        } else {
            @try {
                [func(result.value) onComplete:mapped.completer];
            } @catch (NSException *e) {
                [mapped failWithCause:e];
            }
        }
    }];

    return mapped;
}

@end
