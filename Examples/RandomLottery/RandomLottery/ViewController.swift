//
//  ViewController.swift
//  RandomLottery
//
//  Created on 16/10/2017.
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

import UIKit
import JRPCProxy

class ViewController: UIViewController, JRPCProxyTransport {

    @IBOutlet weak var ballSelectionView: BallSelectionView!
    @IBOutlet weak var maxNumberSlider: UISlider!
    @IBOutlet weak var maxNumberLabel: UILabel!
    
    var randomService :AnyObject! = nil
    let apiKey :String
    let defaultMaxNumber :Int = 59;
    
    //MARK: Initializers
    
    required init?(coder aDecoder: NSCoder) {
        if let apiKey = ProcessInfo.processInfo.environment["RANDOM_ORG_API_KEY"] {
            self.apiKey = apiKey
        } else {
            self.apiKey = ""
        }
        super.init(coder: aDecoder)
        randomService = (JRPCAbstractProxy.proxy(for: RandomDotOrgService.self, paramStructure: .byName, transport: self) as AnyObject)
    }
    
    //MARK: UIViewController overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Use device for initial set of random numbers
        var initialNumbers :[Int] = [Int]()
        while initialNumbers.count < 6 {
            let newNum = Int(arc4random_uniform(UInt32(self.maxNumberSlider.value))) + 1
            if initialNumbers.index(of: newNum) == nil {
                initialNumbers.append(newNum)
            }
        }
        ballSelectionView.numbers = initialNumbers.sorted()
        
        // Setup controls
        self.maxNumberSlider.minimumValue = Float(self.ballSelectionView.numbers.count)
        self.maxNumberSlider.maximumValue = Float(BallView.maxBallNumber)
        self.maxNumberSlider.value = Float(self.defaultMaxNumber)
        self.didChangeMaxValue(self.maxNumberSlider)
    }

    //MARK: Actions
    
    @IBAction func didChangeMaxValue(_ sender: UISlider) {
        // Max number slider value changed, update label
        self.maxNumberLabel.text = String(Int(sender.value))
    }
    
    @IBAction func didPressNewNumbersButton(_ sender: UIButton) {
        // Get some new numbers using JSON-RPC
        self.ballSelectionView.numbers = [0,0,0,0,0,0];
        UIApplication.shared.isNetworkActivityIndicatorVisible = true;
        self.randomService?.generateIntegers(apiKey: apiKey, n: 6,
                                             min: BallView.minBallNumber, max: Int(self.maxNumberSlider.value),
                                             replacement: false,
                                             completion: { (newNumbers, error) in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false;
            if let newNumbers = newNumbers as? [Int] {
                ballSelectionView.numbers = newNumbers.sorted()
            } else if let error = error {
                let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        })
    }
    
    //MARK: JRPCProxyTransport
    
    func sendJSONRPCPayload(withRequest payload: Data, completionQueue: DispatchQueue?, completion: @escaping JRPCTransportDataCompletion) {
        // Fire off a request to random.org over via JSON-RPC over HTTPS
        var request = URLRequest(url: URL(string: "https://api.random.org/json-rpc/1/invoke")!)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = payload
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            var dispatchQueue :DispatchQueue! = nil;
            if let queue = completionQueue {
                dispatchQueue = queue
            }
            else {
                dispatchQueue = DispatchQueue.main
            }
            dispatchQueue.async {
                completion(data, error)
            }
        }
        task.resume()
     }
}

