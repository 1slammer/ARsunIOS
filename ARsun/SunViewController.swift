//
//  SunViewController.swift
//  ARsun
//
//  Created by Jeffrey Nolen on 7/5/15.
//  Copyright (c) 2015 Jeffrey Nolen. All rights reserved.
//

import UIKit
import AVFoundation
import CoreLocation
import CoreMotion

class SunViewController: UIViewController, CLLocationManagerDelegate {
    private let fps24 = 1.0/24.0;
    private let fps30 = 1.0/30.0;
    private let fps60 = 1.0/60.0;
    let sunView = SunView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height - 60))
    private let hz1 = 1.0;
    private var updateInterval: Double!
    private let motionManager = CMMotionManager()
    private let queue = NSOperationQueue()
    let captureSession = AVCaptureSession()
    var moonButton: UIButton!
    var sunButton: UIButton!
    // If we find a device we'll store it here for later use
    var captureDevice : AVCaptureDevice?
    var locationManager: CLLocationManager! = CLLocationManager()
    var hasUpdated = false
    var location: CLLocation!
    var dataGetter:NavalDataGetter!
    var g:Graph!
    

    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateInterval = fps24
        //self.sunView = self.view as! SunView
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

        
        motionManager.deviceMotionUpdateInterval = updateInterval
        motionManager.startDeviceMotionUpdatesToQueue(queue, withHandler: {
            (motionData: CMDeviceMotion!, error: NSError!) -> Void in
            self.sunView.accel = motionData.gravity
            self.g = self.sunView.g
            dispatch_async(dispatch_get_main_queue(), {
                self.sunView.update()
            })
        })
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateHeading newHeading: CLHeading!) {
        let h2 = newHeading.trueHeading // will be -1 if we have no location info
        var heading = h2*M_PI/180
        sunView.heading = heading
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
        self.view.addSubview(sunView)
        sunView.backgroundColor = UIColor.clearColor()
        self.view.bringSubviewToFront(sunView)
        
        
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
        g.setMap(dataGetter.myVals);
        g.updateCoordinates(dataGetter.orderedVals)
    }
    
    func sunButtonAction(sender:UIButton!)
    {
        dataGetter = NavalDataGetter(bodyIn: "Sun", location: location)
        while !dataGetter.isFinished {
            sleep(1)
        }
        //        for val in self.dataGetter.myVals{
        //            println(val)
        //        }
        g.setMap(dataGetter.myVals);
        g.updateCoordinates(dataGetter.orderedVals)

    }
    




}

