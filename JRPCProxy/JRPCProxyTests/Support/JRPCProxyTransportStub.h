//
//  JRPCProxyTransportStub.h
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

#import "JRPCProxyTransport.h"

/**
 JRPCProxyTransportStub provides a stub service to use as a JRPCProxyTransport
 You can configure various responses based on method name
 */
@interface JRPCProxyTransportStub : NSObject <JRPCProxyTransport>

/**
 Configure the stub to report to the proxy that it will perform serialization itself.
 If YES, the proxy will call us with a JSON-RPC request object and expect a JSON-RPC response object. The stub performs no serialization since no transport is actually required
 If NO, the proxy will call us with serialized JSON-RPC request NSData, and expect a serialized NSData JSON-RPC repsonse. The stub needs to deserialize the proxied request and serialize the result to simulate raw data transport.
 */
@property (nonatomic, assign) BOOL performsSerialization;

/**
 Configure the stub to return result on calling the method
 @param methodName the name of the method to be stubbed
 @param result a block that will be called with the params and should return the result
 @discussion This method calls configureMethods:result: with an array containing the single method name
 */
- (void) configureMethod:(NSString*)methodName
              result:(id (^)(id params))result;

/**
 Configure the stub to return the same result on calling any of the supplied methods
 @param methodNames An array of method name strings to be stubbed
 @param result a block that will be called with the params and should return the result
 */
- (void) configureMethods:(NSArray<NSString*>*)methodNames
                   result:(id (^)(id params))result;

/**
 Configure the stub to return an error on calling the method
 @param methodName the name of the method to be stubbed
 @param errorCode the code of the error returned from the stubbed method
 @param errorMsg Concise message describing the error returned from the stubbed method
 @param errorData Optional additional data for the error returned from the stubbed method
 */
- (void) configureMethod:(NSString*)methodName
           errorCode:(NSUInteger)errorCode
            errorMessage:(NSString*)errorMsg
               errorData:(id)errorData;

@end
