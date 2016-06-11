//
// react

#import "RAMappedSignal.h"
#import "RAReactor+Protected.h"

@interface RAMappedSignal () {
    void (^_connector)(RAMappedSignal *);
    void (^_disconnector)(RAMappedSignal *);
    BOOL _isConnected;
}
@end

@implementation RAMappedSignal

- (instancetype)initWithConnector:(void (^)(RAMappedSignal *))connector
                     disconnector:(void (^)(RAMappedSignal *))disconnector {
    if ((self = [super init])) {
        _connector = [connector copy];
        _disconnector = [disconnector copy];
    }
    return self;
}

- (void)connectionAdded {
    [super connectionAdded];

    @synchronized (self) {
        if (!_isConnected) {
            _connector(self);
            _isConnected = YES;
        }
    }
}

- (void)connectionRemoved {
    [super connectionRemoved];

    @synchronized (self) {
        if (_isConnected && !self.hasConnections) {
            _disconnector(self);
            _isConnected = NO;
        }
    }
}

@end
