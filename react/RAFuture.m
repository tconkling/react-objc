//
// react-objc

#import "RAFuture.h"
#import "RATry.h"
#import "RAObjectValue.h"
#import "RAPromise.h"
#import "RAMultiFailureError.h"
#import "RAUtil.h"

@interface Sequencer : NSObject {
    RAPromise *_promise;
    NSMutableArray *_results;
    NSUInteger _remaining;
    RAMultiFailureError *_error;
}

@property (nonatomic, readonly) RAFuture *future;

- (instancetype)initWithCount:(NSUInteger)count;
- (void)setResult:(RATry *)result forIndex:(NSUInteger)idx;
@end

@implementation Sequencer

@synthesize future = _promise;

- (instancetype)initWithCount:(NSUInteger)count {
    if ((self = [super init])) {
        _remaining = count;
        _promise = [RAPromise create];

        _results = [NSMutableArray arrayWithCapacity:count];
        for (NSUInteger ii = 0; ii < count; ++ii) {
            [_results addObject:[NSNull null]];
        }
    }
    return self;
}

- (void)setResult:(RATry *)result forIndex:(NSUInteger)idx {
    @synchronized (self) {
        if (result.isSuccess) {
            _results[idx] = RANilToNSNull(result.value);
        } else {
            if (_error == nil) {
                _error = [[RAMultiFailureError alloc] init];
            }
            [_error addFailure:result.failure];
        }

        if (--_remaining == 0) {
            if (_error != nil) {
                [_promise failWithCause:_error];
            } else {
                [_promise succeedWithValue:_results];
            }
        }
    }
}

@end

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

+ (instancetype)failure {
    return [RAFuture futureWithResult:[RATry failure:nil]];
}

+ (instancetype)futureWithResult:(RATry *)result {
    RAFuture *future = [[RAFuture alloc] init];
    future->_result.value = result;
    return future;
}

+ (RAFuture *)sequence:(NSArray *)futures {
    // if we're passed an empty list of futures, succeed immediately with an empty array
    if (futures.count == 0) {
        return [RAFuture successWithValue:[NSArray array]];
    }

    Sequencer *seq = [[Sequencer alloc] initWithCount:futures.count];
    for (NSUInteger idx = 0; idx < futures.count; ++idx) {
        RAFuture *thisFuture = futures[idx];
        [thisFuture onComplete:^(RATry *result) {
            [seq setResult:result forIndex:idx];
        }];
    }

    return seq.future;
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
