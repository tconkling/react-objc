//
// react-objc - a library for functional-reactive-like programming
// https://github.com/tconkling/react-objc/blob/master/LICENSE

#import "RAIntReactor.h"

@interface RAIntSignal : RAIntReactor
/** Emits the supplied value to all connected slots. */
- (void)emitEvent:(int)event;
@end
