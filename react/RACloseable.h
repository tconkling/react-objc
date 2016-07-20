//
// react-objc - a library for functional-reactive-like programming
// https://github.com/tconkling/react-objc/blob/master/LICENSE

#import <Foundation/Foundation.h>

/** A resource that can be closed. */
@protocol RACloseable <NSObject>
- (void)close;
@end
