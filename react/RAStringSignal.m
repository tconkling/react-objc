//
// react-objc - a library for functional-reactive-like programming
// https://github.com/tconkling/react-objc/blob/master/LICENSE

#import "RAStringSignal.h"
#import "RAStringReactor+Protected.h"

@implementation RAStringSignal
- (void)emitEvent:(NSString *)event {
    [self dispatchEvent:event];
}
@end
