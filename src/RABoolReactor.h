//
// react-objc - a library for functional-reactive-like programming
// https://github.com/tconkling/react-objc/blob/master/LICENSE

#import "RAReactor.h"

@interface RABoolReactor : RAReactor
/** @name Connection */

/** Connects the given block to receive emissions from this signal at the default priority.  */
- (RAConnection *)connectSlot:(RABoolSlot)block;

/** Connects the given block at the given priority.  */
- (RAConnection *)withPriority:(int)priority connectSlot:(RABoolSlot)block;
@end
