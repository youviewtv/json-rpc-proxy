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

#import "JRPCProxyTransportStub.h"
#import "NSDictionary+JSONRPC.h"
#import "JRPCError.h"

@interface JRPCProxyTransportStub()
@property (nonatomic, strong) NSMutableDictionary<NSString*, id> *stubbedResponses;
@property (nonatomic, strong) NSMutableDictionary<NSString*, NSDictionary*> *stubbedErrors;
@end

// JSON-RPC Version
static const NSString * const kJSONRPCVersion = @"2.0";

// Canned JSON-RPC errors from spec
static NSDictionary *parseError;
static NSDictionary *invalidRequestError;
static NSDictionary *methodNotFoundError;
static NSDictionary *invalidParamsError;
static NSDictionary *internalError;

@implementation JRPCProxyTransportStub

+ (void)initialize
{
    if (self == [[self class] class]) {
        parseError          = @{ kJSONRPCErrorCodeKey   : @(JSONRPCErrorCodeParsing),           kJSONRPCErrorMessageKey    : @"Invalid JSON was received by the server." };
        invalidRequestError = @{ kJSONRPCErrorCodeKey   : @(JSONRPCErrorCodeInvalidRequest),    kJSONRPCErrorMessageKey    : @"The JSON sent is not a valid Request object." };
        methodNotFoundError = @{ kJSONRPCErrorCodeKey   : @(JSONRPCErrorCodeMethodNotFound),    kJSONRPCErrorMessageKey    : @"The method does not exist." };
        invalidParamsError  = @{ kJSONRPCErrorCodeKey   : @(JSONRPCErrorCodeInvalidParameters), kJSONRPCErrorMessageKey    : @"Invalid method parameter(s)." };
        internalError       = @{ kJSONRPCErrorCodeKey   : @(JSONRPCErrorCodeInternalError),     kJSONRPCErrorMessageKey    : @"Internal JSON-RPC error." };
    }
}

- (void) configureMethod:(NSString*)methodName
                  result:(id (^)(id params))result {
    [self configureMethods:@[methodName] result:result];
}

- (void) configureMethods:(NSArray<NSString*>*)methodNames
                  result:(id (^)(id params))result {
    for (NSString *methodName in methodNames) {
        self.stubbedResponses[methodName] = result;
    }
}

- (void) configureMethod:(NSString*)methodName
               errorCode:(NSUInteger)errorCode
            errorMessage:(NSString*)errorMsg
               errorData:(id)errorData {
    NSMutableDictionary *error = [@{ kJSONRPCErrorCodeKey    : @(errorCode),
                                     kJSONRPCErrorMessageKey : errorMsg ? : @""
                                     } mutableCopy];
    if (errorData) {
        error[kJSONRPCErrorDataKey] = errorData;
    }
    self.stubbedErrors[methodName] = [error copy];  // copy trips mutability
}

#pragma mark - Private

- (NSDictionary*) responseForRequest:(NSDictionary*)jsonRPCRequest {
    NSLog(@"%s - request: %@", __func__, jsonRPCRequest);
    id result = nil;
    NSDictionary *error = nil;
    // Check required request params
    NSString *version = jsonRPCRequest[kJSONRPCVersionKey];
    NSString *methodName = jsonRPCRequest[kJSONRPCMethodKey];
    id requestId = jsonRPCRequest[kJSONRPCRequestIdKey];
    if (![kJSONRPCVersion isEqualToString:version] ||
        !requestId ||
        methodName.length == 0) {
        error = invalidRequestError;
    }
    else {
        // Lookup stubbed method resposne or error
        id (^resultBlock)(id) = self.stubbedResponses[methodName];
        if (resultBlock) {
            // Complete with stubbed response
            result = resultBlock(jsonRPCRequest[kJSONRPCParamsKey]);
        }
        else {
            // No stubbed response, check for error
            NSDictionary *stubbedError = self.stubbedErrors[methodName];
            if (stubbedError) {
                // Complete with stubbed error
                error = stubbedError;
            }
            else {
                // Method not stubbed
                error = methodNotFoundError;
            }
        }
    }
    NSMutableDictionary *response = [@{
                                       kJSONRPCVersionKey   : kJSONRPCVersion,
                                       kJSONRPCRequestIdKey : requestId ? : [NSNull null],
                                       } mutableCopy];
    if (result) {
        // Return as result
        response[kJSONRPCResultKey] = result;
    }
    else if (error) {
        // Return as error
        response[kJSONRPCErrorKey] = error;
    }
    else {
        // Internal error
        response[kJSONRPCErrorKey] = internalError;
    }
    return [response copy]; // copy strips mutability
}

- (void) completeRequestWithResponse:(NSDictionary*)jsonRPCResponse
                               completionQueue:(dispatch_queue_t)completionQueue
                                    completion:(JRPCTransportObjectCompletion)completion {
    NSLog(@"%s - response: %@", __func__, jsonRPCResponse);
    // Complete request
    if (NULL != completion) {
        dispatch_queue_t queue = completionQueue ? : dispatch_get_main_queue();
        dispatch_async(queue, ^{
            completion(jsonRPCResponse, nil);
        });
    }
}

- (void) completeRequestWithSerializedResponse:(NSDictionary*)jsonRPCResponse
                               completionQueue:(dispatch_queue_t)completionQueue
                                    completion:(JRPCTransportDataCompletion)completion {
    NSLog(@"%s - response: %@", __func__, jsonRPCResponse);
    // Seralize response
    NSData *data = [NSJSONSerialization dataWithJSONObject:jsonRPCResponse options:0 error:nil];
    // Complete request
    if (NULL != completion) {
        dispatch_queue_t queue = completionQueue ? : dispatch_get_main_queue();
        dispatch_async(queue, ^{
            completion(data, nil);
        });
    }
}

#pragma mark - NSObject overrides

- (instancetype) init {
    self = [super init];
    if (self) {
        self.stubbedResponses = [[NSMutableDictionary alloc] init];
        self.stubbedErrors = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (BOOL) respondsToSelector:(SEL)aSelector {
    // We override this to pretend we don't respond to one of the JRPCProxyTransport methods if self.performsSerialization == YES
    if (!self.performsSerialization && [NSStringFromSelector(aSelector) isEqualToString:NSStringFromSelector(@selector(sendJSONRPCPayloadWithRequestObject:completionQueue:completion:))]) {
        return NO;
    }
    return [super respondsToSelector:aSelector];
}

#pragma mark - JRPCProxyTransport

- (void) sendJSONRPCPayloadWithRequestObject:(NSDictionary*)jsonRPCRequest
                             completionQueue:(dispatch_queue_t)completionQueue
                                  completion:(JRPCTransportObjectCompletion)completion {
    // When the stub declares that the transport performs serialzation, the proxy will pass us the JSON-PRC request object rather than serialized data
    // Obviously the stub doesn't serialize it, since we don't send it anywhere and just prepare a response
    NSDictionary *jsonRPCResponse = nil;
    if ([jsonRPCRequest isKindOfClass:[NSDictionary class]]) {
        // Successful serialization
        jsonRPCResponse = [self responseForRequest:jsonRPCRequest];
    }
    else {
        // JSON parse failed
        jsonRPCResponse = [@{
                             kJSONRPCVersionKey   : kJSONRPCVersion,
                             kJSONRPCRequestIdKey : [NSNull null],
                             kJSONRPCErrorKey     : internalError,
                             } mutableCopy];
    }
    // When the stub decalres that the transport performs serialization, the proxy expects a dictionary result containing the JSON-RPC response
    [self completeRequestWithResponse:jsonRPCResponse completionQueue:completionQueue completion:completion];
}

- (void) sendJSONRPCPayloadWithRequestData:(NSData*)payload
            completionQueue:(dispatch_queue_t)completionQueue
                 completion:(JRPCTransportDataCompletion)completion {
    // Ironically, when the stub declares that the transport does NOT perform serialization, we need to reverse the serialization that the proxy has already done on its behalf!
    // Deserialize request
    NSError *serializationError = nil;
    id jsonObject = [NSJSONSerialization JSONObjectWithData:payload options:0 error:&serializationError];
    NSDictionary *jsonRPCResponse = nil;
    if ([jsonObject isKindOfClass:[NSDictionary class]]) {
        // Successful serialization
        NSDictionary *jsonRPCRequest = (NSDictionary*)jsonObject;
        jsonRPCResponse = [self responseForRequest:jsonRPCRequest];
    }
    else {
        // JSON parse failed
        jsonRPCResponse = [@{
                               kJSONRPCVersionKey   : kJSONRPCVersion,
                               kJSONRPCRequestIdKey : [NSNull null],
                               kJSONRPCErrorKey     : parseError,
                               } mutableCopy];
    }
    // Also when the stub declares that the transport does NOT perform de-serialization, the proxy expects raw data to deserialize itself, so we DO serialize the response
    [self completeRequestWithSerializedResponse:jsonRPCResponse completionQueue:completionQueue completion:completion];
}


@end
