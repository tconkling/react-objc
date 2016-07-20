//
// react-objc - a library for functional-reactive-like programming
// https://github.com/tconkling/react-objc/blob/master/LICENSE

#import "RACloseableSet.h"
#import "RAMultiFailureError.h"

@interface RACloseableSet () {
    // lazily instantiated
    NSMutableSet *_set;
}
@end

@implementation RACloseableSet

- (instancetype)init {
    if (!(self = [super init])) return nil;
    return self;
}

- (void)close {
    if (_set != nil) {
        RAMultiFailureError *multiErr = nil;
        for (id<RACloseable> c in _set) {
            @try {
                [c close];
            } @catch (NSException *e) {
                if (multiErr == nil) {
                    multiErr = [[RAMultiFailureError alloc] init];
                }
                [multiErr addFailure:e];
            }
        }
        [_set removeAllObjects];

        if (multiErr != nil) {
            [multiErr raise];
        }
    }
}

- (id<RACloseable>)add:(id<RACloseable>)c {
    if (_set == nil) {
        _set = [[NSMutableSet alloc] init];
    }
    [_set addObject:c];
    return c;
}

- (void)remove:(id<RACloseable>)conn {
    if (_set != nil) {
        [_set removeObject:conn];
    }
}

@end
