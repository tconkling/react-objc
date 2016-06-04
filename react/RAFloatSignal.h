//
// react-objc - a library for functional-reactive-like programming
// https://github.com/tconkling/react-objc/blob/master/LICENSE

#import "RAFloatReactor.h"

@interface RAFloatSignal : RAFloatReactor
/** @name Emission */

/** Emits the supplied value to all connected slots. */
- (void)emitEvent:(float)event;
@end
