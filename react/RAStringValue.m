//
// react-objc - a library for functional-reactive-like programming
// https://github.com/tconkling/react-objc/blob/master/LICENSE

#import "RAStringValue.h"
#import "RAStringReactor+Protected.h"

@implementation RAStringValue

- (instancetype)init {
    return [self initWithValue:nil];
}

- (instancetype)initWithValue:(NSString *)value {
    if ((self = [super init])) {
        _value = value;
    }
    return self;
}

- (NSString *)value { return _value; }

- (void)setValue:(NSString *)value {
    if (value == _value) {
        return;
    }

    _value = value;
    [self dispatchEvent:_value];
}

@end
