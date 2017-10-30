//
//  JRPCProxyTestsBase.h
//  JRPCProxyTests
//
//  Created on: 07/10/2017
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
#import "JRPCAbstractProxy.h"
#import "JRPCTransformable.h"

@class JRPCProxyTransportStub;

/**
 Abstract base class for by-position and by-name tests
 */
@interface JRPCProxyTestsBase : XCTestCase
/** The System Under Test */
@property (nonatomic, readonly) JRPCAbstractProxy *SUT;
/** The parameter structure to use for the tests. Should be set by sub-classes BEFORE calling [super setup] */
@property (nonatomic, assign) JRPCParameterStructure paramsStructure;
/** The protocol to be proxied by the SUT. Should be set by sub-classes BEFORE calling [super setup] */
@property (nonatomic, strong) Protocol *protocol;
/** Determines whether the stubbed transport should perform serialization (YES), or whether the SUT (de)serializes requests/responses.
    Should be set by sub-classes BEFORE calling [super setup] */
@property (nonatomic, assign) BOOL transportStubPerformsSerialization;
@end

@interface JRPCTestTransformableResult : NSObject <JRPCTransformable>
@property (nonatomic, strong) NSString *string;
@property (nonatomic, assign) NSUInteger unsignedInteger;
@end
