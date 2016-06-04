//
// react-objc - a library for functional-reactive-like programming
// https://github.com/tconkling/react-objc/blob/master/LICENSE

#import "RAReactor.h"

@interface RAObjectReactor : RAReactor
/** Connects the given block to receive emissions from this signal at the default priority.  */
- (RAConnection *)connect:(void (^)(id))slot;

/** Connects the given block at the given priority.  */
- (RAConnection *)withPriority:(int)priority connect:(void (^)(id))slot;
@end
