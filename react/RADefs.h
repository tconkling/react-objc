//
// react-objc - a library for functional-reactive-like programming
// https://github.com/tconkling/react-objc/blob/master/LICENSE

#import <Foundation/Foundation.h>

#define RA_IS_ABSTRACT()                                                            \
    @throw [NSException exceptionWithName:NSInternalInconsistencyException          \
        reason:[NSString stringWithFormat:@"You must override %@ in a subclass",    \
        NSStringFromSelector(_cmd)] userInfo:nil]

#define RA_DEFAULT_PRIORITY 0
