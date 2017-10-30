//
//  JRPCProxySerializationTests.m
//  JRPCProxyTests
//
//  Created on: 14/10/2017
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

@interface JRPCProxySerializationTests : JRPCProxyTestsBase
@end

// This is the protocol being proxied by the SUT ...
@protocol JRPCProxySerializationTestsProtocol
- (void) echoString:(NSString*)string :(void (^)(NSString *result, NSError *error))completion;
@end
// ... so we declare conformance to the protocol by the SUT to satisfy the compiler
@interface JRPCAbstractProxy() <JRPCProxySerializationTestsProtocol>
@end

@implementation JRPCProxySerializationTests

- (void)setUp {
    self.protocol = @protocol(JRPCProxySerializationTestsProtocol);
    self.paramsStructure = JRPCParameterStructureByPosition;
    self.transportStubPerformsSerialization = YES;
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

#pragma mark - Tests

- (void) testTransportPerformsSerialization {
    // Same as testEchoWithString test but we tell the transport stub to perform serialization
    XCTWaiter *waiter = [[XCTWaiter alloc] initWithDelegate:self];
    XCTestExpectation *expectation = [self expectationWithDescription:@"json-rpc string expectation"];
    __weak typeof(self) wSelf = self;
    NSString *echoVal = @"Hello World!";
    [wSelf.SUT echoString:echoVal :^(NSString* result, NSError *error) {
        XCTAssertEqualObjects(echoVal, result);
        [expectation fulfill];
    }];
    [waiter waitForExpectations:@[expectation] timeout:60.0];
}

@end
