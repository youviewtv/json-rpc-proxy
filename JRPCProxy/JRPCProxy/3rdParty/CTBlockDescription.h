//
//  CTBlockDescription.h
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

@import Foundation;

struct CTBlockLiteral {
    void *isa; // initialized to &_NSConcreteStackBlock or &_NSConcreteGlobalBlock
    int flags;
    int reserved;
    void (*invoke)(void *, ...);
    struct block_descriptor {
        unsigned long int reserved;	// NULL
    	unsigned long int size;         // sizeof(struct Block_literal_1)
        // optional helper functions
    	void (*copy_helper)(void *dst, void *src);     // IFF (1<<25)
    	void (*dispose_helper)(void *src);             // IFF (1<<25)
        // required ABI.2010.3.16
        const char *signature;                         // IFF (1<<30)
    } *descriptor;
    // imported variables
};

enum {
    CTBlockDescriptionFlagsHasCopyDispose = (1 << 25),
    CTBlockDescriptionFlagsHasCtor = (1 << 26), // helpers have C++ code
    CTBlockDescriptionFlagsIsGlobal = (1 << 28),
    CTBlockDescriptionFlagsHasStret = (1 << 29), // IFF BLOCK_HAS_SIGNATURE
    CTBlockDescriptionFlagsHasSignature = (1 << 30)
};
typedef int CTBlockDescriptionFlags;



@interface CTBlockDescription : NSObject

@property (nonatomic, readonly) CTBlockDescriptionFlags flags;
@property (nonatomic, readonly) NSMethodSignature *blockSignature;
@property (nonatomic, readonly) unsigned long int size;
@property (nonatomic, readonly) id block;

- (id)initWithBlock:(id)block;

- (BOOL)isCompatibleForBlockSwizzlingWithMethodSignature:(NSMethodSignature *)methodSignature;

@end
