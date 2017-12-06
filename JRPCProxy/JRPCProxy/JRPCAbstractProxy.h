//
//  JRPCAbstractProxy.h
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

@import Foundation;
@protocol JRPCProxyTransport;

NS_ASSUME_NONNULL_BEGIN

/**
 JRPCParameterStructure determines the 'parameter structure' of the JSON-RPC service being proxied
 See http://www.jsonrpc.org/specification section '4.2 Parameter Structures'
 */
typedef NS_ENUM(NSUInteger, JRPCParameterStructure)  {
    /** Method parameters are provided BY-NAME */
    JRPCParameterStructureByName      = 0,
    /** Method parameters are provided BY-POSITION */
    JRPCParameterStructureByPosition
};

/**
 JRPCAbstractProxy implements the JSON-RPC 2.0 protocol for Objective-C protocols
 
 Convention for protocol method/param mapping to JSPN-RPC method name + args:
 JSON-RPC requests send parameters either BY-NAME (using an Object a.k.a Dictionary) or BY-POSITION (using an Array)
 See http://www.jsonrpc.org/specification section 4.2 Parameter Structures:
 These are mapped onto Obj-C method selectors in proxied protocols as follows:
 
 Since JSON-RPC is async by nature, the return type of proxied methods should ALWAYS be void
 The return value from the JSON-RPC call (or an error) will be passed in a completion block which should be the LAST argument in the proxied method
 
 i.e.
 BY-NAME (JRPCParameterStructureByName):
 Objective-C:
 - (void) <methodName>With<Param1Name>:(Param1Type)param1Value param2Name:(param2Type)param2Value ... completion:(void (^)(<Return Type> result, NSError *error))completion
 Note: The convention of using 'With' in the leading part of the SEL to separate the method name from the first parameter name. This is the same behaviour as
 using #selector with functions in Swift using named paramaters and it is this that enables compatibility with protocols declared @objc in Swift:
 Swift:
 @objc func <methodName>(<Param1Name> param1Value:<Param1Type>, <Param2Name> param2Value:<Param2Type> ... completion completion:(Any?, NSError) -> Void) -> Void
 
 BY-POSITION (JRPCParameterStructureByPosition):
 Objective-C:
 - (void) methodName:(Param1Type)param1Value :(param2Type)param2Value ... :(void (^)(<Return Type> result, NSError *error))completion
 Note: There are no param names. The leading part of the selector IS the method name in entireity. Other params have no names including the trailing completion block
 Swift:
 @objc func <methodName>(_ param1Value:<Param1Type>, _ param2Value:<Param2Type> ... _ completion:(Any?, NSError) -> Void) -> Void
*/
@interface JRPCAbstractProxy : NSProxy

/**
 Factory method to create and return a proxy for a given protocol
 @param protocol The Objective-C protocol that will be implmented by the proxy
 @param paramStructure The parameter structre of the JSON-RPC service to be proxied
 @param transport An object conforming to the JRPCProxyTransport protocol that will be used to make the async JSON-RPC requests
 @return An initialized proxy object for the protocol
 @discussion Note only required instance methods on the protocol are supported (no support for optional and/or class methods)
 */
+ (id) proxyForProtocol:(Protocol *)protocol
         paramStructure:(JRPCParameterStructure)paramStructure
              transport:(id<JRPCProxyTransport>)transport;

/**
 The dispatch queue that will be used to call the completion blocks of proxied protocol methods
 If nil (the default) then the result of calling dispatch_get_main_queue() will be used
 */
@property(nonatomic, strong, nullable) dispatch_queue_t rpcCompletionQueue;

/** init is unavailable */
- (instancetype) init __attribute__((unavailable("init is not available, use proxyForProtocol:transport: class method")));

NS_ASSUME_NONNULL_END

@end
