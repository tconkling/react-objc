//
// react-objc - a library for functional-reactive-like programming
// https://github.com/tconkling/react-objc/blob/master/LICENSE

#import "RAObjectValue.h"
#import "RAObjectReactor+Protected.h"

@implementation RAObjectValue

- (instancetype)init {
    return [self initWithValue:nil];
}

- (instancetype)initWithValue:(id)value {
    if ((self = [super init])) {
        _value = value;
    }
    return self;
}

- (id)value { return _value; }

- (void)setValue:(id)value {
    if (value == _value) {
        return;
    }

    _value = value;
    [self dispatchEvent:_value];
}

@end
