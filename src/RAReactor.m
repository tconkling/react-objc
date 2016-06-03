//
// react-objc - a library for functional-reactive-like programming
// https://github.com/tconkling/react-objc/blob/master/LICENSE

#import "RAReactor.h"
#import "RAReactor+Protected.h"
#import "RAConnection.h"

@interface PostDispatchAction : NSObject {
@public
    RAUnitBlock action;
    PostDispatchAction *next;
}
@end

@implementation PostDispatchAction

- (id)initWithAction:(RAUnitBlock)postAction {
    if ((self = [super init])) {
        self->action = [postAction copy];
    }
    return self;
}

- (void)insertAction:(RAUnitBlock)newAction {
    if (next) {
        [next insertAction:newAction];
    } else {
        next = [[PostDispatchAction alloc] initWithAction:newAction];
    }
}
@end

@interface RAReactor () {
    RAConnection *_head;
    PostDispatchAction *_pending;
}
@end

static void insertConn(RAConnection *conn,  RAConnection *head) {
    if (head->next && head->next->priority >= conn->priority) insertConn(conn, head->next);
    else {
        conn->next = head->next;
        head->next = conn;
    }
}

@implementation RAReactor

- (void)insertConn:(RAConnection *)conn {
    @synchronized (self) {
        if (!_head || conn->priority > _head->priority) {
            conn->next = _head;
            _head = conn;
        } else {
            insertConn(conn, _head);
        }
    }
}

- (void)removeConn:(RAConnection *)conn {
    @synchronized (self) {
        if (_head == nil) {
            return;
        } else if (conn == _head) {
            _head = _head->next;
            return;
        }

        RAConnection *prev = _head;
        for (RAConnection *cur = _head->next; cur != nil; cur = cur->next) {
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

            if (_pending != nil) {
                [_pending insertAction:^{
                    [self removeConn:conn];
                }];
            } else {
                [self removeConn:conn];
            }
        }
    }
}

- (void)disconnectAll {
    @synchronized (self) {
        for (RAConnection *cur = _head; cur != nil; cur = cur->next) {
            cur->reactor = nil;
        }

        if (_pending != nil) {
            [_pending insertAction:^{
                self->_head = nil;
            }];
        } else {
            _head = nil;
        }
    }
}

- (RAConnection *)connectUnit:(RAUnitBlock)block {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
        reason:[NSString stringWithFormat:@"You must override %@ in a subclass",
        NSStringFromSelector(_cmd)] userInfo:nil];
}

- (RAConnection *)withPriority:(int)priority connectUnit:(RAUnitBlock)block {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
        reason:[NSString stringWithFormat:@"You must override %@ in a subclass",
        NSStringFromSelector(_cmd)] userInfo:nil];
}

@end

@implementation RAReactor (Protected)

- (RAConnection *)connectConnection:(RAConnection*)connection {
    @synchronized (self) {
        if (_pending != nil) {
            [_pending insertAction:^{
                // ensure the connection hasn't already been disconnected
                if (RA_IS_CONNECTED(connection)) {
                    [self insertConn:connection];
                }
            }];
        } else {
            [self insertConn:connection];
        }

        return connection;
    }
}
- (RAConnection *)prepareForEmission {
    @synchronized (self) {
        NSAssert(_pending == nil, @"Asked to emit while emission in progress");
        _pending = [[PostDispatchAction alloc] initWithAction:^{
            // Intentionally empty
        }];
        return _head;
    }
}

- (void)finishEmission {
    @synchronized (self) {
        for (; _pending != nil; _pending = _pending->next) {
            _pending->action();
        }
        _pending = nil;
    }
}

@end
