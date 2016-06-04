//
// react-objc - a library for functional-reactive-like programming
// https://github.com/tconkling/react-objc/blob/master/LICENSE

#import "RADoubleSignal.h"
#import "RADoubleReactor+Protected.h"

@implementation RADoubleSignal
- (void)emitEvent:(double)event {
    [self dispatchEvent:event];
}
@end
