//
//  ViewController.swift
//  ARsun
//
//  Created by Jeffrey Nolen on 6/30/15.
//  Copyright (c) 2015 Jeffrey Nolen. All rights reserved.
//

import UIKit
import AVFoundation
import CoreLocation
import CoreMotion

class ViewController: UIViewController , CLLocationManagerDelegate{
    
    let captureSession = AVCaptureSession()
    let f = Test_View(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height - 60))
    var moonButton: UIButton!
    var sunButton: UIButton!
    let motionManager = CMMotionManager()
    private let queue = NSOperationQueue()
   
    // If we find a device we'll store it here for later use
    var captureDevice : AVCaptureDevice?
    var locationManager: CLLocationManager! = CLLocationManager()
    var hasUpdated = false
    var location: CLLocation!
    var dataGetter:NavalDataGetter!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        // Do any additional setup after loading the view, typically from a nib.
        captureSession.sessionPreset = AVCaptureSessionPresetHigh
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.headingFilter = kCLHeadingFilterNone
        locationManager.startUpdatingLocation()
        if CLLocationManager.headingAvailable() {
            locationManager.startUpdatingHeading() }
        
        let devices = AVCaptureDevice.devices()
        // Loop through all the capture devices on this phone
        for device in devices {
            // Make sure this particular device supports video
            if (device.hasMediaType(AVMediaTypeVideo)) {
                // Finally check the position and confirm we've got the back camera
                if(device.position == AVCaptureDevicePosition.Back) {
                    captureDevice = device as? AVCaptureDevice
                }
            }
        }
        if captureDevice != nil {
            beginSession()
        }
//        if motionManager.accelerometerAvailable {
//            motionManager.accelerometerUpdateInterval = 0.01
//            motionManager.startAccelerometerUpdatesToQueue(queue) {
//                [weak self] (data: CMAccelerometerData!, error: NSError!) in
//                
//                let rotation = atan2(data.acceleration.x, data.acceleration.y) - M_PI
//                self?.f.transform = CGAffineTransformMakeRotation(CGFloat(rotation))
//            }
//        }
        
        if motionManager.deviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 0.08
            motionManager.startDeviceMotionUpdatesToQueue(queue) {
                [weak self] (data: CMDeviceMotion!, error: NSError!) in
                self!.f.accel = data.gravity
                
                dispatch_async(dispatch_get_main_queue(), { self!.f.update()})
                
                
            }
        }
    }
    func locationManagerShouldDisplayHeadingCalibration(manager: CLLocationManager!) -> Bool {
        return true
    }
    func locationManager(manager: CLLocationManager!, didUpdateHeading newHeading: CLHeading!) {
        let h2 = newHeading.trueHeading // will be -1 if we have no location info
        var heading = h2*M_PI/180
        f.azimuth = heading
    }
    func locationManager(manager: CLLocationManager!,
        didUpdateLocations locations: [AnyObject]!) {
    if (!hasUpdated){
        hasUpdated = true
        location = locations.last as! CLLocation
        
    } else {
        locationManager.stopUpdatingLocation()
            }

    }
    
    func locationManager(manager: CLLocationManager!,
        didFailWithError error: NSError!)
    {
        println("Error getting location.")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func beginSession() {
        var err : NSError? = nil
        captureSession.addInput(AVCaptureDeviceInput(device: captureDevice, error: &err))
        
        if err != nil {
            println("error: \(err?.localizedDescription)")
        }
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.view.layer.addSublayer(previewLayer)
        previewLayer?.frame = self.view.layer.frame
        captureSession.startRunning()
        moonButton = UIButton.buttonWithType(UIButtonType.System) as! UIButton
        moonButton.frame = CGRectMake(180, 500, 100, 50)
        moonButton.backgroundColor = UIColor.blueColor()
        moonButton.setTitle("Moon Button", forState: UIControlState.Normal)
        moonButton.addTarget(self, action: "moonButtonAction:", forControlEvents: UIControlEvents.TouchUpInside)
        
        self.view.addSubview(moonButton)
        sunButton = UIButton.buttonWithType(UIButtonType.System) as! UIButton
        sunButton.frame = CGRectMake(35, 500, 100, 50)
        sunButton.backgroundColor = UIColor.blueColor()
        sunButton.setTitle("Sun Button", forState: UIControlState.Normal)
        sunButton.addTarget(self, action: "sunButtonAction:", forControlEvents: UIControlEvents.TouchUpInside)
        
        self.view.addSubview(sunButton)
        self.view.addSubview(f)
        f.backgroundColor = UIColor.clearColor()

    }
    
    
    func moonButtonAction(sender:UIButton!)
    {
        dataGetter = NavalDataGetter(bodyIn: "Moon", location: location)
        while !dataGetter.isFinished {
            sleep(1)
                }
//        for val in self.dataGetter.myVals{
//            println(val)
//        }
        f.g.setMap(dataGetter.myVals);
        f.g.updateCoordinates(dataGetter.orderedVals)
    }
    
    func sunButtonAction(sender:UIButton!)
    {
        dataGetter = NavalDataGetter(bodyIn: "Sun", location: location)
    }
    
    class Test_View: UIView {
        var accel = CMAcceleration(x:0,y:0,z:0)
        var path = UIBezierPath()
        var hasCalled = false
        var paramsAreSet = false
        var azimuth:Double!
        var pitch:Double!
        var roll:Double!
        var g:Graph!
        var z = 0
        var m = 0
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            g = Graph( degW: 32.13, degH: 53.13, screenHor: Int(self.bounds.width),screenVert: Int(self.bounds.height));
        }
        
        required init(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
        }
        override func drawRect(rect: CGRect) {
            super.drawRect(rect)
            var color:UIColor = UIColor.blueColor()
            color.set()
            path.stroke()
                
            //NSLog("points:\(points[0]), \(points[1])" )
        }
        
        func setParams(azIn:Double, pitchIn:Double, rollIn:Double){
            azimuth = azIn
            roll = rollIn
            pitch = pitchIn
            paramsAreSet = true
            
        }
        func update() {
            roll = accel.x * M_PI
            pitch  = accel.y * M_PI
            println("called")
            if g.ready {
                var points = g.points(pitch, azimuth: azimuth, roll: roll)
                for cp in points {
                    println(cp)
                }
                path.moveToPoint(CGPoint(x:50, y:50))
                path.addLineToPoint(CGPoint(x:z++, y:m++))
                //path.moveToPoint(CGPoint(x: points[0], y:points[1]))
//                for var zp = 2; zp < points.count; zp = zp + 2 {
//                    path.addLineToPoint(CGPoint(x: points[zp], y: points[zp + 1]))
//                }

                self.setNeedsDisplay()
               
        
        }
        
        }
    
    
    }}



