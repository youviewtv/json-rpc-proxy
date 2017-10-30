//
//  JRPCError.h
//  JRPCProxy
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

@import Foundation;

/** Error domain for JRPCAbstractProxy */
FOUNDATION_EXPORT NSErrorDomain const JRPCErrorDomain;

/**
 Error codes in the JRPCErrorDomain error domain
 */
NS_ERROR_ENUM(JRPCErrorDomain) {
    /** Error occurred during JSON serialization of the request before sending to the server. See NSUnderlyingErrorKey of userInfo */
    JRPCErrorRequestSerializationCode    = 1001,
    /** Error occurred during JSON deserialization of the response from the server.  See NSUnderlyingErrorKey of userInfo */
    JRPCErrorResponseSerializationCode   = 1002,
    /** Error occurred during JSON-RPC transport.  See NSUnderlyingErrorKey of userInfo */
    JRPCErrorTransportCode               = 1003,
    /** An error was returned by the JSON-PRC server in the payload. See userInfo keys below */
    JRPCErrorServerResponseCode          = 1004
};

/**
 @const kJRPCErrorCodeKey
 @abstract userInfo key for JSON-RPC server response error code.
 */
FOUNDATION_EXPORT NSString * const kJRPCErrorCodeKey;

/**
 @const kJRPCErrorMessageKey
 @abstract userInfo key for JSON-RPC server response error message.
 */
FOUNDATION_EXPORT NSString * const kJRPCErrorMessageKey;

/**
 @const kJRPCErrorDataKey
 @abstract userInfo key for JSON-RPC server response error data.
 */
FOUNDATION_EXPORT NSString * const kJRPCErrorDataKey;

// Values for the userInfo key kJRPCErrorCodeKey when NSError.code == JRPCErrorResponseSerializationCode
// These are application errors retured by the JSON-RPC server
typedef NS_ENUM(NSInteger, JSONRPCErrorCode) {
    /** An error occurred on the server while parsing the JSON text. */
    JSONRPCErrorCodeParsing            = -32700,
    /** The JSON sent is not a valid Request object */
    JSONRPCErrorCodeInvalidRequest     = -32600,
    /** The method does not exist. */
    JSONRPCErrorCodeMethodNotFound     = -32601,
    /** Invalid method parameter(s). */
    JSONRPCErrorCodeInvalidParameters  = -32602,
    /** Internal JSON-RPC error. */
    JSONRPCErrorCodeInternalError      = -32603
};

