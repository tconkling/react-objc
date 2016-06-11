//
// react-objc - a library for functional-reactive-like programming
// https://github.com/tconkling/react-objc/blob/master/LICENSE

#import "RAReactor.h"
#import "RAReactor+Protected.h"
#import "RAConnection.h"

@interface PostDispatchAction : NSObject {
@public
    void (^action)();
    PostDispatchAction *next;
}
@end

@implementation PostDispatchAction

- (instancetype)initWithAction:(void (^)())postAction {
    if ((self = [super init])) {
        self->action = [postAction copy];
    }
    return self;
}

- (void)insertAction:(void (^)())newAction {
    if (next) {
        [next insertAction:newAction];
    } else {
        next = [[PostDispatchAction alloc] initWithAction:newAction];
    }
}
@end

@interface RAReactor () {
    RAConnection *_listeners;
    PostDispatchAction *_pendingActions;
}
@end

static void insertConn (RAConnection *conn,  RAConnection *head) {
    if (head->next && head->next->priority >= conn->priority) insertConn(conn, head->next);
    else {
        conn->next = head->next;
        head->next = conn;
    }
}

@implementation RAReactor

- (BOOL)hasConnections {
    return (_listeners != nil);
}

- (BOOL)isEmitting {
    return (_pendingActions != nil);
}

- (void)insertConn:(RAConnection *)conn {
    @synchronized (self) {
        if (!_listeners || conn->priority > _listeners->priority) {
            conn->next = _listeners;
            _listeners = conn;
        } else {
            insertConn(conn, _listeners);
        }
    }
}

- (void)removeConn:(RAConnection *)conn {
    @synchronized (self) {
        if (_listeners == nil) {
            return;
        } else if (conn == _listeners) {
            _listeners = _listeners->next;
            return;
        }

        RAConnection *prev = _listeners;
        for (RAConnection *cur = _listeners->next; cur != nil; cur = cur->next) {
            if (cur == conn) {
                prev->next = cur->next;
                return;
            }
            prev = cur;
        }
    }
}

- (void)disconnect:(RAConnection *)conn {
    @synchronized (self) {
        if (RA_IS_CONNECTED(conn)) {
            // mark the connection as disconnected by nilling out the reactor reference
            conn->reactor = nil;

            if (self.isEmitting) {
                __weak typeof(self) weakSelf = self;
                [_pendingActions insertAction:^{
                    typeof(self) strongSelf = weakSelf;
                    [strongSelf removeConn:conn];
                    [strongSelf connectionRemoved];
                }];
            } else {
                [self removeConn:conn];
                [self connectionRemoved];
            }
        }
    }
}

- (void)disconnectAll {
    @synchronized (self) {
        for (RAConnection *cur = _listeners; cur != nil; cur = cur->next) {
            cur->reactor = nil;
        }

        if (self.isEmitting) {
            __weak typeof(self) weakSelf = self;
            [_pendingActions insertAction:^{
                typeof(self) strongSelf = weakSelf;
                if (strongSelf->_listeners != nil) {
                    strongSelf->_listeners = nil;
                    [strongSelf connectionRemoved];
                }
            }];
        } else {
            if (_listeners != nil) {
                _listeners = nil;
                [self connectionRemoved];
            }
        }
    }
}

- (RAConnection *)connectUnit:(void (^)())slot {
    RA_IS_ABSTRACT();
}

- (RAConnection *)withPriority:(int)priority connectUnit:(void (^)())slot {
    RA_IS_ABSTRACT();
}

@end

@implementation RAReactor (Protected)

- (RAConnection *)addConnection:(RAConnection *)connection {
    @synchronized (self) {
        if (self.isEmitting) {
            __weak typeof(self) weakSelf = self;
            [_pendingActions insertAction:^{
                typeof(self) strongSelf = weakSelf;
                // ensure the connection hasn't already been disconnected
                if (RA_IS_CONNECTED(connection)) {
                    [strongSelf insertConn:connection];
                    [strongSelf connectionAdded];
                }
            }];
        } else {
            [self insertConn:connection];
            [self connectionAdded];
        }

        return connection;
    }
}
- (RAConnection *)prepareForEmission {
    @synchronized (self) {
        NSAssert(!self.isEmitting, @"Asked to emit while emission in progress");
        _pendingActions = [[PostDispatchAction alloc] initWithAction:^{
            // Intentionally empty
        }];
        return _listeners;
    }
}

- (void)finishEmission {
    @synchronized (self) {
        NSAssert(self.isEmitting, @"Emission not in progress");
        for (; _pendingActions != nil; _pendingActions = _pendingActions->next) {
            _pendingActions->action();
        }
        _pendingActions = nil;
    }
}

- (void)connectionAdded {
}

- (void)connectionRemoved {
}

@end
