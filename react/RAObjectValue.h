//
// react-objc - a library for functional-reactive-like programming
// https://github.com/tconkling/react-objc/blob/master/LICENSE

#import "RAObjectReactor.h"

@interface RAObjectValue : RAObjectReactor {
@protected
    id _value;
}

@property(nonatomic,readwrite,strong) id value;
- (instancetype)init;
- (instancetype)initWithValue:(id)value;
@end
