//
// react-objc - a library for functional-reactive-like programming
// https://github.com/tconkling/react-objc/blob/master/LICENSE

#import <Foundation/Foundation.h>
#import "RAStringReactor.h"

@interface RAStringReactor (Protected)
- (void)dispatchEvent:(NSString *)event;
@end
