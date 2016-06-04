//
// react-objc - a library for functional-reactive-like programming
// https://github.com/tconkling/react-objc/blob/master/LICENSE

#import "RABoolSignal.h"
#import "RABoolReactor+Protected.h"

@implementation RABoolSignal
- (void)emitEvent:(BOOL)event {
    [self dispatchEvent:event];
}
@end
