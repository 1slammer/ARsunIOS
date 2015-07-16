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
    var oldHeading = 0.0
    var attitude:CMAttitude!
    var rm:CMRotationMatrix!
    var heading:Double!
    var hasbeen:Bool!
    var points:[Double]!
    var path:UIBezierPath!
    var pangle2 = 0.0
    private let image = UIImage(named : "moon_image")!
    func update() -> Void {
        var x = accel.x
        //println(x)
        var y = accel.y
        var z = accel.z

        var rangle = atan2(x, y);
        var pangle = atan2(y, z)

        var diff1 = heading - oldHeading
        var diff2 = pangle - pangle2
        if diff1 > 1.0 || diff2 > 1.0 {
        rangle = rangle*180/M_PI
        pangle = pangle*180/M_PI
        //pangle = pangle - 180
        if(rangle < 0){
            rangle = rangle + 360
        }
        
        pangle = pangle + 90
        if(pangle < 0){
            pangle = pangle + 360
        }
        if pangle > 180 {
            pangle = pangle - 360
        }
            if abs(heading - oldHeading) > 5.0 {
                if pangle > 44.0 {
                heading = (heading + 180) % 360
                
                }
            
            }
        
        oldHeading = heading
        pangle2 = pangle
        if g.ready {
            points = g.points(pangle*M_PI/180, azimuth: heading*M_PI/180, roll: rangle*M_PI/180)
            // Do the view updating/redrawing on the main thread so it is smoother
            //hor = g.horizon(0.0, width:  Double(self.frame.width), pitch: pangle*M_PI/180, azimuth: heading, roll: rangle)
            dispatch_async(dispatch_get_main_queue(), { self.setNeedsDisplayInRect(self.frame)});
    
        }
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
        var color:UIColor = UIColor.lightGrayColor()
        color.set()
        if points != nil{
            path = UIBezierPath()
            path.lineWidth = 5.0
            path.moveToPoint(CGPoint(x: points[0], y:points[1]))
            for var zp = 2; zp < points.count - 2; zp = zp + 2 {
                path.addLineToPoint(CGPoint(x: points[zp], y: points[zp + 1]))
                
            }
            path.closePath()
            
         path.stroke()

        }

    }
}

