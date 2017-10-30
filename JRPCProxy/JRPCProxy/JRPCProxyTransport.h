//
//  JRPCProxyTransport.h
//  JRPCProxy
//
//  Created on: 27/10/2017
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

/**
 JRPCTransportDataCompletion defines the block to be called on completion of async JSON-RPC requests by JRPCProxyTransport
 This block defintion is used when the transport wishes to pass the raw data and leave JSON serialization to the proxy
 @param data If the request succeeded contains the raw data from the response payload, otherwise nil if the request failed
 @param error if the request failed, contains an NSError describing the failure, otherwise nil if the request succeeded
 */
typedef void (^JRPCTransportDataCompletion)(NSData * __nullable data , NSError * __nullable error);

/**
 JRPCTransportObjectCompletion defines the block to be called on completion of async JSON-RPC requests by JRPCProxyTransport
 This block defintion is used when the transport wishes to perform JSON serializtion itself and pass the resulting JSON object
 @param jsonResponse If the request succeeded contains the deserialilzed JSON response object, otherwise nil if the request failed
 @param error if the request failed, contains an NSError describing the failure, otherwise nil if the request succeeded
 */
typedef void (^JRPCTransportObjectCompletion)(NSDictionary * __nullable jsonResponse , NSError * __nullable error);

/**
 JRPCProxyTransport is used by JRPCAbstractProxy to abstract away the actual mechanism used to make the request and receive the response.
 @discussion The transport is expected to implement ONE of these methods only, depending on whether it wishes to perform the JSON<->NSData serialiazation itself, or leave it up to the proxy. e.g.
 If the transport is HTTP you may prefer to use raw data since the request/response can easily be matched without knowledge of the payload request id
 Alternativeley, for a WebSocket, you may prefer to perform the serialization in the transport in order to match the id between request & response objects
 If NEITHER method is implemnented an exception will occur.
 If BOTH methods are implemented, the proxy will prefer to delegate serialization duties to the transport
 */
@protocol JRPCProxyTransport <NSObject>
@optional
/**
 Asyncronosuly sends the JSON-RPC request payload object and returns the result object
 @param jsonRPCRequest The serialized JSON data for the JSON-RPC request object
 @param completionQueue A dispatch queue that will be used to call the completion block. Should accept nil for use of dispatch_get_main_queue()
 @param completion A block that will be called woth the result of the JSON-RPC request
 */
- (void) sendJSONRPCPayloadWithRequestObject:(NSDictionary*)jsonRPCRequest
                             completionQueue:(dispatch_queue_t __nullable)completionQueue
                                  completion:(JRPCTransportObjectCompletion)completion;

/**
 Asyncronously sends the JSON-RPC request payload serialized data and returns the raw data result
 @param payload The serialized JSON data for the JSON-RPC request object
 @param completionQueue A dispatch queue that will be used to call the completion block. Should accept nil for use of dispatch_get_main_queue()
 @param completion A block that will be called woth the result of the JSON-RPC request
 */
- (void) sendJSONRPCPayloadWithRequestData:(NSData*)payload
                           completionQueue:(dispatch_queue_t __nullable)completionQueue
                                completion:(JRPCTransportDataCompletion)completion;

@end

NS_ASSUME_NONNULL_END
