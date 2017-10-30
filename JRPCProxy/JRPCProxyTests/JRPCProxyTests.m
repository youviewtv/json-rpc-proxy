//
//  JRPCProxyTests.m
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

@interface JRPCProxyTests : JRPCProxyTestsBase
@end

// This is the protocol being proxied by the SUT ...
@protocol JRPCProxyTestsProtocol
- (void) methodWithString:(NSString*)string completion:(void (^)(NSString *result, NSError *error))completion;
@end
// ... so we declare conformance to the protocol by the SUT to satisfy the compiler
@interface JRPCAbstractProxy() <JRPCProxyTestsProtocol>
@end

@implementation JRPCProxyTests

- (void)setUp {
    self.protocol = @protocol(JRPCProxyTestsProtocol);
    self.paramsStructure = JRPCParameterStructureByName;
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

#pragma mark - Tests

- (void) testProxyRespondsToSelector {
    BOOL expected = YES;
    BOOL responds = [self.SUT respondsToSelector:@selector(methodWithString:completion:)];
    XCTAssertEqual(expected, responds);
}
- (void) testProxyDoesNotRespondToSelector {
    BOOL expected = NO;
    SEL nonProxiedSel = NSSelectorFromString(@"methodWithInteger:completion:");
    BOOL responds = [self.SUT respondsToSelector:nonProxiedSel];
    XCTAssertEqual(expected, responds);
}

@end
