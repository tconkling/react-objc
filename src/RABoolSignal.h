//
// react-objc - a library for functional-reactive-like programming
// https://github.com/tconkling/react-objc/blob/master/LICENSE

#import "RABoolReactor.h"

@interface RABoolSignal : RABoolReactor
/** @name Emission */

/** Emits the supplied value to all connected slots. */
- (void)emitEvent:(BOOL)event;
@end
