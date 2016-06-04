//
// react-objc

#import "RATry.h"
#import "RADefs.h"

@interface RASuccess : RATry {
    id _value;
}
- (instancetype)initWithValue:(id)value;
@end

@interface RAFailure : RATry {
    id _cause;
}
- (instancetype)initWithCause:(id)cause;
@end

@implementation RATry

+ (RATry *)success:(id)value {
    return [[RASuccess alloc] initWithValue:value];
}

+ (RATry *)failure:(id)cause {
    return [[RAFailure alloc] initWithCause:cause];
}

/** Lifts {@code func}, a function on values, to a function on tries. */
+ (RATry * (^)(RATry *))lift:(id (^)(id))map {
    return ^RATry * (RATry *result) {
        return [result map:map];
    };
}

- (id)value {
    RA_IS_ABSTRACT();
}

- (id)failure {
    RA_IS_ABSTRACT();
}

- (BOOL)isSuccess {
    RA_IS_ABSTRACT();
}

- (BOOL)isFailure {
    return !self.isSuccess;
}

- (RATry *)map:(id (^)(id value))map {
    RA_IS_ABSTRACT();
}

- (RATry *)recover:(id (^)(id failureCause))recover {
    RA_IS_ABSTRACT();
}

- (RATry *)flatMap:(RATry * (^)(id value))flatMap {
    RA_IS_ABSTRACT();
}

@end

@implementation RASuccess

- (instancetype)initWithValue:(id)value {
    if ((self = [super init])) {
        _value = value;
    }
    return self;
}

- (id)value {
    return _value;
}

- (id)failure {
    [NSException raise:NSGenericException format:@"Not a failure"];
    return nil;
}

- (BOOL)isSuccess {
    return YES;
}

- (RATry *)map:(id (^)(id value))map {
    @try {
        return [RATry success:map(_value)];
    } @catch (NSException *e) {
        return [RATry failure:e];
    }
}

- (RATry *)recover:(id (^)(id failureCause))recover {
    return self;
}

- (RATry *)flatMap:(RATry * (^)(id value))flatMap {
    @try {
        return flatMap(_value);
    } @catch (NSException *e) {
        return [RATry failure:e];
    }
}

@end

@implementation RAFailure

- (instancetype)initWithCause:(id)cause {
    if ((self = [super init])) {
        _cause = cause;
    }
    return self;
}

- (id)value {
    [[self causeToException] raise];
    return nil;
}

- (id)failure {
    return _cause;
}

- (BOOL)isSuccess {
    return NO;
}

- (RATry *)map:(id (^)(id value))map {
    return self;
}

- (RATry *)recover:(id (^)(id failureCause))recover {
    @try {
        return [RATry success:recover(_cause)];
    } @catch (NSException *e) {
        return [RATry failure:e];
    }
}

- (RATry *)flatMap:(RATry * (^)(id value))flatMap {
    return self;
}

- (NSException *)causeToException {
    if ([_cause isKindOfClass:[NSException class]]) {
        return _cause;
    } else if ([_cause isKindOfClass:[NSError class]]) {
        NSError *err = _cause;
        return [[NSException alloc] initWithName:NSGenericException
                                          reason:err.description
                                        userInfo:@{ @"NSError": err }];

    } else {
        return [[NSException alloc] initWithName:NSGenericException
                                          reason:[NSString stringWithFormat:@"%@", _cause]
                                        userInfo:@{ @"cause": _cause }];
    }
}

@end
