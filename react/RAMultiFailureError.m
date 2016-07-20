//
// react

#import "RAMultiFailureError.h"
#import "RAUtil.h"

@interface RAMultiFailureError () {
    NSMutableArray *_failures;
}
@end

static NSString *GetMessage (id failure) {
    if ([failure isKindOfClass:[NSException class]]) {
        NSException *exc = (NSException *)failure;
        return [NSString stringWithFormat:@"%@: %@", exc.name, exc.reason];
    } else if ([failure isKindOfClass:[NSString class]]) {
        return failure;
    } else if ([failure isKindOfClass:[NSNull class]] || failure == nil) {
        return @"null";
    } else if ([failure isKindOfClass:[NSObject class]]) {
        return ((NSObject *) failure).description;
    } else {
        return @"Unknown error";
    }
}

@implementation RAMultiFailureError

@synthesize failures = _failures;

- (instancetype)init {
    if ((self = [super init])) {
        _failures = [NSMutableArray array];
    }
    return self;
}

- (void)addFailure:(id)failure {
    [_failures addObject:RANilToNSNull(failure)];
}

- (NSString *)description {
    NSMutableString *messages = [NSMutableString string];
    for (id failure in _failures) {
        if (messages.length > 0) {
            [messages appendString:@", "];
        }
        [messages appendString:GetMessage(failure)];
    }

    return [NSString stringWithFormat:@"%lu failures: %@", (unsigned long)_failures.count, messages];
}

- (void)raise {
    [NSException raise:@"RAMultiFailureError" format:@"%@", self.description];
}

@end
