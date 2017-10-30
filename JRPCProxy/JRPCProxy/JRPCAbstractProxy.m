//
//  JRPCAbstractProxy.m
//  JRPCProxy
//
//  Created on: 06/10/2017
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

#import "JRPCAbstractProxy.h"
#import "JRPCProxyTransport.h"
#import "JRPCTransformable.h"
#import "NSDictionary+JSONRPC.h"
#import "JRPCError.h"
#import "CTBlockDescription.h"
#import <objc/runtime.h>

// JSON-RPC Version
static const NSString * const kJSONRPCVersion = @"2.0";

@interface JRPCAbstractProxy()
@property (nonatomic, strong) Protocol *protocol;
@property (nonatomic, assign) JRPCParameterStructure paramStructure;
@property (nonatomic, strong) id<JRPCProxyTransport> transport;
@property (nonatomic, assign) BOOL transportPerformsSerialization;
@property (nonatomic, strong) dispatch_queue_t serializationQueue;
@property (atomic) NSUInteger jsonRPCRequestId;
@end

static const char *JSON_RPC_SERIALIZATION_QUEUE_NAME = "JRPCAbstractProxySerializationQueue";

@implementation JRPCAbstractProxy

+ (id) proxyForProtocol:(Protocol *)protocol
         paramStructure:(JRPCParameterStructure)paramStructure
              transport:(id<JRPCProxyTransport>)transport {
    return [[[self class] alloc] initWithProtocol:protocol paramStructure:paramStructure transport:transport];
}

#pragma mark - Private

- (id) initWithProtocol:(Protocol *)protocol
         paramStructure:(JRPCParameterStructure)paramStructure
              transport:(id<JRPCProxyTransport>)transport {
    // Verify that the transport implements AT LEAST one of the optional transport methods:
    self.transportPerformsSerialization = [transport respondsToSelector:@selector(sendJSONRPCPayloadWithRequestObject:completionQueue:completion:)];
    if (!self.transportPerformsSerialization &&
        ![transport respondsToSelector:@selector(sendJSONRPCPayloadWithRequestData:completionQueue:completion:)]) {
        [NSException raise:NSInvalidArgumentException format:@"transport MUST implement at least one method"];
        return nil;
    }
    // TODO: validate type encodings of protocol methods as per parameter structure and fail if necessary by returning nil
    self.protocol = protocol;
    self.paramStructure = paramStructure;
    self.transport = transport;
    if (!self.transportPerformsSerialization) {
        self.serializationQueue = dispatch_queue_create(JSON_RPC_SERIALIZATION_QUEUE_NAME, DISPATCH_QUEUE_CONCURRENT);
    }
    self.jsonRPCRequestId = 0;
    return self;
}

- (dispatch_queue_t) rpcCompletionQueue {
    return _rpcCompletionQueue ? : dispatch_get_main_queue();
}

- (dispatch_queue_t) serializationQueue {
    return _serializationQueue ? : dispatch_get_main_queue();
}

- (NSArray*) paramValuesFromInvocation:(NSInvocation*)invocation {
    // first arg is self, second arg is SEL (_cmd), last arg is completion block
    NSMutableArray *paramValues = [[NSMutableArray alloc] initWithCapacity:invocation.methodSignature.numberOfArguments - 3];
    for (int i = 2; i < invocation.methodSignature.numberOfArguments - 1; ++i) {
        // Look up the Objective-C runtime type encoding for the argument
        // See https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html
        const char *argTypeEncoding = [invocation.methodSignature getArgumentTypeAtIndex:i];
        if (1 == strlen(argTypeEncoding))
        {
            // We only support SOME of the basic types
            char encodedType = argTypeEncoding[0];
            switch (encodedType) {
                case 'B':   // A C++ bool or a C99 _Bool (Swift bridges booleans to this!)
                {
                    _Bool value = false;
                    [invocation getArgument:&value atIndex:i];
                    [paramValues addObject:[NSNumber numberWithBool:value]];
               }
                    break;
                case 'c':   // char => box in NSNumber
                {
                    char value = 0;
                    [invocation getArgument:&value atIndex:i];
                    [paramValues addObject:[NSNumber numberWithChar:value]];
                }
                    break;
                case 'i':   // int => box in NSNumber
                {
                    int value = 0;
                    [invocation getArgument:&value atIndex:i];
                    [paramValues addObject:[NSNumber numberWithInt:value]];
                }
                    break;
                case 's':   // short => box in NSNumber
                {
                    short value = 0;
                    [invocation getArgument:&value atIndex:i];
                    [paramValues addObject:[NSNumber numberWithShort:value]];
                }
                    break;
                case 'l':   // long, treated as 32-bit on 64-bit systems => box in NSNumber
                {
                    long value = 0;
                    [invocation getArgument:&value atIndex:i];
                    [paramValues addObject:[NSNumber numberWithLong:value]];
                }
                    break;
                case 'q':   // long long => box in NSNumber
                {
                    long long value = 0;
                    [invocation getArgument:&value atIndex:i];
                    [paramValues addObject:[NSNumber numberWithLongLong:value]];
                }
                    break;
                case 'C':   // unsigned char => box in NSNumber
                {
                    unsigned char value = 0;
                    [invocation getArgument:&value atIndex:i];
                    [paramValues addObject:[NSNumber numberWithUnsignedChar:value]];
                }
                    break;
                case 'I':   // unsigned int => box in NSNumber
                {
                    unsigned int value = 0;
                    [invocation getArgument:&value atIndex:i];
                    [paramValues addObject:[NSNumber numberWithUnsignedInt:value]];
                }
                    break;
                case 'S':   // unsigned short => box in NSNumber
                {
                    unsigned short value = 0;
                    [invocation getArgument:&value atIndex:i];
                    [paramValues addObject:[NSNumber numberWithUnsignedShort:value]];
                }
                    break;
                case 'L':   // unsigned long => box in NSNumber
                {
                    unsigned long value = 0;
                    [invocation getArgument:&value atIndex:i];
                    [paramValues addObject:[NSNumber numberWithUnsignedLong:value]];
                }
                    break;
                case 'Q':   // unsigned long long => box in NSNumber
                {
                    unsigned long long value = 0;
                    [invocation getArgument:&value atIndex:i];
                    [paramValues addObject:[NSNumber numberWithUnsignedLongLong:value]];
                }
                    break;
                case 'f':   // float => box in NSNumber
                {
                    float value = 0;
                    [invocation getArgument:&value atIndex:i];
                    [paramValues addObject:[NSNumber numberWithFloat:value]];
                }
                    break;
                case 'd':   // double => box in NSNumber
                {
                    double value = 0;
                    [invocation getArgument:&value atIndex:i];
                    [paramValues addObject:[NSNumber numberWithDouble:value]];
                }
                    break;
                case '*':   // character string => box in NSString
                {
                    char *value = 0;
                    [invocation getArgument:&value atIndex:i];
                    [paramValues addObject:[NSString stringWithFormat:@"%s", value]];
                }
                    break;
                case '@':   // Objects
                {
                    __unsafe_unretained NSObject *obj = nil;
                    [invocation getArgument:&obj atIndex:i];
                    // Process optional transformation of parameter if not natively JSON serializable
                    obj = [self transformedJSONParameterForParameter:obj];
                    // Ensure transformed result is JSON serializable
                    if ([[self class] isValidJSONObject:obj]) {
                        // JSON serializable parameters are added directly to the JSON-RPC request parameters
                        [paramValues addObject:obj];
                    } else {
                        // Not JSON serializable
                        [NSException raise:NSInvalidArgumentException format:@"Unsupported object type for param at index=%li, obj=%@", (long)i-2, obj];
                    }

                }
                    break;
                default:
                    [NSException raise:NSInvalidArgumentException format:@"Unsupported param type %s for param at index %li",argTypeEncoding, (long)i-2];
                    break;
            }
        }
        else {
            [NSException raise:NSInvalidArgumentException format:@"Unsupported param type encoding %s for param at index %li", argTypeEncoding, (long)i-2];
        }
    }
    return [paramValues copy];  // copy strips mutability
}

- (void) dispatchJSONRPCRequest:(NSDictionary*)jsonRPCRequest completionBlock:(id)completionBlock {
    __weak typeof(self) weakSelf = self;
    // Dispatch to transport on the main queue, handling response on RPC completion queue
    [weakSelf.transport sendJSONRPCPayloadWithRequestObject:jsonRPCRequest completionQueue:weakSelf.rpcCompletionQueue completion:^(NSDictionary *jsonRPCResponse, NSError *transportError) {
        if (jsonRPCResponse) {
            // Complete request with response object
            [weakSelf completeJSONRPCRequest:jsonRPCRequest response:jsonRPCResponse error:nil completionBlock:completionBlock];
        }
        else {
            // Transport error
            NSDictionary *userInfo = transportError ? @{ NSUnderlyingErrorKey : transportError } : nil;
            NSError *error = [NSError errorWithDomain:JRPCErrorDomain code:JRPCErrorTransportCode userInfo:userInfo];
            [weakSelf completeJSONRPCRequest:jsonRPCRequest response:nil error:error completionBlock:completionBlock];
        }
    }];
}

- (void) dispatchSerializedJSONRPCRequest:(NSDictionary*)jsonRPCRequest completionBlock:(id)completionBlock {
    __weak typeof(self) weakSelf = self;
    // Serialize request
    [self serializeJSONRPCRequest:jsonRPCRequest completion:^(NSData *jsonRPCData, NSError *reqSerError) {
        if (jsonRPCData) {
            // Dispatch to transport on the main queue, handling response on RPC completion queue
            [weakSelf.transport sendJSONRPCPayloadWithRequestData:jsonRPCData completionQueue:weakSelf.rpcCompletionQueue completion:^(NSData *responseData, NSError *transportError) {
                if (responseData) {
                    // Deserialize response
                    [weakSelf deserializeJSONRPCResponse:responseData completion:^(NSDictionary *jsonRPCResponse, NSError *respSerError) {
                        if (jsonRPCResponse) {
                            // Complete request with response object
                            [weakSelf completeJSONRPCRequest:jsonRPCRequest response:jsonRPCResponse error:nil completionBlock:completionBlock];
                        }
                        else {
                            // Response deserialization error
                            NSDictionary *userInfo = respSerError ? @{ NSUnderlyingErrorKey : respSerError } : nil;
                            NSError *error = [NSError errorWithDomain:JRPCErrorDomain code:JRPCErrorResponseSerializationCode userInfo:userInfo];
                            [weakSelf completeJSONRPCRequest:jsonRPCRequest response:nil error:error completionBlock:completionBlock];
                        }
                    }];
                }
                else {
                    // Transport error
                    NSDictionary *userInfo = transportError ? @{ NSUnderlyingErrorKey : transportError } : nil;
                    NSError *error = [NSError errorWithDomain:JRPCErrorDomain code:JRPCErrorTransportCode userInfo:userInfo];
                    [weakSelf completeJSONRPCRequest:jsonRPCRequest response:nil error:error completionBlock:completionBlock];
                }
            }];
        }
        else {
            // Request serialization failure
            typeof(weakSelf) sSelf = weakSelf;
            NSDictionary *userInfo = reqSerError ? @{ NSUnderlyingErrorKey : reqSerError } : nil;
            NSError *error = [NSError errorWithDomain:JRPCErrorDomain code:JRPCErrorRequestSerializationCode userInfo:userInfo];
            [sSelf completeJSONRPCRequest:jsonRPCRequest response:nil error:error completionBlock:completionBlock];
        }
    }];
}

- (void) serializeJSONRPCRequest:(NSDictionary*)jsonRPCRequest completion:(void (^_Nonnull)(NSData*, NSError*))completion {
    // Serialize request to JSON data on serializationqueue
    dispatch_async(self.serializationQueue, ^{
        NSError *reqSerError = nil;
        NSData *jsonRPCData = [NSJSONSerialization dataWithJSONObject:jsonRPCRequest options:0 error:&reqSerError];
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(jsonRPCData, reqSerError);
        });
    });
}

- (void) deserializeJSONRPCResponse:(NSData*)responseData completion:(void (^_Nonnull)(NSDictionary*, NSError*))completion {
    // Deserialize response data on serialization queue
    dispatch_async(self.serializationQueue, ^{
        NSError *respSerError = nil;
        NSDictionary *jsonRPCResponse = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&respSerError];
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(jsonRPCResponse, respSerError);
        });
    });
}

- (void) completeJSONRPCRequest:(NSDictionary*)jsonRPCRequest
                       response:(NSDictionary*)jsonRPCResponse
                          error:(NSError*)error
                completionBlock:(id)completionBlock {
    
    id jsonResult = nil;
    if (jsonRPCResponse) {
        jsonResult = jsonRPCResponse[kJSONRPCResultKey];
        // Map any JSON-RPC error returned by the server into an NSError and recurse
        NSDictionary* jsonRPCError = jsonRPCResponse[kJSONRPCErrorKey];
        if (jsonRPCError) {
            NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
            NSNumber *jsonErrorCode = jsonRPCError[kJSONRPCErrorCodeKey];
            NSString *jsonErrorMsg = jsonRPCError[kJSONRPCErrorMessageKey];
            id jsonErrorData = jsonRPCError[kJSONRPCErrorDataKey];
            if (jsonErrorCode) {
                userInfo[kJRPCErrorCodeKey] = jsonErrorCode;
            }
            if (jsonErrorMsg) {
                userInfo[kJRPCErrorMessageKey] = jsonErrorMsg;
            }
            if (jsonErrorData) {
                userInfo[kJRPCErrorDataKey] = jsonErrorData;
            }
            NSError *serverError = [NSError errorWithDomain:JRPCErrorDomain code:JRPCErrorServerResponseCode userInfo:[userInfo copy]];
            // Recurse with mapped JSON-RPC error received from server
            [self completeJSONRPCRequest:jsonRPCRequest response:nil error:serverError completionBlock:completionBlock];
            return;
        }
    }
    // complete with result/error
    dispatch_async(self.rpcCompletionQueue, ^{
        [self invokeCompletionBlock:completionBlock result:jsonResult error:error];
    });
}

- (void) invokeCompletionBlock:(id)completionBlock result:(id)result error:(NSError*)error {
    // We need to cast the completion block according to method signature
    CTBlockDescription *blockDesc = [[CTBlockDescription alloc] initWithBlock:completionBlock];
    NSMethodSignature *blockSig = blockDesc.blockSignature;
    // The block params start at index 2 (0 = ret, 1 = self), and we know 3 should be @"NSError" by convention
    // Note: for block signatures, we don't just get '@' for object params, we get an objc string literal, e.g. '@"NSString"' / '@"NSError"'
    // However, primitives DO follow standard objc type encodings:
    // See https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html
    const char *resultTypeEncodingStr = [blockSig getArgumentTypeAtIndex:1];
    if (1 == strlen(resultTypeEncodingStr)) {
        char resultTypeEncoding = resultTypeEncodingStr[0];
        switch (resultTypeEncoding) {
            case 'B': ((void (^)(_Bool, NSError*))blockDesc.block)([(NSNumber*)result boolValue], error); break; // char
            case 'c': ((void (^)(char, NSError*))blockDesc.block)([(NSNumber*)result charValue], error); break; // char
            case 'i': ((void (^)(int, NSError*))blockDesc.block)([(NSNumber*)result intValue], error); break;  // int
            case 's': ((void (^)(short, NSError*))blockDesc.block)([(NSNumber*)result shortValue], error); break;  // short
            case 'l': ((void (^)(long, NSError*))blockDesc.block)([(NSNumber*)result longValue], error); break;  // long
            case 'q': ((void (^)(long long, NSError*))blockDesc.block)([(NSNumber*)result longLongValue], error); break;  // long long
            case 'C': ((void (^)(unsigned char, NSError*))blockDesc.block)([(NSNumber*)result unsignedCharValue], error); break;  // unsigned char
            case 'I': ((void (^)(unsigned int, NSError*))blockDesc.block)([(NSNumber*)result unsignedIntValue], error); break;  // unsigned int
            case 'S': ((void (^)(unsigned short, NSError*))blockDesc.block)([(NSNumber*)result unsignedShortValue], error); break;  // unsigned short
            case 'L': ((void (^)(unsigned long, NSError*))blockDesc.block)([(NSNumber*)result unsignedLongValue], error); break;  // unsigned long
            case 'Q': ((void (^)(unsigned long long, NSError*))blockDesc.block)([(NSNumber*)result unsignedLongLongValue], error); break;  // unsigned long long
            case 'f': ((void (^)(float, NSError*))blockDesc.block)([(NSNumber*)result floatValue], error); break;  // float
            case 'd': ((void (^)(double, NSError*))blockDesc.block)([(NSNumber*)result doubleValue], error); break;  // double
            case '@': ((void (^)(id, NSError*))blockDesc.block)(result, error); break;  // Object
            default:
                [NSException raise:NSInternalInconsistencyException format:@"Unsupported completion type encoding for result: %c", resultTypeEncoding];
                break;
        }
    }
    else {
        // Strip obj string literal syntax to get object class name
        NSString *classStr = [NSString stringWithFormat:@"%s", resultTypeEncodingStr];
        classStr = [classStr stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"@\""]];
        Class argClass = NSClassFromString(classStr);
        // Process optional transformation of result if an alternative initializaer has been supplied
        id newResult = [self transformedResultForJSONResult:result class:argClass];
        // Override JSON-RPC result object with transformed result if available
        result = newResult ? : result;
        if (!result || (argClass && [result isKindOfClass:[argClass class]])) {
            // param type matches result type, so call completion directly
            ((void (^)(id, NSError*))blockDesc.block)(result, error);
        }
        else {
            [NSException raise:NSInternalInconsistencyException format:@"Unable to call completion block due to unsupported result type %s", resultTypeEncodingStr];
        }
    }
}

- (id) transformedResultForJSONResult:(id)result class:(Class)resultClass {
    // Called just before the JSON-RPC response result is returned to caller. A chance to transform it to the required type.
    // See if the class supports initialization by initWithJSONObject: (e.g. by extension category)
    id retResult = result;
    if (![retResult isKindOfClass:[resultClass class]]) {
        SEL jsonObjectInitializer = @selector(initWithJSONRPCResponseResult:);
        if ([resultClass respondsToSelector:@selector(instancesRespondToSelector:)] &&
            [resultClass instancesRespondToSelector:jsonObjectInitializer]) {
            id newResult = [resultClass alloc];
            // workaround compiler warning "PerformSelector may cause a leak because its selector is unknown"
            // [newResult performSelector:jsonObjectInitializer withObject:result];
            IMP imp = [newResult methodForSelector:jsonObjectInitializer];
            id (*func)(id, SEL, id) = (void*)imp;
            newResult = func(newResult, jsonObjectInitializer, result);
            if (newResult) {
                retResult = newResult;
            }
        }
    }
    return retResult;
}

- (id) transformedJSONParameterForParameter:(id)parameter {
    // Called just before the parameter is added to the JSON-RPC request. A chance to transform it to a supported JSON type;
    id retParam = parameter;
    if (![[self class] isValidJSONObject:parameter] &&
        [parameter respondsToSelector:@selector(jsonRPCRequestRepresentation)]) {
        id newParam = [parameter jsonRPCRequestRepresentation];
        if (newParam) {
            retParam = newParam;
        }
    }
    return retParam;
}

+ (BOOL) isValidJSONObject:(id)obj {
    // Test if its a valid type. We wrap obj in an array since [NSJSONSerialization isValidJSONObject] expects top level to be an array or dictionary, but we call this for transformed request parmameters which are within the topl level JSON-RPC request dictionary
    return [NSJSONSerialization isValidJSONObject:@[obj]];
}

#pragma mark - NSProxy

- (BOOL)respondsToSelector:(SEL)selector {
    struct objc_method_description description = protocol_getMethodDescription(self.protocol, selector, YES, YES);
    return description.name != NULL;
}

- (nullable NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    struct objc_method_description methodDesc = protocol_getMethodDescription(self.protocol, sel, YES, YES);
    if (methodDesc.name)
    {
        NSMethodSignature *sig = [NSMethodSignature signatureWithObjCTypes:methodDesc.types];
        return sig; // forwardInvocation WILL be called
    }
    return nil; // forwardInvocation will NOT be called
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    NSMutableDictionary *jsonRPCRequest = [@{
                                            kJSONRPCVersionKey      : kJSONRPCVersion,
                                            kJSONRPCRequestIdKey    : @(self.jsonRPCRequestId++)
                                            } mutableCopy];
    // Grab parameter values from the invocation. These will be the same regardless of JSON-RPC parameter structure
    NSArray *paramValues = [self paramValuesFromInvocation:invocation];
    // Grab the completion block from last param of invocation
    __unsafe_unretained id completionBlock = nil;
    [invocation getArgument:&completionBlock atIndex:invocation.methodSignature.numberOfArguments - 1];
    // Extract method and param names from selector
    NSString* selStr = NSStringFromSelector(invocation.selector);
    NSMutableArray *paramNames = [[selStr componentsSeparatedByString:@":"] mutableCopy];
    // We expect >= TWO elements in the array, with the last an empty string, since a selector string with >= 1 param should always end with a colon ':'
    if (paramNames.count < 2) {
        [NSException raise:NSInternalInconsistencyException format:@"Proxied selectors MUST have AT LEAST ONE parameter, which should be the completion block"];
    }
    NSAssert(((NSString*)paramNames.lastObject).length == 0, @"Selector parse error, SEL does not end in colon: %@", selStr);
    [paramNames removeLastObject];    // Ditch the trailing empty string
    if (JRPCParameterStructureByName == self.paramStructure) {
        // Parse out method name from first component of selector. i.e <methodName>With<Param1Name>:
        NSString *selFirstComp = paramNames[0];
        NSRange rangeOfWith = [selFirstComp rangeOfString:@"With"];
        if (NSNotFound == rangeOfWith.location) {
            [NSException raise:NSInternalInconsistencyException format:@"Selector: %@ does not match JSON-RPC params by-name naming convention: <methodName>With<ParamName>...", selStr];
        }
        jsonRPCRequest[kJSONRPCMethodKey] = [selFirstComp substringToIndex:rangeOfWith.location];
        // Drop the last parameter, it's the completion block which does not participate in JSON-RPC
        [paramNames removeLastObject];
        if (paramNames.count > 0) {
            // Only include "params" key in JSON-RPC payload if at least one key-value pair
            // replace first param name with the part following 'With' so that paramNames is now the parameter list
            NSString *firstParamName = [selFirstComp substringFromIndex:rangeOfWith.location + rangeOfWith.length];
            // convert first char of firstParamName to lower case
            if (firstParamName.length < 2) {
                firstParamName = [firstParamName lowercaseString];
            } else {
                firstParamName = [NSString stringWithFormat:@"%@%@", [[firstParamName substringToIndex:1] lowercaseString], [firstParamName substringFromIndex:1]];
            }
            paramNames[0] = firstParamName;
            // Now create params dict for JSON-RPC by-name
            if (paramValues.count != paramNames.count) {
                [NSException raise:NSInternalInconsistencyException format:@"Param name/value mismatch: names: %@ values: %@ ", paramNames, paramValues];
            }
            NSDictionary *params = [NSDictionary dictionaryWithObjects:paramValues forKeys:paramNames];
            jsonRPCRequest[kJSONRPCParamsKey] = params;
        }
    }
    else {
        // By-Position: method name is entire first component of the selector. 'doSomethingWithCompletion:' is NOT supported, should be simply 'doSomething:'
        jsonRPCRequest[kJSONRPCMethodKey] = paramNames[0];
        if (paramValues.count > 0) {
            // Only include "params" key in JSON-RPC payload if at least one key-value pair
            jsonRPCRequest[kJSONRPCParamsKey] = paramValues;
        }
    }
    
    if (self.transportPerformsSerialization) {
        // Transport prefers to handle request & response JSON serialization
        [self dispatchJSONRPCRequest:[jsonRPCRequest copy] completionBlock:completionBlock];
    }
    else {
        // This class will handle request & response JSON serialization
        [self dispatchSerializedJSONRPCRequest:[jsonRPCRequest copy] completionBlock:completionBlock];
    }
}

@end
