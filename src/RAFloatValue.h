//
// react-objc - a library for functional-reactive-like programming
// https://github.com/tconkling/react-objc/blob/master/LICENSE

#import "RAFloatReactor.h"

@interface RAFloatValue : RAFloatReactor {
@protected
    float _value;
}

@property(nonatomic,readwrite) float value;
- (id)init;
- (id)initWithValue:(float)value;
@end
