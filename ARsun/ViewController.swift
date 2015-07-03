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

class ViewController: UIViewController , CLLocationManagerDelegate{
    
    let captureSession = AVCaptureSession()
    let f = Test_View(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height - 60))
    var g:Graph!

    var moonButton: UIButton!
    var sunButton: UIButton!
   
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
        locationManager.startUpdatingLocation()
        
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
    }
    func locationManager(manager: CLLocationManager!,
        didUpdateLocations locations: [AnyObject]!) {
    if (!hasUpdated){
        hasUpdated = true
        location = locations.last as! CLLocation
        
    } else {
        locationManager.stopUpdatingLocation()
        locationManager = nil
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
        for val in self.dataGetter.orderedVals{
            println(val)
        }
        for var x = 0; x < 16; x++ {
        f.setNeedsDisplay()
        //self.view.setNeedsDisplay()
            sleep(1)
        NSRunLoop.currentRunLoop().runMode(NSDefaultRunLoopMode, beforeDate: NSDate())
        }
    }
    
    func sunButtonAction(sender:UIButton!)
    {
        dataGetter = NavalDataGetter(bodyIn: "Sun", location: location)
    }
    
    class Test_View: UIView {
        var hasCalled = false
        var x = 70
        var y = 70
        
        override init(frame: CGRect) {
            super.init(frame: frame)
        }
        
        required init(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
        }
        override func drawRect(rect: CGRect) {
            super.drawRect(rect)
            if hasCalled {
                var path = UIBezierPath()
                path.moveToPoint(CGPoint(x: 50, y:50))
                path.addLineToPoint(CGPoint(x: x, y: y))
                x = x + 20
                y = y + 40
                var color:UIColor = UIColor.blueColor()
                color.set()
                path.stroke()
            } else {
            let h = rect.height
            let w = rect.width
            var color:UIColor = UIColor.blueColor()
            
            var drect = CGRect(x: (w * 0.25),y: (h * 0.25),width: (w * 0.5),height: (h * 0.5))
            var bpath:UIBezierPath = UIBezierPath(rect: drect)
            
            color.set()
            bpath.stroke()
                hasCalled = true
            }
            
            NSLog("drawRect has updated the view")
            
        }
        
        
    }
    
    
}



