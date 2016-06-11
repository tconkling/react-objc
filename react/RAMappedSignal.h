//
// react

#import <Foundation/Foundation.h>
#import "RAObjectSignal.h"

/**
 * Plumbing to implement mapped signals in such a way that they automatically manage a connection
 * to some underlying signal or event. When the mapped signal adds its first connection,
 * it establishes a connection to its underlying object, and when it removes its last connection
 * it clears that connection.
 */
@interface RAMappedSignal : RAObjectSignal

/**
 * Create a new mapped signal.
 *
 * @param connector a block that will be called when this signal goes from 0 to 1 listeners.
 * It should establish a connection with the underlying signal or event.
 *
 * @param disconnector a block that will be called when this signal no longer has any listeners.
 * It should disconnect the connection that was established by the connector.
 */
- (instancetype)initWithConnector:(void (^)(RAMappedSignal *thisSignal))connector
                     disconnector:(void (^)(RAMappedSignal *thisSignal))disconnector;

@end
