//
//  FFScanLineView.swift
//  FFScanDemo
//
//  Created by fingle on 2020/4/30.
//  Copyright © 2020 fingle0618. All rights reserved.
//

import UIKit

class FFScanView: UIView {
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        
        let hSpace: CGFloat = 64
        let scanW = frame.size.width - hSpace * 2
        let scanMinX = hSpace
        let scanMaxX = hSpace + scanW
        let scanMinY = center.y - scanW / 2
        let scanMaxY = center.y + scanW / 2
        
        
        let context = UIGraphicsGetCurrentContext()
        context?.setLineCap(.round)
        context?.setLineJoin(.round)
        context?.setLineWidth(4.0)
        context?.setStrokeColor(UIColor.orange.cgColor)
        context?.beginPath()
        //left top
        context?.move(to: CGPoint(x: scanMinX + 10, y: scanMinY))
        context?.addLine(to: CGPoint(x: scanMinX, y: scanMinY))
        context?.addLine(to: CGPoint(x: scanMinX, y: scanMinY + 10))
        
        //right top
        
        context?.move(to: CGPoint(x: scanMaxX - 10, y: scanMinY))
        context?.addLine(to: CGPoint(x: scanMaxX, y: scanMinY))
        context?.addLine(to: CGPoint(x: scanMaxX, y: scanMinY + 10))
        
        
        //left bottom
        context?.move(to: CGPoint(x: scanMinX, y: scanMaxY - 10))
        context?.addLine(to: CGPoint(x: scanMinX, y: scanMaxY))
        context?.addLine(to: CGPoint(x: scanMinX + 10, y: scanMaxY))
        
        //right bottom
        
        context?.move(to: CGPoint(x: scanMaxX - 10, y: scanMaxY))
        context?.addLine(to: CGPoint(x: scanMaxX, y: scanMaxY))
        context?.addLine(to: CGPoint(x: scanMaxX, y: scanMaxY - 10))
        
        
        context?.strokePath()
     
    }
   
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
        let hSpace: CGFloat = 64
        let scanW = frame.size.width - hSpace * 2
        let scanMinX = hSpace
        let scanMinY = center.y - scanW / 2

        //line
        let layer  = CAGradientLayer()
        let color = UIColor.orange
        layer.colors = [color.withAlphaComponent(0).cgColor,color.withAlphaComponent(0.9).cgColor,color.withAlphaComponent(0).cgColor]
        layer.locations = [0,0.5,1]
        layer.startPoint = CGPoint(x:0.5,y: 0)
        layer.endPoint = CGPoint(x: 0.5,y: 1)
        layer.cornerRadius = 2
        layer.masksToBounds = true
        let frame = CGRect(x: scanMinX + 8, y: scanMinY + 4, width: scanW - 16, height: 4)
        layer.frame = frame
        self.layer.addSublayer(layer)
        
        //animation
        let animation = CABasicAnimation(keyPath: "transform.translation.y")
        animation.fromValue = 0
        animation.toValue = scanW - 8
        animation.repeatCount = Float.greatestFiniteMagnitude
        animation.duration = 2
        animation.isRemovedOnCompletion = false
        animation.fillMode =  CAMediaTimingFillMode.both
        layer.add(animation, forKey: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

}
