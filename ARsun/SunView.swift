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
    //Member variables
    var accel = CMAcceleration(x: 0, y: 0, z: 0)
    var pitch:Double!
    var roll:Double!
    var g:Graph!
    var m = 60
    var hor: [Float]!
    var oldHeading = 0.0
    var heading:Double!
    var points:[Double]!
    var bodyLoc:[Double]!
    var path:UIBezierPath!
    var pangle2 = 0.0
    private let moonImage = UIImage(named : "moon_image")!
    private let sunImage = UIImage(named : "sun_image")!

    // Method called anytime the acceleration data gets updated
    func update() -> Void {
        //rangle stands for "roll angle"
        var rangle = atan2(accel.x, accel.y)
        //pangle stands for "pitch angle"
        var pangle = atan2(accel.y, accel.z)
        // Difference between last heading used and new incoming heading
        var diff1 = abs(heading - oldHeading)
        //Difference between last roll angle and the incoming roll angle
        var diff2 = abs(pangle - pangle2)
        // Sort of make-shift low-pass filter.
        if diff1 > 1.0 || diff2 > 1.0 {
        
        // Make various correction to get values into correct coordinates
        if(rangle < 0){
            rangle = rangle + 2.0*M_PI
        }
        pangle = pangle + M_PI/2.0
        if(pangle < 0){
            pangle = pangle + 2.0*M_PI
        }
        if pangle > M_PI {
            pangle = pangle - 2*M_PI
        }
            // Attempt to correct for pitch angle flipping over when phone is inclined past 45 degrees
            if abs(heading - oldHeading) > 5.0 {
                if pangle > 44.0 {
                heading = (heading + 180) % 360
                
                }
            
            }
        // Save old heading for use with low-pass filter
        oldHeading = heading
        pangle2 = pangle*180/M_PI
        if g.ready {
            points = g.points(pangle*M_PI/180, azimuth: heading*M_PI/180, roll: rangle*M_PI/180)
            bodyLoc = g.plotSun(pangle*M_PI/180, azimuth: heading*M_PI/180, roll: rangle*M_PI/180)
            // Do the view updating/redrawing on the main thread so it is smoother
            //hor = g.horizon(0.0, width:  Double(self.frame.width), pitch: pangle*M_PI/180, azimuth: heading, roll: rangle)
            dispatch_async(dispatch_get_main_queue(), { self.setNeedsDisplayInRect(self.frame)});
    
        }
        }
    }
    // Initializer which calls common initializer
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
    }
    
    override func drawRect(rect: CGRect) {
        // Drawing code
        var color:UIColor = UIColor.lightGrayColor()
        color.set()
        if points != nil{
            // If the points are ready, build the path for them
            path = UIBezierPath()
            path.lineWidth = 5.0
            path.moveToPoint(CGPoint(x: points[0], y:points[1]))
            for var zp = 2; zp < points.count - 2; zp = zp + 2 {
                path.addLineToPoint(CGPoint(x: points[zp], y: points[zp + 1]))
                
            }
            // Logic for drawing the moon or sun image where it is currently
            if g.bPoints[0] != -1.0 {
               if g.bPoints[1] != -1.0 {
            var currentPoint = CGPoint(x: g.bPoints[0], y: g.bPoints[1])
            //var currentPoint = CGPoint(x: bodyLoc[0], y: bodyLoc[1])
                if g.isMoon {
                    moonImage.drawAtPoint(currentPoint)
                    }
                else if g.isSun {
                    sunImage.drawAtPoint(currentPoint)
                    }
                }
            }
        // Draw the path on the view.
         path.stroke()

        }

    }
}

