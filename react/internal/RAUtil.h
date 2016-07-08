//
// react

#import <Foundation/Foundation.h>

static id RANilToNSNull(id obj) { return (obj == nil ? [NSNull null] : obj); }
