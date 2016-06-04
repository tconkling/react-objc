//
// react-objc - a library for functional-reactive-like programming
// https://github.com/tconkling/react-objc/blob/master/LICENSE

#import "RAIntReactor.h"

@interface RAIntValue : RAIntReactor {
@protected
    int _value;
}

@property(nonatomic,readwrite) int value;
- (instancetype)init;
- (instancetype)initWithValue:(int)value;
@end
