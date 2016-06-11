//
// react-objc - a library for functional-reactive-like programming
// https://github.com/tconkling/react-objc/blob/master/LICENSE

#import "RAObjectSignal.h"
#import "RAObjectReactor+Protected.h"
#import "RAMappedSignal.h"
#import "RAConnection.h"

@implementation RAObjectSignal

- (void)emitEvent:(id)event {
    [self dispatchEvent:event];
}

- (RAObjectSignal *)map:(id (^)(id value))func {
    __block RAConnection *conn;
    __weak typeof(self) weakSelf = self;
    return [[RAMappedSignal alloc]
        initWithConnector:^(RAMappedSignal *signal) {
            typeof(self) strongSelf = weakSelf;
            conn = [strongSelf connect:^(id o) {
                [signal emitEvent:func(o)];
            }];

        } disconnector:^(RAMappedSignal *signal) {
            [conn disconnect];
            conn = nil;
        }];
}

@end
