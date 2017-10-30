//
//  JRPCProxyByNameTests.m
//  JRPCProxyTests
//
//  Created on 06/10/2017.
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
 Test cases for JSON-RPC with 'by-name' parameter structure
 */
@interface JRPCProxyByNameTests : JRPCProxyTestsBase
@end

// This is the protocol being proxied by the SUT ...
@protocol JRPCProxyByNameTestsProtocol
- (void) methodTakesNoParamsReturnsHelloWorldStringWithCompletion:(void (^)(NSString *result, NSError *error))completion;
- (void) appendStringsWithString1:(NSString*)string1 string2:(NSString*)string2 completion:(void (^)(NSString *result, NSError *error))completion;
- (void) addIntegersWithFirst:(NSInteger)first second:(NSInteger)second completion:(void (^)(NSInteger result, NSError *error))completion;
- (void) echoBoolWithValue:(_Bool)value completion:(void (^)(_Bool result, NSError *error))completion;
- (void) echoCharWithValue:(char)value completion:(void (^)(char result, NSError *error))completion;
- (void) echoShortWithValue:(short)value completion:(void (^)(short result, NSError *error))completion;
- (void) echoIntWithValue:(int)value completion:(void (^)(int result, NSError *error))completion;
- (void) echoLongWithValue:(long)value completion:(void (^)(long result, NSError *error))completion;
- (void) echoIntegerWithValue:(NSInteger)value completion:(void (^)(NSInteger result, NSError *error))completion;
- (void) echoUnsignedCharWithValue:(unsigned char)value completion:(void (^)(unsigned char result, NSError *error))completion;
- (void) echoUnsignedShortWithValue:(unsigned short)value completion:(void (^)(unsigned short result, NSError *error))completion;
- (void) echoUnsignedIntWithValue:(unsigned int)value completion:(void (^)(unsigned int result, NSError *error))completion;
- (void) echoUnsignedLongWithValue:(unsigned long)value completion:(void (^)(unsigned long result, NSError *error))completion;
- (void) echoUnsignedIntegerWithValue:(NSUInteger)value completion:(void (^)(NSUInteger result, NSError *error))completion;
- (void) echoFloatWithValue:(float)value completion:(void (^)(float result, NSError *error))completion;
- (void) echoDoubleWithValue:(double)value completion:(void (^)(double result, NSError *error))completion;
- (void) echoStringWithValue:(NSString*)value completion:(void (^)(NSString *result, NSError *error))completion;
- (void) echoTransformableWithValue:(JRPCTestTransformableResult*)value completion:(void (^)(JRPCTestTransformableResult *result, NSError *error))completion;
@end
// ... so we declare conformance to the protocol by the SUT to satisfy the compiler
@interface JRPCAbstractProxy() <JRPCProxyByNameTestsProtocol>
@end

@implementation JRPCProxyByNameTests

- (void)setUp {
    self.protocol = @protocol(JRPCProxyByNameTestsProtocol);
    self.paramsStructure = JRPCParameterStructureByName;
    [super setUp];  // Base class initializes SUT
}

- (void)tearDown {
    [super tearDown];
}

#pragma mark - Tests

- (void) testMethodTakesNoParamsReturnsString {
    XCTWaiter *waiter = [[XCTWaiter alloc] initWithDelegate:self];
    XCTestExpectation *expectation = [self expectationWithDescription:@"json-rpc-expectation"];
    [self.SUT methodTakesNoParamsReturnsHelloWorldStringWithCompletion:^(NSString *result, NSError *error) {
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
    [self.SUT appendStringsWithString1:@"foo" string2:@"bar" completion:^(NSString *result, NSError *error) {
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
    [wSelf.SUT addIntegersWithFirst:10 second:32 completion:^(NSInteger result, NSError *error) {
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
    _Bool echoVal = true;
    [wSelf.SUT echoBoolWithValue:echoVal completion:^(_Bool result, NSError *error) {
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
    [wSelf.SUT echoCharWithValue:echoVal completion:^(char result, NSError *error) {
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
    [wSelf.SUT echoShortWithValue:echoVal completion:^(short result, NSError *error) {
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
    [wSelf.SUT echoIntWithValue:echoVal completion:^(int result, NSError *error) {
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
    [wSelf.SUT echoLongWithValue:echoVal completion:^(long result, NSError *error) {
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
    [wSelf.SUT echoIntegerWithValue:echoVal completion:^(NSInteger result, NSError *error) {
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
    [wSelf.SUT echoUnsignedCharWithValue:echoVal completion:^(unsigned char result, NSError *error) {
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
    [wSelf.SUT echoUnsignedShortWithValue:echoVal completion:^(unsigned short result, NSError *error) {
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
    [wSelf.SUT echoUnsignedIntWithValue:echoVal completion:^(unsigned int result, NSError *error) {
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
    [wSelf.SUT echoUnsignedLongWithValue:echoVal completion:^(unsigned long result, NSError *error) {
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
    [wSelf.SUT echoUnsignedIntegerWithValue:echoVal completion:^(NSUInteger result, NSError *error) {
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
    [wSelf.SUT echoFloatWithValue:echoVal completion:^(float result, NSError *error) {
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
    [wSelf.SUT echoDoubleWithValue:echoVal completion:^(double result, NSError *error) {
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
    [wSelf.SUT echoStringWithValue:echoVal completion:^(NSString* result, NSError *error) {
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
    [wSelf.SUT echoTransformableWithValue:echoVal completion:^(JRPCTestTransformableResult* result, NSError *error) {
        XCTAssertEqualObjects(echoVal, result);
        [expectation fulfill];
    }];
    [waiter waitForExpectations:@[expectation] timeout:60.0];
}

@end
