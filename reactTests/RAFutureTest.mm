//
// react-objc

#import <XCTest/XCTest.h>
#import "RAFuture.h"
#import "Counter.h"
#import "RAPromise.h"

@interface FutureCounter : NSObject
@property (nonatomic) Counter *successes;
@property (nonatomic) Counter *failures;
@property (nonatomic) Counter *completes;
@end

@implementation FutureCounter
+ (instancetype)create {
    return [[FutureCounter alloc] init];
}

- (instancetype)init {
    if ((self = [super init])) {
        self.successes = [[Counter alloc] init];
        self.failures = [[Counter alloc] init];
        self.completes = [[Counter alloc] init];
    }
    return self;
}

- (void)reset {
    [self.successes reset];
    [self.failures reset];
    [self.completes reset];
}

- (void)bind:(RAFuture *)future {
    [self reset];
    [future onSuccess:self.successes.triggerer];
    [future onFailure:self.failures.triggerer];
    [future onComplete:self.completes.triggerer];
}

@end

#define CHECK_FCOUNTER(futureCounter, stateName, scount, fcount, ccount)            \
    CHECK_COUNTER(futureCounter.successes, scount, @"Successes: '%@'", stateName);  \
    CHECK_COUNTER(futureCounter.failures, fcount, @"Failures: '%@'", stateName);    \
    CHECK_COUNTER(futureCounter.completes, ccount, @"Completes: '%@'", stateName)

static id (^NON_NULL)(id) = ^id (id value) {
    return @(value != nil);
};

static NSException * CreateException (NSString *description) {
    return [NSException exceptionWithName:NSGenericException reason:description userInfo:nil];
}

@interface RAFutureTest : XCTestCase
@end

@implementation RAFutureTest

- (void)testImmediate {
    FutureCounter *counter = [FutureCounter create];
    RAFuture *success = [RAFuture successWithValue:@"Yay!"];
    [counter bind:success];
    CHECK_FCOUNTER(counter, @"immediate succeed", 1, 0, 1);

    RAFuture *failure = [RAFuture failureWithCause:CreateException(@"Boo!")];
    [counter bind:failure];
    CHECK_FCOUNTER(counter, @"immediate failure", 0, 1, 1);
}

- (void)testDeferred {
    FutureCounter *counter = [FutureCounter create];

    RAPromise *success = [RAPromise create];
    [counter bind:success];
    CHECK_FCOUNTER(counter, @"before succeed", 0, 0, 0);
    [success succeedWithValue:@"Yay!"];
    CHECK_FCOUNTER(counter, @"after succeed", 1, 0, 1);

    RAPromise *failure = [RAPromise create];
    [counter bind:failure];
    CHECK_FCOUNTER(counter, @"before fail", 0, 0, 0);
    [failure failWithCause:CreateException(@"Boo!")];
    CHECK_FCOUNTER(counter, @"after fail", 0, 1, 1);
}

- (void)testMappedImmediate {
    FutureCounter *counter = [FutureCounter create];

    RAFuture *success = [RAFuture successWithValue:@"Yay!"];
    [counter bind:[success map:NON_NULL]];
    CHECK_FCOUNTER(counter, @"immediate succeed", 1, 0, 1);

    RAFuture *failure = [RAFuture failureWithCause:CreateException(@"Boo!")];
    [counter bind:[failure map:NON_NULL]];
    CHECK_FCOUNTER(counter, @"immediate failure", 0, 1, 1);
}

- (void)testMappedDeferred {
    FutureCounter *counter = [FutureCounter create];

    RAPromise *success = [RAPromise create];
    [counter bind:[success map:NON_NULL]];
    CHECK_FCOUNTER(counter, @"before succeed", 0, 0, 0);
    [success succeedWithValue:@"Yay!"];
    CHECK_FCOUNTER(counter, @"after succeed", 1, 0, 1);

    RAPromise *failure = [RAPromise create];
    [counter bind:[failure map:NON_NULL]];
    CHECK_FCOUNTER(counter, @"before fail", 0, 0, 0);
    [failure failWithCause:CreateException(@"Boo!")];
    CHECK_FCOUNTER(counter, @"after fail", 0, 1, 1);

    XCTAssertFalse(success.hasConnections);
    XCTAssertFalse(failure.hasConnections);
}

- (void)testFlatMappedImmediate {
    FutureCounter *scounter = [FutureCounter create];
    FutureCounter *fcounter = [FutureCounter create];
    FutureCounter *ccounter = [FutureCounter create];

    // NSString* -> RAFuture<BOOL>
    id (^successMap)(NSString *) = ^id (NSString *value) {
        return [RAFuture successWithValue:@(value != nil)];
    };

    // NSString* -> failed RAFuture
    id (^failMap)(NSString *) = ^id (NSString *value) {
        return [RAFuture failureWithCause:CreateException(@"Barzle!")];
    };

    // NSString* -> throw an exception
    id (^crashMap)(NSString *) = ^id (NSString *value) {
        [NSException raise:NSGenericException format:@"Barzle!"];
        return nil;
    };

    RAFuture *success = [RAFuture successWithValue:@"Yay!"];
    [scounter bind:[success flatMap:successMap]];
    [fcounter bind:[success flatMap:failMap]];
    [ccounter bind:[success flatMap:crashMap]];
    CHECK_FCOUNTER(scounter, @"immediate success/success", 1, 0, 1);
    CHECK_FCOUNTER(fcounter, @"immediate success/failure", 0, 1, 1);
    CHECK_FCOUNTER(ccounter, @"immediate success/crash", 0, 1, 1);

    RAFuture *failure = [RAFuture failureWithCause:CreateException(@"Boo!")];
    [scounter bind:[failure flatMap:successMap]];
    [fcounter bind:[failure flatMap:failMap]];
    [ccounter bind:[failure flatMap:crashMap]];
    CHECK_FCOUNTER(scounter, @"immediate failure/success", 0, 1, 1);
    CHECK_FCOUNTER(fcounter, @"immediate failure/failure", 0, 1, 1);
    CHECK_FCOUNTER(ccounter, @"immediate failure/crash", 0, 1, 1);
}

- (void)testFlatMappedDeferred {
    FutureCounter *scounter = [FutureCounter create];
    FutureCounter *fcounter = [FutureCounter create];

    // NSString* -> RAFuture<BOOL>
    id (^successMap)(NSString *) = ^id (NSString *value) {
        return [RAFuture successWithValue:@(value != nil)];
    };

    // NSString* -> failed RAFuture
    id (^failMap)(NSString *) = ^id (NSString *value) {
        return [RAFuture failureWithCause:CreateException(@"Barzle!")];
    };

    RAPromise *success = [RAPromise create];
    [scounter bind:[success flatMap:successMap]];
    [fcounter bind:[success flatMap:failMap]];
    CHECK_FCOUNTER(scounter, @"before succeed/success", 0, 0, 0);
    CHECK_FCOUNTER(fcounter, @"before succeed/fail", 0, 0, 0);
    [success succeedWithValue:@"Yay!"];
    CHECK_FCOUNTER(scounter, @"after succeed/success", 1, 0, 1);
    CHECK_FCOUNTER(fcounter, @"after succeed/fail", 0, 1, 1);

    RAPromise *failure = [RAPromise create];
    [scounter bind:[failure flatMap:successMap]];
    [fcounter bind:[failure flatMap:failMap]];
    CHECK_FCOUNTER(scounter, @"before fail/success", 0, 0, 0);
    CHECK_FCOUNTER(fcounter, @"before fail/failure", 0, 0, 0);
    [failure failWithCause:CreateException(@"Boo!")];
    CHECK_FCOUNTER(scounter, @"after fail/success", 0, 1, 1);
    CHECK_FCOUNTER(fcounter, @"after fail/failure", 0, 1, 1);

    XCTAssertFalse(success.hasConnections);
    XCTAssertFalse(failure.hasConnections);
}

- (void)testFlatMappedDoubleDeferred {
    FutureCounter *scounter = [FutureCounter create];
    FutureCounter *fcounter = [FutureCounter create];

    {
        RAPromise *success = [RAPromise create];
        RAPromise *innerSuccessSuccess = [RAPromise create];
        [scounter bind:[success flatMap:^RAFuture *(id value) {
            return innerSuccessSuccess;
        }]];
        CHECK_FCOUNTER(scounter, @"before succeed/succeed", 0, 0, 0);

        RAPromise *innerSuccessFailure = [RAPromise create];
        [fcounter bind:[success flatMap:^RAFuture *(id o) {
            return innerSuccessFailure;
        }]];
        CHECK_FCOUNTER(fcounter, @"before succeed/fail", 0, 0, 0);

        [success succeedWithValue:@"Yay!"];
        CHECK_FCOUNTER(scounter, @"after first succeed/succeed", 0, 0, 0);
        CHECK_FCOUNTER(fcounter, @"after first succeed/fail", 0, 0, 0);
        [innerSuccessSuccess succeedWithValue:@YES];
        CHECK_FCOUNTER(scounter, @"after second succeed/succeed", 1, 0, 1);
        [innerSuccessFailure failWithCause:CreateException(@"Boo hoo!")];
        CHECK_FCOUNTER(fcounter, @"after second succeed/fail", 0, 1, 1);

        XCTAssertFalse(success.hasConnections);
        XCTAssertFalse(innerSuccessSuccess.hasConnections);
        XCTAssertFalse(innerSuccessFailure.hasConnections);
    }
    
    {
        RAPromise *failure = [RAPromise create];
        RAPromise *innerFailureSuccess = [RAPromise create];
        [scounter bind:[failure flatMap:^RAFuture *(id value) {
            return innerFailureSuccess;
        }]];
        CHECK_FCOUNTER(scounter, @"before fail/succeed", 0, 0, 0);

        RAPromise *innerFailureFailure = [RAPromise create];
        [fcounter bind:[failure flatMap:^RAFuture *(id o) {
            return innerFailureFailure;
        }]];
        CHECK_FCOUNTER(fcounter, @"before fail/fail", 0, 0, 0);

        [failure failWithCause:CreateException(@"Boo!")];
        CHECK_FCOUNTER(scounter, @"after first fail/succeed", 0, 1, 1);
        CHECK_FCOUNTER(fcounter, @"after first fail/fail", 0, 1, 1);
        [innerFailureSuccess succeedWithValue:@YES];
        CHECK_FCOUNTER(scounter, @"after second fail/succeed", 0, 1, 1);
        [innerFailureFailure failWithCause:CreateException(@"Is this thing on?")];
        CHECK_FCOUNTER(fcounter, @"after second fail/fail", 0, 1, 1);

        XCTAssertFalse(failure.hasConnections);
        XCTAssertFalse(innerFailureSuccess.hasConnections);
        XCTAssertFalse(innerFailureFailure.hasConnections);
    }
}

@end
