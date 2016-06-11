//
// react-objc - a library for functional-reactive-like programming
// https://github.com/tconkling/react-objc/blob/master/LICENSE

#import "RAObjectReactor.h"

@interface RAObjectSignal : RAObjectReactor

/** Emits the supplied value to all connected slots. */
- (void)emitEvent:(id)event;

/** Creates an RAMappedSignal that re-emits mapped versions of this signal's events. */
- (RAObjectSignal *)map:(id (^)(id value))func;

@end
