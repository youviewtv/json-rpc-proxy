//
//  JRPCProxyTestsBase.m
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

#import "JRPCProxyTestsBase.h"
#import "JRPCProxyTransportStub.h"

@interface JRPCProxyTestsBase()
@property (nonatomic, strong) JRPCAbstractProxy *SUT;
@property (nonatomic, strong) JRPCProxyTransportStub *jsonRPCTransport;
@end

@implementation JRPCProxyTestsBase

// Utility function to pull param by index (array) or key (dictionary) from params object
- (id) paramForIndex:(NSUInteger)index orKey:(NSString*)key inParams:(id)params {
    if ([params isKindOfClass:[NSArray class]]) {
        return ((NSArray*)params)[index];
    }
    else if ([params isKindOfClass:[NSDictionary class]]) {
        return ((NSDictionary*)params)[key];
    }
    return nil;
}

- (void)setUp {
    [super setUp];
    self.jsonRPCTransport = [[JRPCProxyTransportStub alloc] init];
    self.jsonRPCTransport.performsSerialization = self.transportStubPerformsSerialization;
    self.SUT = [JRPCAbstractProxy proxyForProtocol:self.protocol
                                              paramStructure:self.paramsStructure
                                                   transport:self.jsonRPCTransport];
    
#pragma mark - Stubbed methods with results
    
    [self.jsonRPCTransport configureMethod:@"methodTakesNoParamsReturnsHelloWorldString" result:^id(id params) {
        return @"Hello World!";
    }];
    
    [self.jsonRPCTransport configureMethod:@"appendStrings" result:^id(id params) {
        NSString *str1 = [self paramForIndex:0 orKey:@"string1" inParams:params];
        NSString *str2 = [self paramForIndex:1 orKey:@"string2" inParams:params];
        return [str1 stringByAppendingString:str2];
    }];
    
    [self.jsonRPCTransport configureMethod:@"addIntegers" result:^id(id params) {
        NSInteger int1 = [[self paramForIndex:0 orKey:@"first" inParams:params] integerValue];
        NSInteger int2 = [[self paramForIndex:1 orKey:@"second" inParams:params] integerValue];
        return [NSNumber numberWithInteger:(int1 + int2)];
    }];
    
    // All of the echo methods take a single param which is returned as the result
    NSArray<NSString*> *echoMethods = @[
                                        @"echoBool", @"echoChar", @"echoShort", @"echoInt", @"echoLong", @"echoInteger",
                                        @"echoUnsignedChar", @"echoUnsignedShort", @"echoUnsignedInt", @"echoUnsignedLong", @"echoUnsignedInteger",
                                        @"echoFloat", @"echoDouble", @"echoString", @"echoTransformable"
                                        ];
    [self.jsonRPCTransport configureMethods:echoMethods result:^id(id params) {
        return [self paramForIndex:0 orKey:@"value" inParams:params];
    }];
    
#pragma mark - Stubbed methods with errors
    
    [self.jsonRPCTransport configureMethod:@"methodReturnsErrorNotInt" errorCode:-32000 errorMessage:@"foobar" errorData:nil];
    [self.jsonRPCTransport configureMethod:@"methodReturnsErrorNotDouble" errorCode:-32001 errorMessage:@"foobar" errorData:nil];
}

- (void)tearDown {
    self.SUT = nil;
    self.jsonRPCTransport = nil;
    self.protocol = nil;
    self.transportStubPerformsSerialization = NO;
    self.paramsStructure = JRPCParameterStructureByName;
    [super tearDown];
}

@end

#pragma mark - JRPCTestTransformableResult

@implementation JRPCTestTransformableResult
// Properties are synthesized
// We add JSON-RPC initializer support in JSONRPC_Init category below
- (BOOL) isEqual:(id)object {
    if (self == object)
    {
        return YES;
    }
    
    if (![object isKindOfClass:[self class]])
    {
        return NO;
    }
    
    JRPCTestTransformableResult *result = (JRPCTestTransformableResult*)object;
    return (self.unsignedInteger == result.unsignedInteger &&
            [self.string isEqualToString:result.string]);
}
@end

@implementation JRPCTestTransformableResult (JSONRPC_Init)

#pragma mark - JRPCTestTransformableResult<JRPCTransformable>

/** Initialize JRPCTestTransformableResult from a JSON object passed by JRPCAbstractProxy */
- (instancetype) initWithJSONRPCResponseResult:(id)jsonObject {
    self = [super init];
    if ([jsonObject isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dict = (NSDictionary*)jsonObject;
        self.string = dict[@"string"];
        self.unsignedInteger = [dict[@"unsignedInteger"] unsignedIntegerValue];
    }
    else {
        self = nil; // Failed initialization
    }
    return self;
}

/** Return a valid JSON serializable object to JRPCAbstractProxy */
- (id) jsonRPCRequestRepresentation {
    return @ {
        @"string"           : self.string,
        @"unsignedInteger"  : @(self.unsignedInteger)
    };
}

@end
