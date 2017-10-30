//
//  JRPCProxyErrorTests.m
//  JRPCProxyTests
//
//  Created on: 08/10/2017
//

/* The MIT License (MIT)
 *
 * Copyright (c) 2017 YouView Ltd
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of
 * this software and associated documentation files (the "Software"), to deal in
 * the Software without restriction, including without limitation the rights to
 * use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
 * the Software, and to permit persons to whom the Software is furnished to do so,
 * subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
 * FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
 * COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
 * IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import "JRPCProxyTestsBase.h"
#import "JRPCError.h"

/**
 Test cases for JSON-RPC proxy error handling
 */
@interface JRPCProxyErrorTests : JRPCProxyTestsBase
@end

// This is the protocol being proxied by the SUT ...
@protocol JRPCProxyErrorTestsProtocol
- (void) methodNotStubbedWithString:(NSString*)string completion:(void (^)(NSString *result, NSError *error))completion;
- (void) methodReturnsErrorNotIntWithCompletion:(void (^)(int result, NSError *error))completion;
- (void) methodReturnsErrorNotDoubleWithCompletion:(void (^)(double result, NSError *error))completion;
@end
// ... so we declare conformance to the protocol by the SUT to satisfy the compiler
@interface JRPCAbstractProxy() <JRPCProxyErrorTestsProtocol>
@end

@implementation JRPCProxyErrorTests

- (void)setUp {
    self.protocol = @protocol(JRPCProxyErrorTestsProtocol);
    self.paramsStructure = JRPCParameterStructureByName;
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

#pragma mark - Tests

- (void) testMethodNotFoundError {
    XCTWaiter *waiter = [[XCTWaiter alloc] initWithDelegate:self];
    XCTestExpectation *expectation = [self expectationWithDescription:@"json-rpc string expectation"];
    [self.SUT methodNotStubbedWithString:@"foo" completion:^(NSString *result, NSError *error) {
        XCTAssertNil(result);
        XCTAssertNotNil(error);
        XCTAssertEqualObjects(error.domain, JRPCErrorDomain);
        XCTAssertEqual(error.code, JRPCErrorServerResponseCode);
        XCTAssertEqual([error.userInfo[kJRPCErrorCodeKey] integerValue], JSONRPCErrorCodeMethodNotFound);
        [expectation fulfill];
    }];
    [waiter waitForExpectations:@[expectation] timeout:60.0];
}

- (void) testMethodReturnsErrorNotInt {
    XCTWaiter *waiter = [[XCTWaiter alloc] initWithDelegate:self];
    XCTestExpectation *expectation = [self expectationWithDescription:@"json-rpc string expectation"];
    [self.SUT methodReturnsErrorNotIntWithCompletion:^(int result, NSError *error) {
        XCTAssertEqual(result, 0);
        XCTAssertNotNil(error);
        XCTAssertEqualObjects(error.domain, JRPCErrorDomain);
        XCTAssertEqual(error.code, JRPCErrorServerResponseCode);
        XCTAssertEqual([error.userInfo[kJRPCErrorCodeKey] integerValue], -32000);
        [expectation fulfill];
    }];
    [waiter waitForExpectations:@[expectation] timeout:60.0];
}

- (void) testMethodReturnsErrorNotDouble {
    XCTWaiter *waiter = [[XCTWaiter alloc] initWithDelegate:self];
    XCTestExpectation *expectation = [self expectationWithDescription:@"json-rpc string expectation"];
    [self.SUT methodReturnsErrorNotDoubleWithCompletion:^(double result, NSError *error) {
        XCTAssertEqual(result, 0.0);
        XCTAssertNotNil(error);
        XCTAssertEqualObjects(error.domain, JRPCErrorDomain);
        XCTAssertEqual(error.code, JRPCErrorServerResponseCode);
        XCTAssertEqual([error.userInfo[kJRPCErrorCodeKey] integerValue], -32001);
        [expectation fulfill];
    }];
    [waiter waitForExpectations:@[expectation] timeout:60.0];
}

@end
