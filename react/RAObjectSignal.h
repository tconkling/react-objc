//
// react-objc - a library for functional-reactive-like programming
// https://github.com/tconkling/react-objc/blob/master/LICENSE

#import "RAObjectReactor.h"

@interface RAObjectSignal : RAObjectReactor
/** Emits the supplied value to all connected slots. */
- (void)emitEvent:(id)event;
@end
