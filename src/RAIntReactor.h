//
// react-objc - a library for functional-reactive-like programming
// https://github.com/tconkling/react-objc/blob/master/LICENSE

#import "RAReactor.h"

@interface RAIntReactor : RAReactor
/** @name Connection */

/** Connects the given block to receieve emissions from this signal at the default priority.  */
- (RAConnection*)connectSlot:(RAIntSlot)block;

/** Connects the given block at the given priority.  */
- (RAConnection*)withPriority:(int)priority connectSlot:(RAIntSlot)block;
@end
