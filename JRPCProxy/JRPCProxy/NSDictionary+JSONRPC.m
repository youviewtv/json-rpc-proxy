//
//  NSDictionary+JSONRPC.m
//  JRPCProxy
//
//  Created on 14/10/2017.
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

#import "NSDictionary+JSONRPC.h"

// JSON-RPC specification keys
const NSString * const kJSONRPCVersionKey = @"jsonrpc";
const NSString * const kJSONRPCRequestIdKey = @"id";
const NSString * const kJSONRPCMethodKey = @"method";
const NSString * const kJSONRPCParamsKey = @"params";
const NSString * const kJSONRPCResultKey = @"result";
const NSString * const kJSONRPCErrorKey = @"error";
const NSString * const kJSONRPCErrorCodeKey = @"code";
const NSString * const kJSONRPCErrorMessageKey = @"message";
const NSString * const kJSONRPCErrorDataKey = @"data";

@implementation NSDictionary (JSONRPC)

- (NSString * _Nullable) jsonRPC_version {
    return self[kJSONRPCVersionKey];
}

- (id _Nullable) jsonRPC_requestId {
    id requestId = self[kJSONRPCRequestIdKey];
    if (!requestId || [requestId isKindOfClass:[NSNull class]]) {
        return nil;
    }
    return requestId;
}

@end

@implementation NSDictionary (JSONRPCRequest)

- (NSString * _Nullable) jsonRPC_methodName {
    return self[kJSONRPCMethodKey];
}

- (NSUInteger) jsonRPC_parametersCount {
    id params = self[kJSONRPCParamsKey];
    if (params && [params respondsToSelector:@selector(count)]) {
        return [params count];
    }
    return 0;
}

- (NSArray<id> * _Nullable) jsonRPC_parametersByPosition {
    id params = self[kJSONRPCParamsKey];
    if (params && [params isKindOfClass:[NSArray class]]) {
        return (NSArray*)params;
    }
    return nil;
}

- (NSDictionary<NSString*, id> * _Nullable) jsonRPC_parametersByName {
    id params = self[kJSONRPCParamsKey];
    if (params && [params isKindOfClass:[NSDictionary class]]) {
        return (NSDictionary*)params;
    }
    return nil;
}

@end

@implementation NSDictionary (JSONRPCResponse)

- (BOOL) jsonRPC_success {
    return (self[kJSONRPCResultKey] != nil);
}

- (id) jsonRPC_result {
    return self[kJSONRPCResultKey];
}

- (NSInteger) jsonRPC_errorCode {
    NSInteger errorCode = NSNotFound;
    id error = self[kJSONRPCErrorKey];
    if (error) {
        NSNumber *errorNum = error[kJSONRPCErrorCodeKey];
        if (errorNum) {
            errorCode = errorNum.integerValue;
        }
    }
    return errorCode;
}

- (NSString*) jsonRPC_errorMessage {
    return (self[kJSONRPCErrorKey])[kJSONRPCErrorMessageKey];
}

- (id) jsonRPC_errorData {
    return (self[kJSONRPCErrorKey])[kJSONRPCErrorDataKey];
}

@end

