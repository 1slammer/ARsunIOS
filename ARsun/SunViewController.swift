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
    //Member variables
    private let fps24 = 1.0/24.0;
    private let fps30 = 1.0/30.0;
    private let fps60 = 1.0/60.0;
    let sunView = SunView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height - 60))
    private let hz1 = 1.0;
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
    private let moon_button_background = UIImage(named : "moon_button_image") as UIImage?
    private let sun_button_background = UIImage(named : "sun_button_image") as UIImage?
    

    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Set the update interval for the sensors
        motionManager.deviceMotionUpdateInterval = fps24

        captureSession.sessionPreset = AVCaptureSessionPresetHigh
        //This makes the user authorize constant access to their location
        //They will recieve an alert asking them to authorize.
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        //Can set a filter on how often the updates happen
        locationManager.headingFilter = kCLHeadingFilterNone
        //Set the device orientation for purposes of heading updates
        locationManager.headingOrientation = CLDeviceOrientation.LandscapeRight
        //Start updating the location. The delegate is set to self above so that this class
        // must implement the required callback methods and will recieve callbacks(i.e. didUpdateLocation)
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

        //Start motion updates to get acceleration data
        motionManager.startDeviceMotionUpdatesUsingReferenceFrame(CMAttitudeReferenceFrame.XArbitraryZVertical, toQueue:queue, withHandler: {
            (motionData: CMDeviceMotion!, error: NSError!) -> Void in
            //Give the sunView a pointer to acceleration matrix
            self.sunView.accel = motionData.gravity
            //Get a pointer to the graph in sunView
            self.g = self.sunView.g
            // We want to do most of the cpu bound data processing on the background thread so
            // we don't keep the view from redrawing.
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                self.sunView.update()
            })
        })
    }
    //Delegate callback method for heading updates
    func locationManager(manager: CLLocationManager!, didUpdateHeading newHeading: CLHeading!) {
        let h2 = newHeading.trueHeading // will be -1 if we have no location info
        //Correct heading to terms we need
        var heading = (h2 + 90) % 360
        // Give sunVIew a reference to heading
        sunView.heading = heading
        }
    //Delegate callback method for location updates
     func locationManager(manager: CLLocationManager!,
        didUpdateLocations locations: [AnyObject]!) {
            // Just want the one location check, so get it and turn the updates off
            if (!hasUpdated){
                hasUpdated = true
                location = locations.last as! CLLocation
                
            } else {
                locationManager.stopUpdatingLocation()
            }
            
    }
    // Delegate error handler
    func locationManager(manager: CLLocationManager!,
        didFailWithError error: NSError!)
    {
        println("Error getting location.")
        // Set up and present an alert if location updates are not turned on
        let settingsAction: UIAlertAction = UIAlertAction(title: "Go to Settings", style: .Cancel) { action -> Void in
            //Just dismiss the action sheet
            var appSettings = NSURL(string: UIApplicationOpenSettingsURLString)
            UIApplication.sharedApplication().openURL(appSettings!)
        }
        let alert = UIAlertController(title: "Alert", message: "You must have location updates enabled to use this App.", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(settingsAction)
        UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(alert, animated: true, completion: nil)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // Start capture session and instantiate buttons, add the action methods to them and place them on view.
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
        moonButton = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
        moonButton.frame = CGRectMake(180, 475, 100, 75)
        moonButton.layer.borderColor=UIColor.darkGrayColor().CGColor
        moonButton.setImage(moon_button_background, forState: .Normal)
        moonButton.layer.borderWidth=2.0
        moonButton.setTitle("Moon Button", forState: UIControlState.Normal)
        moonButton.addTarget(self, action: "moonButtonAction:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(moonButton)
        sunButton = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
        sunButton.frame = CGRectMake(35, 475, 100, 75)
        sunButton.layer.borderColor=UIColor.orangeColor().CGColor
        sunButton.setImage(sun_button_background, forState: .Normal)
        sunButton.layer.borderWidth=1.5
        sunButton.setTitle("Sun Button", forState: UIControlState.Normal)
        sunButton.addTarget(self, action: "sunButtonAction:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(sunButton)
        self.view.addSubview(sunView)
        sunView.backgroundColor = UIColor.clearColor()
        self.view.bringSubviewToFront(sunView)        
        
    }
    //Moon Button action method, called when moon button pressed.
    func moonButtonAction(sender:UIButton!)
    {
        dataGetter = NavalDataGetter(bodyIn: "Moon", location: location)
        //wait until data reader is finished, then set the variables for the graph
        while !dataGetter.isFinished {
            sleep(1)
        }
        g.setMap(dataGetter.myVals)
        g.updateCoordinates(dataGetter.orderedVals)
        g.crPoints = dataGetter.currentPoints
    }
    // SunButton action method, called when the sun button is pressed.
    func sunButtonAction(sender:UIButton!)
    {
        dataGetter = NavalDataGetter(bodyIn: "Sun", location: location)
        //wait until data reader is finished, then set the variables for the graph
        while !dataGetter.isFinished {
            sleep(1)
        }
        g.setMap(dataGetter.myVals);
        g.updateCoordinates(dataGetter.orderedVals)

    }
    




}

