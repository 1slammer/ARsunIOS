//
//  NavalDataGetter.swift
//  ARsun
//
//  Created by Jeffrey Nolen on 6/30/15.
//  Copyright (c) 2015 Jeffrey Nolen. All rights reserved.
//

import Foundation
import CoreLocation

class NavalDataGetter : NSObject {
    
    var longVals = [Int]()
    var latVals = [Int]()
    var myVals = [String: [Double]]()
    var orderedVals = Array<Array<Double>>()//[[Double]]()
    var flag4 = false
    var url:String!
    

    init(bodyIn:String, location:CLLocation) {
        super.init()
        let urlStart = "http://aa.usno.navy.mil/cgi-bin/aa_altazw.pl?form=2&body="
        let lattitude = " "
        let longitude = " "
        var body,tz,mid1,mid2,firstTime,lastTime,tz_sign,lat_sign,lon_sign:String
        if (bodyIn == "Moon") {body = "11"}
        else if (bodyIn == "Sun") {body = "10"}
        else {body = "10"}
        if (location.coordinate.latitude  < 0){
            lat_sign = "-1"
        } else {
            lat_sign = "1"
        }
        if(location.coordinate.longitude > 0){
            lon_sign = "1"
        } else {
            lon_sign = "-1"
        }
        let formatter = NSDateFormatter()
        
        var lonData = convertDecToDeg(location.coordinate.longitude)
        var latData = convertDecToDeg(location.coordinate.latitude)
        let usDateFormat = NSDateFormatter.dateFormatFromTemplate("yyyy/MM/dd HH:mm:ss", options: 0, locale: NSLocale(localeIdentifier: "en-US"))
        formatter.dateFormat = usDateFormat
        var myDate = formatter.stringFromDate(NSDate())
        var offSet = NSTimeZone.localTimeZone().secondsFromGMT/3600
        if (offSet >= 0) {tz_sign = "1"}
        else if (offSet < 0) {tz_sign = "-1"}
        else {tz_sign = "0"}
        tz = String(abs(offSet))
        var range = Range(start: advance(myDate.startIndex, 6), end: advance(myDate.startIndex, 10))
        let yearString = myDate.substringWithRange(range)
        range = Range(start: myDate.startIndex, end: advance(myDate.startIndex, 2))
        var monthString = myDate.substringWithRange(range)
        range = Range(start: advance(myDate.startIndex, 3), end: advance(myDate.startIndex, 5))
        var dayString = myDate.substringWithRange(range)
        range = Range(start: advance(myDate.startIndex, 11), end: advance(myDate.startIndex, 17))
        let timeString = myDate.substringWithRange(range)
        var monthInt: Int! = monthString.toInt()
        monthInt = monthInt!/1
        monthString = String(monthInt as Int)
        var dayInt: Int! = dayString.toInt()
        dayInt = dayInt!/1
        dayString = String(dayInt as Int)
        url = urlStart + body + "&year=" + yearString + "&month=" + monthString + "&day=" + dayString
        url = url + "&intv_mag=1&place=%28no+name+given%29&lon_sign=" + lon_sign
        url = url + "&lon_deg=" + String(lonData[0]) + "&lon_min=" + String(lonData[1])
        url = url + "&lat_sign=" + lat_sign + "&lat_deg="
        url = url + String(latData[0]) + "&lat_min="
        url = url + String(latData[1]) + "&tz=" + tz + "&tz_sign=" + tz_sign
        
        dispatch_async(dispatch_get_main_queue()) {
            self.startGetting(self.url)
        }
        
        
        }
    
    func convertDecToDeg(numIn:Double) ->[Int] {
    
    var degrees =  Int((numIn))
    var m = (numIn % 1) * 60
    var min = Int((m))
        var x =  [Int]()
    x.append(abs(degrees))
    x.append(abs(min))
    return x;
    
    }
    func startGetting(urlIn:String){
        let session = NSURLSession.sharedSession()
        var localurl = NSURL(string: urlIn)// Creating URL
        var task = session.dataTaskWithURL(localurl!){
            (data, response, error) -> Void in
            
            if error != nil {
                println(error.localizedDescription)
            }
            else {
                var datastring = NSString(data: data, encoding: NSUTF8StringEncoding)
                let scanner = NSScanner(string: datastring as! String)
                scanner.scanLocation = 1200
                let whitespaceAndPunctuationSet = NSMutableCharacterSet.whitespaceAndNewlineCharacterSet()
                var parsedString:NSString?
                var x = 0
                var y = 0
                var key: String!
                var myDubs = [Double]()
                while scanner.scanUpToCharactersFromSet(whitespaceAndPunctuationSet, intoString: &parsedString),
                    let val = parsedString as? String
                {
                    if (val.rangeOfString("<") != nil){
                        break;
                    }
                    if x == 0 {
                        key = val
                        }
                    else if x == 1 {
                        myDubs.append((val as NSString).doubleValue)
                        self.orderedVals.append(Array(count: 2, repeatedValue: 1))
                        self.orderedVals[y][0] = (val as NSString).doubleValue
                    }
                    else if x == 2 {
                        myDubs.append((val as NSString).doubleValue)
                        self.orderedVals[y][1] = (val as NSString).doubleValue
                        x = -1
                        self.myVals[key] = myDubs
                        myDubs = [Double]()
                        y++
                    }
                    x++
                    
                    
                }
                
            }
            for number in self.myVals {
                println("helo")
                println("\(number)")
        }
        }
        task.resume()
    }
    
    
    
    
        }
