//
// react-objc - a library for functional-reactive-like programming
// https://github.com/tconkling/react-objc/blob/master/LICENSE

#import "RADoubleValue.h"
#import "RADoubleReactor+Protected.h"

@implementation RADoubleValue

- (instancetype)init {
    return [self initWithValue:0];
}

- (instancetype)initWithValue:(double)value {
    if ((self = [super init])) {
        _value = value;
    }
    return self;
}

- (double)value { return _value; }

- (void)setValue:(double)value {
     if (value == _value) {
        return;
    }

    _value = value;
    [self dispatchEvent:_value];
}

@end
