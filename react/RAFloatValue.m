//
// react-objc - a library for functional-reactive-like programming
// https://github.com/tconkling/react-objc/blob/master/LICENSE

#import "RAFloatValue.h"
#import "RAFloatReactor+Protected.h"

@implementation RAFloatValue

- (instancetype)init {
    return [self initWithValue:0];
}

- (instancetype)initWithValue:(float)value {
    if ((self = [super init])) {
        _value = value;
    }
    return self;
}

- (float)value { return _value; }

- (void)setValue:(float)value {
     if (value == _value) {
        return;
    }

    _value = value;
    [self dispatchEvent:_value];
}

@end
