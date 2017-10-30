//
//  NSDictionary+JSONRPCTests.m
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

#import <XCTest/XCTest.h>
#import "NSDictionary+JSONRPC.h"

@interface NSDictionary_JSONRPCTests : XCTestCase
@property (nonatomic, strong) NSDictionary *validPositionRequest;
@property (nonatomic, strong) NSDictionary *validNamedRequest;
@property (nonatomic, strong) NSDictionary *resultResponse;
@property (nonatomic, strong) NSDictionary *methodNotFoundResponse;
@end

@implementation NSDictionary_JSONRPCTests

- (void)setUp {
    [super setUp];
    self.validPositionRequest = @{@"jsonrpc": @"2.0", @"method": @"subtract", @"params": @[@42, @23], @"id": @123};
    self.validNamedRequest = @{@"jsonrpc": @"2.0", @"method": @"subtract", @"params": @{@"subtrahend": @42, @"minuend": @23}, @"id": @"123"};
    self.resultResponse = @{@"jsonrpc": @"2.0", @"result": @19, @"id": @"123"};
    self.methodNotFoundResponse = @{@"jsonrpc": @"2.0", @"error": @{@"code": @-32601, @"message": @"Method not found"}, @"id": @"123"};
}

- (void)tearDown {
    self.validPositionRequest = nil;
    self.validNamedRequest = nil;
    self.resultResponse = nil;
    self.methodNotFoundResponse = nil;
    [super tearDown];
}

#pragma mark - Tests

- (void) testPositionRequest {
    XCTAssertEqualObjects(self.validPositionRequest.jsonRPC_version, @"2.0");
    XCTAssertEqualObjects(self.validPositionRequest.jsonRPC_methodName, @"subtract");
    XCTAssertEqualObjects(self.validPositionRequest.jsonRPC_requestId, @123);
    XCTAssertEqual(self.validPositionRequest.jsonRPC_parametersCount, 2);
    NSArray *posParams = self.validPositionRequest.jsonRPC_parametersByPosition;
    NSDictionary *nameParams = self.validPositionRequest.jsonRPC_parametersByName;
    XCTAssertNil(nameParams);
    XCTAssertEqual([posParams[0] integerValue], 42);
    XCTAssertEqual([posParams[1] integerValue], 23);
}

- (void) testNamedRequest {
    XCTAssertEqualObjects(self.validNamedRequest.jsonRPC_version, @"2.0");
    XCTAssertEqualObjects(self.validNamedRequest.jsonRPC_methodName, @"subtract");
    XCTAssertEqualObjects(self.validNamedRequest.jsonRPC_requestId, @"123");
    XCTAssertEqual(self.validNamedRequest.jsonRPC_parametersCount, 2);
    NSArray *posParams = self.validNamedRequest.jsonRPC_parametersByPosition;
    NSDictionary *nameParams = self.validNamedRequest.jsonRPC_parametersByName;
    XCTAssertNil(posParams);
    XCTAssertEqual([nameParams[@"subtrahend"] integerValue], 42);
    XCTAssertEqual([nameParams[@"minuend"] integerValue], 23);
}

- (void) testResultResponse {
    XCTAssertEqualObjects(self.resultResponse.jsonRPC_version, @"2.0");
    XCTAssertEqualObjects(self.resultResponse.jsonRPC_requestId, @"123");
    XCTAssertTrue(self.resultResponse.jsonRPC_success);
    XCTAssertEqual([self.resultResponse.jsonRPC_result integerValue], 19);
    XCTAssertEqual(self.resultResponse.jsonRPC_errorCode, NSNotFound);
    XCTAssertNil(self.resultResponse.jsonRPC_errorMessage);
    XCTAssertNil(self.resultResponse.jsonRPC_errorData);
}

- (void) testMethodNotFoundResponse {
    XCTAssertEqualObjects(self.methodNotFoundResponse.jsonRPC_version, @"2.0");
    XCTAssertEqualObjects(self.methodNotFoundResponse.jsonRPC_requestId, @"123");
    XCTAssertFalse(self.methodNotFoundResponse.jsonRPC_success);
    XCTAssertNil(self.methodNotFoundResponse.jsonRPC_result);
    XCTAssertEqual(self.methodNotFoundResponse.jsonRPC_errorCode, -32601);
    XCTAssertEqualObjects(self.methodNotFoundResponse.jsonRPC_errorMessage, @"Method not found");
    XCTAssertNil(self.methodNotFoundResponse.jsonRPC_errorData);
}

- (void) testNoRequestIdInRequest {
    NSMutableDictionary *request = [self.validPositionRequest mutableCopy];
    request[kJSONRPCRequestIdKey] = nil;
    XCTAssertNil(request.jsonRPC_requestId);
}

- (void) testNullRequestIdInRequest {
    NSMutableDictionary *request = [self.validPositionRequest mutableCopy];
    request[kJSONRPCRequestIdKey] = [NSNull null];
    XCTAssertNil(request.jsonRPC_requestId);
}

- (void) testRequestWithNoParams {
    NSMutableDictionary *request = [self.validPositionRequest mutableCopy];
    request[kJSONRPCParamsKey] = nil;
    XCTAssertEqual(request.jsonRPC_parametersCount, 0);
}
@end
