//
// react-objc - a library for functional-reactive-like programming
// https://github.com/tconkling/react-objc/blob/master/LICENSE

#import "RABoolValue.h"
#import "RABoolReactor+Protected.h"

@implementation RABoolValue

- (instancetype)init {
    return [self initWithValue:NO];
}

- (instancetype)initWithValue:(BOOL)value {
    if ((self = [super init])) {
        _value = value;
    }
    return self;
}

- (BOOL)value { return _value; }

- (void)setValue:(BOOL)value {
     if (value == _value) {
        return;
    }

    _value = value;
    [self dispatchEvent:_value];
}

@end
