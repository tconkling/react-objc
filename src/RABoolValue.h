//
// react-objc - a library for functional-reactive-like programming
// https://github.com/tconkling/react-objc/blob/master/LICENSE

#import "RABoolReactor.h"

@interface RABoolValue : RABoolReactor {
@protected
    BOOL _value;
}

@property(nonatomic,readwrite) BOOL value;
- (instancetype)init;
- (instancetype)initWithValue:(BOOL)value;
@end
