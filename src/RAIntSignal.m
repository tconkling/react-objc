//
// react-objc - a library for functional-reactive-like programming
// https://github.com/tconkling/react-objc/blob/master/LICENSE

#import "RAIntSignal.h"
#import "RAIntReactor+Protected.h"

@implementation RAIntSignal
- (void)emitEvent:(int)event {
    [self dispatchEvent:event];
}
@end
