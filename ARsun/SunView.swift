//
//  SunView.swift
//  ARsun
//
//  Created by Jeffrey Nolen on 7/3/15.
//  Copyright (c) 2015 Jeffrey Nolen. All rights reserved.
//

import UIKit
import CoreMotion

class SunView: UIView {
    var accel = CMAcceleration(x: 0, y: 0, z: 0)
    var pitch:Double!
    var roll:Double!
    var g:Graph!
    var m = 60
    var hor: [Float]!
    var heading:Double!
    var hasbeen:Bool!
    var points:[Double]!
    private let image = UIImage(named : "moon_image")!
    func update() -> Void {
        //println("(X,Y)\t(\(accel.x),\(accel.y)")
        var x = accel.x
        //println(x)
        var y = accel.y
        var z = accel.z
        var angle = atan2(x, y);
        var pangle = atan2(y, z)
        angle = angle*180/M_PI
        angle = angle - 180
        if(angle < 0){
            angle = angle + 360
        }
        pangle = pangle*180/M_PI
        pangle = pangle + 90
        if(pangle < 0){
            pangle = pangle + 360
        }
        
        roll = accel.x * M_PI
        pitch  = accel.y * M_PI
        if g.ready {
            points = g.points(pitch, azimuth: heading, roll: roll)
            //for cp in points {
            //    println(cp)
            //}
//            path.moveToPoint(CGPoint(x:50, y:50))
//            path.addLineToPoint(CGPoint(x:z++, y:m++))
//            println("points:\(z), \(m)" )
//
//            path.moveToPoint(CGPoint(x: points[0], y:points[1]))
//                            for var zp = 2; zp < points.count; zp = zp + 2 {
//                                path.addLineToPoint(CGPoint(x: points[zp], y: points[zp + 1]))
//                            }
            hor = g.horizon(0.0, width:  Double(self.frame.width), pitch: pangle*M_PI/180, azimuth: heading, roll: roll)
            println("called")
            
            dispatch_async(dispatch_get_main_queue(), { self.setNeedsDisplayInRect(self.frame)});
    
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() -> Void {
        g = Graph( degW: 32.13, degH: 53.13, screenHor: Int(self.bounds.width),screenVert: Int(self.bounds.height))
        hasbeen = true
    }
    
    override func drawRect(rect: CGRect) {
        // Drawing code
        var path = UIBezierPath()
        var color:UIColor = UIColor.lightGrayColor()
        color.set()
//        path.moveToPoint(CGPoint(x:50, y:50))
//        path.addLineToPoint(CGPoint(x:++z, y:++m))
//        if (points != nil){
//        path.moveToPoint(CGPoint(x: points[0], y:points[1]))
//        for var zp = 2; zp < points.count; zp = zp + 2 {
//            path.addLineToPoint(CGPoint(x: points[zp], y: points[zp + 1]))
////            path.moveToPoint(CGPoint(x:points[zp],y: points[zp+1]))
//            println("(\(points[zp]),\(points[zp+1]))")
//        }
        //}
        if hor != nil{
            println("called2")
            path.lineWidth = 5.0
        path.moveToPoint(CGPoint(x: Double(hor[0]), y: Double(hor[1])))
            path.addLineToPoint(CGPoint(x: Double(hor[2]), y: Double(hor[3])))
         path.stroke()
         var currentPoint = CGPoint(x: Double(self.frame.width/2 - 30), y: Double(hor[1] - 40))
            image.drawAtPoint(currentPoint)
        }

    }
}

