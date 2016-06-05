//
// react-objc - a library for functional-reactive-like programming
// https://github.com/tconkling/react-objc/blob/master/LICENSE

#import "RADoubleReactor.h"

@interface RADoubleValue : RADoubleReactor {
@protected
    double _value;
}

@property(nonatomic,readwrite) double value;
- (instancetype)init;
- (instancetype)initWithValue:(double)value;
@end
