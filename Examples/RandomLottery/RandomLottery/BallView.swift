//
//  BallView.swift
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
import QuartzCore



@IBDesignable class BallView: UIView {
    
    static let kBallStrokeWidth: CGFloat = 4.0
    static let minBallNumber: Int = 1
    static let maxBallNumber: Int = 99
    
    weak var label : UILabel!
    
    @IBInspectable var number :Int = 0 {  // 0 = unassigned, 1..59 valid range
        didSet {
            if BallView.minBallNumber...BallView.maxBallNumber ~= number {
                self.label.text = String(format:"%02d", number)
            } else {
                self.label.text = "??"
            }
            self.setNeedsDisplay()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
        setupConstraints()
    }
    
    func setupViews() {
        self.backgroundColor = UIColor.clear
        let label = UILabel(frame: CGRect())
        label.numberOfLines = 1
        label.textAlignment = .center
        label.baselineAdjustment = .alignCenters
        label.backgroundColor = UIColor.clear
        label.textColor = UIColor.black
        label.font = UIFont.boldSystemFont(ofSize: 64.0)
        label.adjustsFontSizeToFitWidth = true;
        label.minimumScaleFactor = 0.10;
        self.addSubview(label)
        self.label = label
    }
    
    func setupConstraints() {
        self.label.translatesAutoresizingMaskIntoConstraints = false
        self.label.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        self.label.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        let m = 1.0/sqrt(2.0)
        self.label.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: CGFloat(m)).isActive = true
        self.label.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: CGFloat(m)).isActive = true
    }
    
    func fillColor() -> UIColor {
        switch number {
        case 1...9: return .white
        case 10...19: return .lottery_brown
        case 20...29: return .lottery_pink
        case 30...39: return .lottery_orange
        case 40...49: return .lottery_yellow
        case 50...59: return .lottery_green
        case 60...69: return .lottery_marine
        case 70...79: return .lottery_blue
        case 80...89: return .lottery_purple
        default: return .gray
        }
    }

    override func draw(_ rect: CGRect) {
        if let context = UIGraphicsGetCurrentContext() {
            let fillColor = self.fillColor()
            context.setStrokeColor(UIColor.black.cgColor)
            context.setLineWidth(BallView.kBallStrokeWidth)
            context.setFillColor(fillColor.cgColor)
            let ballRect = rect.insetBy(dx: BallView.kBallStrokeWidth/2.0, dy: BallView.kBallStrokeWidth/2.0) // stroke 'straddles' the path
            context.strokeEllipse(in: ballRect)
            context.fillEllipse(in: ballRect)
            
        }
    }

}
