//
// react-objc - a library for functional-reactive-like programming
// https://github.com/tconkling/react-objc/blob/master/LICENSE

#import "RAStringReactor.h"

@interface RAStringValue : RAStringReactor {
@protected
    NSString *_value;
}

@property(nonatomic,readwrite) NSString *value;
- (instancetype)init;
- (instancetype)initWithValue:(NSString *)value;
@end
