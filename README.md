# JSON RPC Proxy

 Implements the [JSON-RPC 2.0 specification](http://www.jsonrpc.org/specification) for protocols in Objective-C and Swift (Objective-C compatible protocols marked 
 ```@objc``` only)

 This allows you to write your RPC function declarations and callbacks in Objective-C or Swift using native types. The proxy will create the JSON-RPC request payload object, and convert the JSON-RPC response into a callback via a block/closure, marshalling all parameter and return types between Objective-C/Swift & JSON automatically.

 The proxy is transport independent. A client provides a conformant 'transport' component that can take the request object from the proxy and return the response to it. The transport may optionally perform the JSON [de]serialization, or opt to have the proxy perform this duty and deal only with the serialized data.

 ## Terminology
 * This document will use the terms ```method``` and ```function``` interchangebaly as is common between Objective-C and Swift.
* This document will use the terms ```parameter``` and ```argument``` interchangeably in reference to methods/functions as is common between Objective-C and Swift.
  
## Getting Started

After [installing](#installing) follow the steps in this section to get your JSON-RPC calls up & running, and/or take a look at the [sample code](#samples)

### Write your protocol methods following convention
In order for the proxy to be able to successfully translate your RPC method names, parameters and return types to and from JSON-RPC, you must ensure your protocol methods adhere to some basic conventions:

* Since JSON-RPC is asynchronous by nature, the return type of ALL proxied methods should ALWAYS be ```void```. Return values (and errors) are passed in completion blocks/closures which MUST be the last parameter of the method.
* In Swift, all methods (or the protocol definition itself) should be marked ```@objc``` and use compatible/bridged types. This is required since the data marshalling is performed through the Objective-C runtime.
* For ```by-position```, parameters should NOT be named. In Objective-C, the first component of the selector is the method name. All other components of the selector should NOT be named. In Swift all function arguments should not have labels associated with them (```_```)
* For ```by-name```, parameters should be named. In Objective-C the first component of the selector should separate the method name from the first parameter name by the word ```With```. This is analagous to the Objective-C/Swift compatibility conventions (e.g. ```#selector```). In Swift, all function arguments should have labels associated with them.

#### Examples
##### BY-POSITION
```obj-c
// Objective-C
@protocol MyProxiedProtocol
- (void) addIntegers:(NSInteger)first :(NSInteger)second :(void (^)(NSInteger result, NSError *error))completion;
@end
```
```swift
// Swift
@objc protocol MyProxiedProtocol {
    func addIntegers(first:Int, second:Int, completion:(Any?, NSError) -> Void) -> Void
}
```
##### BY-NAME
```obj-c
// Objective-C
@protocol MyProxiedProtocol
- (void) addIntegersWithFirstValue:(NSInteger)first secondValue:(NSInteger)second completion:(void (^)(NSInteger result, NSError *error))completion;
@end
```
```swift
// Swift
@objc protocol MyProxiedProtocol {
    func addIntegers(firstValue first:Int, secondValue second:Int, completion completion:(Any?, NSError) -> Void) -> Void
}
```

### Create a transport component
Like the JSON-RPC 2.0 specification, the proxy is transport indpendent. This means it does not impose a particular method of sending the request to, and receiving the response from the server. 

The client must provide an object conforming to the ```JRPCProxyTransport``` protocol to the proxy during intialization. This object is responsible for the transport of the request & response and may optionally perform JSON serialization.

```obj-c
// Objective-C
@interface MyJSONRPCTransport : NSObject<JRPCProxyTransport>
// ...
@end
```
```swift
// Swift
@objc class MyJSONRPCTransport : NSObject, JRPCProxyTransport {
// ...
}
```
You choose your serialization strategy by implementing ONE of the two optional methods of ```JRPCProxyTransport```. If you implement both methods, the proxy will choose to delegate  JSON serialiazation to the transport. If you implement neither, or do not supply a transport, the proxy will throw an exception when initialized.

#### Transports that do not perform JSON serialization
You may choose this strategy if you prefer to delegate the serialization to/from JSON to the proxy. This is suitable for e.g. HTTP[S] transport where the HTTP protocol & library can easily match the request & response for multiple concurrent requests. Your transport will deal only with opaque ```Data``` objects.

To choose this strategy, implement the following method:
```obj-c
// Objective-C
- (void) sendJSONRPCPayloadWithRequestData:(NSData*)payload
                completionQueue:(dispatch_queue_t)completionQueue
                     completion:(JRPCTransportDataCompletion)completion;
```
```swift
// Swift
func sendJSONRPCPayload(withRequest payload: Data, completionQueue: DispatchQueue, completion: @escaping JRPCTransportDataCompletion) -> Void
```

#### Transports that perform JSON serialization
You may choose this strategy if you prefer to perform the serialization to/from JSON in your own code, and/or require visibility of the JSON-RPC request & response objects. This is suitable for e.g. a duplex web socket transport where you need access to the JSON-RPC request id to match a response to the corresponding request when sending multiple concurrent requests that may return in any order.

To choose this strategy, implement the following method:
```obj-c
// Objective-C
- (void) sendJSONRPCPayloadWithRequestObject:(NSDictionary*)jsonRPCRequest
                completionQueue:(dispatch_queue_t)completionQueue
                     completion:(JRPCTransportObjectCompletion)completion;
```
```swift
// Swift
func sendJSONRPCPayload(withRequestObject payload: Dictionary<String, AnyObject>, completionQueue: DispatchQueue, completion: @escaping JRPCTransportObjectCompletion) -> Void
```

Your transport component may use the methods and key constants in the ```NSDictionary+JSONRPC``` category to access the JSON-RPC request & response dictionary objects.

### Create a proxy for your protocol using your transport and invoke your methods
```obj-c
// Objective-C
// - create a transport
id<JRPCProxyTransport> transport = [[MyJSONRPCTransport alloc] init];
// - create the proxy
JRPCAbstractProxy *proxy = [JRPCAbstractProxy proxyForProtocol:@protocol(MyProxiedProtocol)
  paramStructure:JRPCParameterStructureByName
       transport:transport];
// - invoke methods
[proxy addIntegersWithFirstValue:10 secondValue:32 completion:^(NSInteger result, NSError *error) {
    // ...
}];

```
```swift
// Swift
// - create a transport
let transport = MyJSONRPCTransport()
// - create the proxy
let proxy = JRPCAbstractProxy.proxy(for: MyProxiedProtocol.self, paramStructure: .byName, transport: transport) as AnyObject
// - invoke methods
proxy.addIntegers(firstValue: 10, secondValue: 32, completion: { (result, error) in
    // ...
})
```
### Samples

#### RandomLottery
This sample application is written in Swift, and demonstrates the use of the [random.org API](https://api.random.org/json-rpc/1/) to randomly pick lottery numbers.

Note: You should obtain your own [API key](https://api.random.org/api-keys) from random.org and set it's value in the ```RANDOM_ORG_API_KEY``` environment variable by editing the scheme, replacing the default value of ```00000000-0000-0000-0000-000000000000```

## Installing

The easiest way to install JRPCProxy into your project is via [CocoaPods](https://cocoapods.org/) or [Carthage](https://github.com/Carthage/Carthage)

### CocoaPods

Add 'JRPCProxy' as a dependency in your ```Podfile```
```
pod 'JRPCProxy'
```

If you are using the [```use_frameworks!```](https://guides.cocoapods.org/syntax/podfile.html#use_frameworks_bang) attribute for your target you can simply import the module:
```swift
// Swift
import JRPCProxy
```
```obj-c
// Objective-C
@import JRPCProxy;
```
Alternatively, for a static library, import the umbrella header into either your source files or pre-compiled header (Objective-C only)
```obj-c
import "JRPCProxy.h"
```

### Carthage

Add 'JRPCProxy' as a dependency in your ```Cartfile```
```
github "youviewtv/json-rpc-proxy"
```
Link ```JRPCProxy.framework``` in your project and import the module into your code:
```swift
// Swift
import JRPCProxy
```
```obj-c
// Objective-C
@import JRPCProxy;
```


### Manual

Copy all the files in the ```JRPCProxy``` folder into your project.

Import the umbrella header ```JRPCProxy.h``` into your [bridging header](https://developer.apple.com/library/content/documentation/Swift/Conceptual/BuildingCocoaApps/MixandMatch.html) for Swift, or pre-compiled header for Objective-C

## Scope
### Supported Features
* ```by-name``` and ```by-position``` parameter structures
* Optional JSON serialization of request object and deserialization of the response object.
* Automatic unique request id synthesis.
* Automatic marshalling of basic data types between native and JSON types.
* Support for extending marshalling to custom data types.
* JSON-RPC errors are mapped to native error types.

### Limitations & Omissions
* Only version 2.0 of JSON-RPC is supported (not compatible with version 1.0)
* Notifications are not supported.
* Batch requests are not supported.
* Server or 'symmetric' roles are not supported. Client role only.

## Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md)

## Authors

* **Neil Davis** - *Initial work* - [YouView](https://github.com/youviewtv)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details

## Acknowledgments

* Thanks to **[Oliver Letterer](https://github.com/OliverLetterer)** for use of [CTBlockDescription](https://github.com/ebf/CTObjectiveCRuntimeAdditions/blob/master/CTObjectiveCRuntimeAdditions/CTObjectiveCRuntimeAdditions/CTBlockDescription.h) under terms of the [MIT license](https://github.com/ebf/CTObjectiveCRuntimeAdditions/blob/master/LICENSE)
