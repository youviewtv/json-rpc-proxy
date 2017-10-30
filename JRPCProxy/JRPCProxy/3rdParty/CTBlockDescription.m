//
//  CTBlockDescription.m
//  CTBlockDescription
//
//  Created by Oliver Letterer on 01.09.12.
//  Copyright (c) 2012 olettere. All rights reserved.
//

/*
 MIT LICENSE: https://github.com/ebf/CTObjectiveCRuntimeAdditions/blob/master/LICENSE
 
 Copyright (c) 2012 EBF-EDV Beratung Föllmer GmbH
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import "CTBlockDescription.h"

@implementation CTBlockDescription

- (id)initWithBlock:(id)block
{
    if (self = [super init]) {
        _block = block;
        
        struct CTBlockLiteral *blockRef = (__bridge struct CTBlockLiteral *)block;
        _flags = blockRef->flags;
        _size = blockRef->descriptor->size;
        
        if (_flags & CTBlockDescriptionFlagsHasSignature) {
            void *signatureLocation = blockRef->descriptor;
            signatureLocation += sizeof(unsigned long int);
            signatureLocation += sizeof(unsigned long int);
            
            if (_flags & CTBlockDescriptionFlagsHasCopyDispose) {
                signatureLocation += sizeof(void(*)(void *dst, void *src));
                signatureLocation += sizeof(void (*)(void *src));
            }
            
            const char *signature = (*(const char **)signatureLocation);
            _blockSignature = [NSMethodSignature signatureWithObjCTypes:signature];
        }
    }
    return self;
}

- (BOOL)isCompatibleForBlockSwizzlingWithMethodSignature:(NSMethodSignature *)methodSignature
{
    if (_blockSignature.numberOfArguments != methodSignature.numberOfArguments + 1) {
        return NO;
    }
    
    if (strcmp(_blockSignature.methodReturnType, methodSignature.methodReturnType) != 0) {
        return NO;
    }
    
    for (int i = 0; i < methodSignature.numberOfArguments; i++) {
        if (i == 1) {
            // SEL in method, IMP in block
            if (strcmp([methodSignature getArgumentTypeAtIndex:i], ":") != 0) {
                return NO;
            }
            
            if (strcmp([_blockSignature getArgumentTypeAtIndex:i + 1], "^?") != 0) {
                return NO;
            }
        } else {
            if (strcmp([methodSignature getArgumentTypeAtIndex:i], [_blockSignature getArgumentTypeAtIndex:i + 1]) != 0) {
                return NO;
            }
        }
    }
    
    return YES;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@: %@", [super description], _blockSignature.description];
}

@end
