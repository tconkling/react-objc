//
// react-objc

#import <XCTest/XCTest.h>
#import "RAFuture.h"
#import "Counter.h"
#import "RAPromise.h"
#import "RAMultiFailureError.h"

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

- (void)testSequenceImmediate {
    FutureCounter *counter = [FutureCounter create];

    RAFuture *success1 = [RAFuture successWithValue:@"Yay 1!"];
    RAFuture *success2 = [RAFuture successWithValue:@"Yay 2!"];

    RAFuture *failure1 = [RAFuture failureWithCause:@"Boo 1!"];
    RAFuture *failure2 = [RAFuture failureWithCause:@"Boo 2!"];

    RAFuture *sucseq = [RAFuture sequence:@[success1, success2]];
    [counter bind:sucseq];
    [sucseq onSuccess:^(id results) {
        XCTAssertEqualObjects((@[@"Yay 1!", @"Yay 2!"]), results);
    }];
    CHECK_FCOUNTER(counter, @"immediate seq success/success", 1, 0, 1);

    [counter bind:[RAFuture sequence:@[success1, failure1]]];
    CHECK_FCOUNTER(counter, @"immediate seq success/failure", 0, 1, 1);

    [counter bind:[RAFuture sequence:@[failure1, success2]]];
    CHECK_FCOUNTER(counter, @"immediate seq failure/success", 0, 1, 1);

    [counter bind:[RAFuture sequence:@[failure1, failure2]]];
    CHECK_FCOUNTER(counter, @"immediate seq failure/failure", 0, 1, 1);
}

- (void)testSequenceDeferred {
    FutureCounter *counter = [FutureCounter create];

    RAPromise *success1 = [RAPromise create];
    RAPromise *success2 = [RAPromise create];
    RAPromise *failure1 = [RAPromise create];
    RAPromise *failure2 = [RAPromise create];

    RAFuture *suc2seq = [RAFuture sequence:@[success1, success2]];
    [counter bind:suc2seq];
    [suc2seq onSuccess:^(id results) {
        XCTAssertEqualObjects((@[@"Yay 1!", @"Yay 2!"]), results);
    }];
    CHECK_FCOUNTER(counter, @"before seq succeed/succeed", 0, 0, 0);
    [success1 succeedWithValue:@"Yay 1!"];
    [success2 succeedWithValue:@"Yay 2!"];
    CHECK_FCOUNTER(counter, @"after seq succeed/succeed", 1, 0, 1);

    RAFuture *sucfailseq = [RAFuture sequence:@[success1, failure1]];
    [sucfailseq onFailure:^(id cause) {
        XCTAssert([cause isKindOfClass:[RAMultiFailureError class]]);
        RAMultiFailureError *err = (RAMultiFailureError *)cause;
        XCTAssertEqualObjects(@"1 failures: Boo 1!", err.description);
    }];
    [counter bind:sucfailseq];
    CHECK_FCOUNTER(counter, @"before seq succeed/fail", 0, 0, 0);
    [failure1 failWithCause:@"Boo 1!"];
    CHECK_FCOUNTER(counter, @"after seq succeed/fail", 0, 1, 1);

    RAFuture *failsucseq = [RAFuture sequence:@[failure1, success2]];
    [failsucseq onFailure:^(id cause) {
        XCTAssert([cause isKindOfClass:[RAMultiFailureError class]]);
        RAMultiFailureError *err = (RAMultiFailureError *)cause;
        XCTAssertEqualObjects(@"1 failures: Boo 1!", err.description);
    }];
    [counter bind:failsucseq];
    CHECK_FCOUNTER(counter, @"after seq fail/succeed", 0, 1, 1);

    RAFuture *fail2seq = [RAFuture sequence:@[failure1, failure2]];
    [fail2seq onFailure:^(id cause) {
        XCTAssert([cause isKindOfClass:[RAMultiFailureError class]]);
        RAMultiFailureError *err = (RAMultiFailureError *)cause;
        XCTAssertEqualObjects(@"2 failures: Boo 1!, Boo 2!", err.description);
    }];
    [counter bind:fail2seq];
    CHECK_FCOUNTER(counter, @"before seq fail/fail", 0, 0, 0);
    [failure2 failWithCause:@"Boo 2!"];
    CHECK_FCOUNTER(counter, @"after seq fail/fail", 0, 1, 1);
}

- (void)testSequenceEmpty {
    FutureCounter *counter = [FutureCounter create];
    RAFuture *seq = [RAFuture sequence:@[]];
    [counter bind:seq];
    CHECK_FCOUNTER(counter, @"sequence empty list succeed", 1, 0, 1);
}

@end
