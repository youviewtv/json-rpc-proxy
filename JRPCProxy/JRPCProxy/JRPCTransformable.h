//
//  JRPCTransformable.h
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

/**
 JRPCTransformable defines the methods that allow a client to extend support of custom types to JSON-RPC or modify the existing behaviour for supported types.
 You would typically add support to existing types by implementing a category/extension to conform to this protocol. or conform to it in your own custom types.
 */
@protocol JRPCTransformable <NSObject>

@optional

/**
 An initializer that will be called with the JSON-RPC response result object.
 @param result The 'top level' JSON object passed as the result from a JSON-RPC response. They type will depend on the JSON-RPC server method specifications
 @return An initialzed object.
 */
- (id) initWithJSONRPCResponseResult:(id)result;

/**
 A method to allow a type to determine its JSON representation when included as a parameter in a JSON-RPC request.
 @return a valid object that can be used in a call to NSJSONSerialization when forming the JSON-RPC request.
 @see NSJSONSerialization for a list of the valid types.
 */
- (id) jsonRPCRequestRepresentation;

@end
