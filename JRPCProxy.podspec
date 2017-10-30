Pod::Spec.new do |s|
  s.name             = 'JRPCProxy'
  s.version          = '1.0.0'
  s.summary          = 'An implmentation of the JSON-RPC 2.0 specification for Objective-C protocols.'


  s.description      = <<-DESC
Implements the JSON-RPC 2.0 specification for protocols in Objective-C and Objective-C compatible protocols (marked 
 ```@objc```) in Swift.

 This allows you to write your RPC function declarations and callbacks in Objective-C or Swift using native types. The proxy will create the JSON-RPC request payload object, and convert the JSON-RPC response into a callback via a block/closure.

 The proxy is transport independent. A client provides a conformant component that can take the request object and return the response, optionally including the JSON encoding/decoding.
                       DESC

  s.homepage         = 'https://github.com/youviewtv/json-rpc-proxy/'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Neil Davis' => 'neil.davis2@youview.com' }
  s.source           = { :git => 'https://github.com/youviewtv/json-rpc-proxy.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files = 'JRPCProxy/JRPCProxy/**/*.{h,m}'
  s.public_header_files = 'JRPCProxy/JRPCProxy/*.h'
end
