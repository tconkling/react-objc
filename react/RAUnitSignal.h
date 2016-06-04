//
// react-objc - a library for functional-reactive-like programming
// https://github.com/tconkling/react-objc/blob/master/LICENSE

#import <Foundation/Foundation.h>
#import "RAReactor.h"

/** Emits events with no corresponding data. */
@interface RAUnitSignal : RAReactor

/** Invokes all connected blocks. */
- (void)emit;

/** Connects the given block to be called on future emissions. */
- (RAConnection *)connectUnit:(void (^)())block;

/** Connects the given block at the given priority to receive future emissions. */
- (RAConnection *)withPriority:(int)priority connectUnit:(void (^)())block;
@end
