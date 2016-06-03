//
// react-objc - a library for functional-reactive-like programming
// https://github.com/tconkling/react-objc/blob/master/LICENSE

#import "RAFloatSignal.h"
#import "RAFloatReactor+Protected.h"

@implementation RAFloatSignal
- (void)emitEvent:(float)event {
    [self dispatchEvent:event];
}
@end
