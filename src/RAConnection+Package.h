//
// react-objc - a library for functional-reactive-like programming
// https://github.com/tconkling/react-objc/blob/master/LICENSE

#import "RAConnection.h"

@interface RAConnection (package)
- (id)initWithBlock:(id)block atPriority:(int)priority onReactor:(RAReactor*)reactor;
@end
