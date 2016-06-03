//
// react-objc - a library for functional-reactive-like programming
// https://github.com/tconkling/react-objc/blob/master/LICENSE

#import "RAConnection.h"

@interface RAConnection (package)
- (instancetype)initWithBlock:(id)newBlock atPriority:(int)newPriority onReactor:(RAReactor *)newReactor;
@end
