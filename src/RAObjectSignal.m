//
// react-objc - a library for functional-reactive-like programming
// https://github.com/tconkling/react-objc/blob/master/LICENSE

#import "RAObjectSignal.h"
#import "RAObjectReactor+Protected.h"

@implementation RAObjectSignal
- (void)emitEvent:(id)event {
    [self dispatchEvent:event];
}
@end
