//
//  NSDictionary+JSONRPC.h
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

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/*
 This section provides the raw JSON-RPC keys as defined in the specification
 */
/** A String specifying the version of the JSON-RPC protocol */
extern const NSString * const kJSONRPCVersionKey;
/** The id of the request as set by the client in the request and matched in the repsonse. */
extern const NSString * const kJSONRPCRequestIdKey;
/** A String containing the name of the method to be invoked. */
extern const NSString * const kJSONRPCMethodKey;
/** A NSArray or NSDictionary that holds the parameter values to be used during the invocation of the method.  */
extern const NSString * const kJSONRPCParamsKey;
/** The result in a successful response */
extern const NSString * const kJSONRPCResultKey;
/** The error object in an unsuccessful resposne */
extern const NSString * const kJSONRPCErrorKey;
/** The error code in an unsuccessful response @see JSONRPCErrorCode */
extern const NSString * const kJSONRPCErrorCodeKey;
/** The error message in an unsuccessful response */
extern const NSString * const kJSONRPCErrorMessageKey;
/** The error data in an unsuccessful response */
extern const NSString * const kJSONRPCErrorDataKey;

/**
 This category adds convenience accessors for keys common to both the JSON-RPC request & response
 */
@interface NSDictionary (JSONRPC)

/** The JSON-RPC version, or nil if not present */
@property (readonly, nullable) NSString *jsonRPC_version;

/** The JSON-RPC requestId, or nil if not present */
@property (readonly, nullable) id jsonRPC_requestId;

@end

/**
 This category adds convenience accessors for keys unique to the JSON-RPC request
 */
@interface NSDictionary (JSONRPCRequest)

/** The JSON-RPC request method name, or nil if not present */
@property (readonly, nullable) NSString *jsonRPC_methodName;

/** The number of parameters for the JSON-RPC request */
@property (readonly) NSUInteger jsonRPC_parametersCount;

/** The JSON-RPC request method parameters if present & by-position structure is used. Otherwise nil */
@property (readonly, nullable) NSArray<id> *jsonRPC_parametersByPosition;

/** The JSON-RPC request method parameters if present & by-position structure is used. Otherwise nil */
@property (readonly, nullable) NSDictionary<NSString*, id>  *jsonRPC_parametersByName;

@end

/**
 This category adds convenience accessors for keys unique to the JSON-RPC response
 */
@interface NSDictionary (JSONRPCResponse)

/** Determines whether the response was a success (YES) or error (NO) */
@property (readonly) BOOL jsonRPC_success;

/** The result of the JSON-RPC call, or nil if not successful */
@property (readonly, nullable) id jsonRPC_result;

/** The error code of the JSON-PRC response, or NSNotFound if not provided */
@property (readonly) NSInteger jsonRPC_errorCode;

/** The error message of the JSON-PRC response, or nil if none provided */
@property (readonly, nullable) NSString *jsonRPC_errorMessage;

/** The error data of the JSON-PRC response, or nil if none provided */
@property (readonly, nullable) id jsonRPC_errorData;

@end

NS_ASSUME_NONNULL_END

