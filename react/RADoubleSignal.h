//
// react-objc - a library for functional-reactive-like programming
// https://github.com/tconkling/react-objc/blob/master/LICENSE

#import "RADoubleReactor.h"

@interface RADoubleSignal : RADoubleReactor
/** @name Emission */

/** Emits the supplied value to all connected slots. */
- (void)emitEvent:(double)event;
@end
