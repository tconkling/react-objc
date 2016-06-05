//
// react-objc - a library for functional-reactive-like programming
// https://github.com/tconkling/react-objc/blob/master/LICENSE

#import "RAStringReactor.h"

@interface RAStringSignal : RAStringReactor
/** Emits the supplied value to all connected slots. */
- (void)emitEvent:(NSString *)event;
@end
