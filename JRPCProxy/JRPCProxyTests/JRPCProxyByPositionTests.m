//
//  JRPCProxyByPositionTests.m
//  JRPCProxyTests
//
//  Created on 07/10/2017.
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

/**
 Test cases for JSON-RPC with 'by-position' parameter structure
 */
@interface JRPCProxyByPositionTests : JRPCProxyTestsBase
@end

// This is the protocol being proxied by the SUT ...
@protocol JRPCProxyByPositionTestsProtocol
- (void) methodTakesNoParamsReturnsHelloWorldString:(void (^)(NSString *result, NSError *error))completion;
- (void) appendStrings:(NSString*)string1 :(NSString*)string2 :(void (^)(NSString *result, NSError *error))completion;
- (void) addIntegers:(NSInteger)first :(NSInteger)second :(void (^)(NSInteger result, NSError *error))completion;
- (void) returnTransformable:(NSString*)stringVal :(NSUInteger)uintVal :(void (^)(JRPCTestTransformableResult* result, NSError *error))completion;
- (void) echoBool:(_Bool)value :(void (^)(_Bool result, NSError *error))completion;
- (void) echoChar:(char)value :(void (^)(char result, NSError *error))completion;
- (void) echoShort:(short)value :(void (^)(short result, NSError *error))completion;
- (void) echoInt:(int)value :(void (^)(int result, NSError *error))completion;
- (void) echoLong:(long)value :(void (^)(long result, NSError *error))completion;
- (void) echoInteger:(NSInteger)value :(void (^)(NSInteger result, NSError *error))completion;
- (void) echoUnsignedChar:(unsigned char)value :(void (^)(unsigned char result, NSError *error))completion;
- (void) echoUnsignedShort:(unsigned short)value :(void (^)(unsigned short result, NSError *error))completion;
- (void) echoUnsignedInt:(unsigned int)value :(void (^)(unsigned int result, NSError *error))completion;
- (void) echoUnsignedLong:(unsigned long)value :(void (^)(unsigned long result, NSError *error))completion;
- (void) echoUnsignedInteger:(NSUInteger)value :(void (^)(NSUInteger result, NSError *error))completion;
- (void) echoFloat:(float)value :(void (^)(float result, NSError *error))completion;
- (void) echoDouble:(double)value :(void (^)(double result, NSError *error))completion;
- (void) echoString:(NSString*)value :(void (^)(NSString *result, NSError *error))completion;
- (void) echoTransformable:(JRPCTestTransformableResult*)value :(void (^)(JRPCTestTransformableResult *result, NSError *error))completion;
@end
// ... so we declare conformance to the protocol by the SUT to satisfy the compiler
@interface JRPCAbstractProxy() <JRPCProxyByPositionTestsProtocol>
@end

@implementation JRPCProxyByPositionTests

- (void)setUp {
    self.protocol = @protocol(JRPCProxyByPositionTestsProtocol);
    self.paramsStructure = JRPCParameterStructureByPosition;
    [super setUp];  // Base class initializes SUT
 }

- (void)tearDown {
    [super tearDown];
}

#pragma mark - Tests

- (void) testMethodTakesNoParamsReturnsString {
    XCTWaiter *waiter = [[XCTWaiter alloc] initWithDelegate:self];
    XCTestExpectation *expectation = [self expectationWithDescription:@"json-rpc-expectation"];
    [self.SUT methodTakesNoParamsReturnsHelloWorldString:^(NSString *result, NSError *error) {
        XCTAssertNil(error);
        NSString *expectedStr = @"Hello World!";
        XCTAssertEqualObjects(expectedStr, result);
        [expectation fulfill];
    }];
    [waiter waitForExpectations:@[expectation] timeout:60.0];
}

- (void) testAppendStringsMethod {
    XCTWaiter *waiter = [[XCTWaiter alloc] initWithDelegate:self];
    XCTestExpectation *expectation = [self expectationWithDescription:@"json-rpc-expectation"];
    [self.SUT appendStrings:@"foo" :@"bar" :^(NSString *result, NSError *error) {
        XCTAssertNil(error);
        NSString *expectedStr = @"foobar";
        XCTAssertEqualObjects(expectedStr, result);
        [expectation fulfill];
    }];
    [waiter waitForExpectations:@[expectation] timeout:60.0];
}

- (void) testAddIntegersMethod {
    XCTWaiter *waiter = [[XCTWaiter alloc] initWithDelegate:self];
    XCTestExpectation *expectation = [self expectationWithDescription:@"json-rpc-expectation"];
    __weak typeof(self) wSelf = self;
    [wSelf.SUT addIntegers:10 :32 :^(NSInteger result, NSError *error) {
        NSInteger expectedResult = 42;
        XCTAssertEqual(expectedResult, result);
        [expectation fulfill];
    }];
    [waiter waitForExpectations:@[expectation] timeout:60.0];
}

- (void) testEchoWithBool {
    XCTWaiter *waiter = [[XCTWaiter alloc] initWithDelegate:self];
    XCTestExpectation *expectation = [self expectationWithDescription:@"json-rpc-expectation"];
    __weak typeof(self) wSelf = self;
    _Bool echoVal = -42;
    [wSelf.SUT echoBool:echoVal :^(_Bool result, NSError *error) {
        XCTAssertEqual(echoVal, result);
        [expectation fulfill];
    }];
    [waiter waitForExpectations:@[expectation] timeout:60.0];
}

- (void) testEchoWithChar {
    XCTWaiter *waiter = [[XCTWaiter alloc] initWithDelegate:self];
    XCTestExpectation *expectation = [self expectationWithDescription:@"json-rpc-expectation"];
    __weak typeof(self) wSelf = self;
    char echoVal = -42;
    [wSelf.SUT echoChar:echoVal :^(char result, NSError *error) {
        XCTAssertEqual(echoVal, result);
        [expectation fulfill];
    }];
    [waiter waitForExpectations:@[expectation] timeout:60.0];
}

- (void) testEchoWithShort {
    XCTWaiter *waiter = [[XCTWaiter alloc] initWithDelegate:self];
    XCTestExpectation *expectation = [self expectationWithDescription:@"json-rpc-expectation"];
    __weak typeof(self) wSelf = self;
    short echoVal = -2017;
    [wSelf.SUT echoShort:echoVal :^(short result, NSError *error) {
        XCTAssertEqual(echoVal, result);
        [expectation fulfill];
    }];
    [waiter waitForExpectations:@[expectation] timeout:60.0];
}

- (void) testEchoWithInt {
    XCTWaiter *waiter = [[XCTWaiter alloc] initWithDelegate:self];
    XCTestExpectation *expectation = [self expectationWithDescription:@"json-rpc-expectation"];
    __weak typeof(self) wSelf = self;
    int echoVal = -2000000000;
    [wSelf.SUT echoInt:echoVal :^(int result, NSError *error) {
        XCTAssertEqual(echoVal, result);
        [expectation fulfill];
    }];
    [waiter waitForExpectations:@[expectation] timeout:60.0];
}

- (void) testEchoWithLong {
    XCTWaiter *waiter = [[XCTWaiter alloc] initWithDelegate:self];
    XCTestExpectation *expectation = [self expectationWithDescription:@"json-rpc-expectation"];
    __weak typeof(self) wSelf = self;
    long echoVal = 42;
    [wSelf.SUT echoLong:echoVal :^(long result, NSError *error) {
        XCTAssertEqual(echoVal, result);
        [expectation fulfill];
    }];
    [waiter waitForExpectations:@[expectation] timeout:60.0];
}

- (void) testEchoWithInteger {
    XCTWaiter *waiter = [[XCTWaiter alloc] initWithDelegate:self];
    XCTestExpectation *expectation = [self expectationWithDescription:@"json-rpc-expectation"];
    __weak typeof(self) wSelf = self;
    NSInteger echoVal = -42;
    [wSelf.SUT echoInteger:echoVal :^(NSInteger result, NSError *error) {
        XCTAssertEqual(echoVal, result);
        [expectation fulfill];
    }];
    [waiter waitForExpectations:@[expectation] timeout:60.0];
}

- (void) testEchoWithUnsignedChar {
    XCTWaiter *waiter = [[XCTWaiter alloc] initWithDelegate:self];
    XCTestExpectation *expectation = [self expectationWithDescription:@"json-rpc-expectation"];
    __weak typeof(self) wSelf = self;
    unsigned char echoVal = 42;
    [wSelf.SUT echoUnsignedChar:echoVal :^(unsigned char result, NSError *error) {
        XCTAssertEqual(echoVal, result);
        [expectation fulfill];
    }];
    [waiter waitForExpectations:@[expectation] timeout:60.0];
}

- (void) testEchoWithUnsignedShort {
    XCTWaiter *waiter = [[XCTWaiter alloc] initWithDelegate:self];
    XCTestExpectation *expectation = [self expectationWithDescription:@"json-rpc-expectation"];
    __weak typeof(self) wSelf = self;
    unsigned short echoVal = 2017;
    [wSelf.SUT echoUnsignedShort:echoVal :^(unsigned short result, NSError *error) {
        XCTAssertEqual(echoVal, result);
        [expectation fulfill];
    }];
    [waiter waitForExpectations:@[expectation] timeout:60.0];
}

- (void) testEchoWithUnsignedInt {
    XCTWaiter *waiter = [[XCTWaiter alloc] initWithDelegate:self];
    XCTestExpectation *expectation = [self expectationWithDescription:@"json-rpc-expectation"];
    __weak typeof(self) wSelf = self;
    unsigned int echoVal = 34567;
    [wSelf.SUT echoUnsignedInt:echoVal :^(unsigned int result, NSError *error) {
        XCTAssertEqual(echoVal, result);
        [expectation fulfill];
    }];
    [waiter waitForExpectations:@[expectation] timeout:60.0];
}

- (void) testEchoWithUnsignedLong {
    XCTWaiter *waiter = [[XCTWaiter alloc] initWithDelegate:self];
    XCTestExpectation *expectation = [self expectationWithDescription:@"json-rpc-expectation"];
    __weak typeof(self) wSelf = self;
    unsigned long echoVal = 2000000000;
    [wSelf.SUT echoUnsignedLong:echoVal :^(unsigned long result, NSError *error) {
        XCTAssertEqual(echoVal, result);
        [expectation fulfill];
    }];
    [waiter waitForExpectations:@[expectation] timeout:60.0];
}

- (void) testEchoWithUnsignedInteger {
    XCTWaiter *waiter = [[XCTWaiter alloc] initWithDelegate:self];
    XCTestExpectation *expectation = [self expectationWithDescription:@"json-rpc-expectation"];
    __weak typeof(self) wSelf = self;
    NSUInteger echoVal = 42;
    [wSelf.SUT echoUnsignedInteger:echoVal :^(NSUInteger result, NSError *error) {
        XCTAssertEqual(echoVal, result);
        [expectation fulfill];
    }];
    [waiter waitForExpectations:@[expectation] timeout:60.0];
}

- (void) testEchoWithFloat {
    XCTWaiter *waiter = [[XCTWaiter alloc] initWithDelegate:self];
    XCTestExpectation *expectation = [self expectationWithDescription:@"json-rpc-expectation"];
    __weak typeof(self) wSelf = self;
    float echoVal = M_PI;
    [wSelf.SUT echoFloat:echoVal :^(float result, NSError *error) {
        XCTAssertEqual(echoVal, result);
        [expectation fulfill];
    }];
    [waiter waitForExpectations:@[expectation] timeout:60.0];
}

- (void) testEchoWithDouble {
    XCTWaiter *waiter = [[XCTWaiter alloc] initWithDelegate:self];
    XCTestExpectation *expectation = [self expectationWithDescription:@"json-rpc-expectation"];
    __weak typeof(self) wSelf = self;
    double echoVal = M_PI;
    [wSelf.SUT echoDouble:echoVal :^(double result, NSError *error) {
        XCTAssertEqual(echoVal, result);
        [expectation fulfill];
    }];
    [waiter waitForExpectations:@[expectation] timeout:60.0];
}

- (void) testEchoWithString {
    XCTWaiter *waiter = [[XCTWaiter alloc] initWithDelegate:self];
    XCTestExpectation *expectation = [self expectationWithDescription:@"json-rpc-expectation"];
    __weak typeof(self) wSelf = self;
    NSString *echoVal = @"Hello World!";
    [wSelf.SUT echoString:echoVal :^(NSString* result, NSError *error) {
        XCTAssertEqualObjects(echoVal, result);
        [expectation fulfill];
    }];
    [waiter waitForExpectations:@[expectation] timeout:60.0];
}

- (void) testEchoWithTransformable {
    XCTWaiter *waiter = [[XCTWaiter alloc] initWithDelegate:self];
    XCTestExpectation *expectation = [self expectationWithDescription:@"json-rpc-expectation"];
    __weak typeof(self) wSelf = self;
    JRPCTestTransformableResult *echoVal = [[JRPCTestTransformableResult alloc] init];
    echoVal.unsignedInteger = 6;
    echoVal.string = @"Hello World!";
    [wSelf.SUT echoTransformable:echoVal :^(JRPCTestTransformableResult* result, NSError *error) {
        XCTAssertEqualObjects(echoVal, result);
        [expectation fulfill];
    }];
    [waiter waitForExpectations:@[expectation] timeout:60.0];
}


@end
