//
// react-objc - a library for functional-reactive-like programming
// https://github.com/tconkling/react-objc/blob/master/LICENSE

#import "RAStringReactor.h"

@interface RAStringValue : RAStringReactor {
@protected
    NSString *_value;
}

@property(nonatomic,readwrite) NSString *value;
- (id)init;
- (id)initWithValue:(NSString *)value;
@end
