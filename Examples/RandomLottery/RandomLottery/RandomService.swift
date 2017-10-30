//
//  RandomService.swift
//  RandomLottery
//
//  Created on 17/10/2017.
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

import Foundation

// The service is actually provided by random.org via JSON-RPC
// https://api.random.org/json-rpc/1/basic
// We just create a protocol to match the methods and use the JSON-RPC proxy ...
@objc protocol RandomDotOrgService {
    func generateIntegers(apiKey key:String, n num:Int, min minNum:Int, max maxInt:Int, replacement replace:Bool, completion completionBlock:(NSArray?, NSError?)->Void)
}

// We add an extension to Array to allow the proxy to extract the result from response
@objc extension NSArray {
    convenience init?(jSONRPCResponseResult : Dictionary<String, Any>) {
        guard let random: Dictionary<String, Any> = jSONRPCResponseResult["random"] as? Dictionary<String, Any> else {
            return nil
        }
        guard let numbers: [Int] = random["data"] as? [Int] else {
            return nil
        }
        self.init(array: numbers)
    }
}
