//
// react-objc - a library for functional-reactive-like programming
// https://github.com/tconkling/react-objc/blob/master/LICENSE

#import <Foundation/Foundation.h>
#define RA_DEFAULT_PRIORITY 0

typedef void (^RAUnitBlock)(void);
typedef void (^RABoolSlot)(BOOL);
typedef void (^RADoubleSlot)(double);
typedef void (^RAObjectSlot)(id);
typedef void (^RAFloatSlot)(float);
typedef void (^RAIntSlot)(int);
typedef void (^RAStringSlot)(NSString *);
