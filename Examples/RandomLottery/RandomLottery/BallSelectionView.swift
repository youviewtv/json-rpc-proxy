//
//  BallSelectionView.swift
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

import UIKit

@IBDesignable class BallSelectionView: UIStackView {

    @IBInspectable var numbers : [Int] {
        didSet {
            if numbers.count != self.arrangedSubviews.count {
                self.setupArrangedSubviews()
            } else {
                for i in 0..<numbers.count {
                    (self.arrangedSubviews[i] as! BallView).number = numbers[i]
                }
            }
        }
    }
    
    override init(frame: CGRect) {
        self.numbers = [Int]()
        super.init(frame: frame)
        self.setupArrangedSubviews()
    }
    
    required init(coder: NSCoder) {
        self.numbers = [Int]()
        super.init(coder: coder)
        self.setupArrangedSubviews()
    }
    
    func setupArrangedSubviews() {
        // Remove existing arranged subviews
        for subview in self.arrangedSubviews {
            self.removeArrangedSubview(subview)
        }
        // Add new arranged subviews
        for i in 0..<numbers.count {
            let ball = BallView(frame: CGRect())
            ball.number = numbers[i]
            ball.tag = i
            ball.translatesAutoresizingMaskIntoConstraints = false
            ball.heightAnchor.constraint(equalTo: ball.widthAnchor).isActive = true
            self.addArrangedSubview(ball)
        }
    }
}
