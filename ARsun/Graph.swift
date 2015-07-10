//
//  Graph.swift
//  ARsun
//
//  Created by Jeffrey Nolen on 7/2/15.
//  Copyright (c) 2015 Jeffrey Nolen. All rights reserved.
//

import Foundation



extension Double {
    var degreesToRadians : Double {
        return self * Double(M_PI) / 180.0
    }
}




class Graph : NSObject {
    
    var scrH: Int = 0
    var scr_w: Int = 0
    var cam_w:Double = 0
    var cam_h:Double = 0
    var pdh: Double = 0
    var pdw: Double = 0
    var time: String!
    var centerW:Int = 0
    var centerH:Int = 0
    var myMap: [String: [Double]]!
    var curAz:Double! = 0
    var curAlt:Double! = 0
    var ready = false
    var containsT = false
    var spCoor:[[Double]]!
    
    init(degW:Double, degH:Double, screenHor:Int, screenVert:Int){
        cam_h = degH.degreesToRadians
        cam_w = degW.degreesToRadians
        scrH = screenVert
        scr_w = screenHor
        centerH = scrH/2
        centerW = scr_w/2
        pdh = Double(Double(scrH)/cam_h)
        pdw = Double(Double(scr_w)/cam_w)
        let formatter = NSDateFormatter()
        let usDateFormat = NSDateFormatter.dateFormatFromTemplate("yyyy/MM/dd HH:mm:ss", options: 0, locale: NSLocale(localeIdentifier: "en-US"))
        formatter.dateFormat = usDateFormat
        var myDate = formatter.stringFromDate(NSDate())
        var range = Range(start: advance(myDate.startIndex, 11), end: advance(myDate.startIndex, 17))
        time = myDate.substringWithRange(range)

        
    }
    
    func setMap(mapIn: [String: [Double]]!) {
        myMap = mapIn
        if let a = myMap[time] {
            containsT = true
        }
        else {
            containsT = false
        }
    }
    
    func upDateCoordinates(coorIn: [[Double]]!){
        spCoor = coorIn
        for (var i = 0; i < spCoor.count; i++){
            spCoor[i][0] = spCoor[i][0].degreesToRadians
            spCoor[i][1] = spCoor[i][1].degreesToRadians
        }
        ready = true
    }
    
    func normalize(numIn:Double) -> Double {
        return numIn - floor(numIn/360)*360
    }
    
    func plotSun(pitch:Double, azimuth:Double, roll:Double) -> [Double] {
        
        if let adj:[Double]! = myMap[time] { // adj is Optional<String[]>
            if let adj2 = adj {  // adj2 is String[]
                curAlt = adj2[0] as Double
                println(curAlt)
            }
        }
        if let adj3:[Double]! = myMap[time] { // adj is Optional<String[]>
            if let adj4 = adj3 {  // adj2 is String[]
                curAz = adj4[0] as Double
                println(curAz)
                }
        }
            var temp0: Double
            var temp1:Double
            
            var azimuth1 = normalize((azimuth-M_PI).degreesToRadians).degreesToRadians
            temp0 = curAlt.degreesToRadians - pitch
            temp1 = curAz.degreesToRadians - azimuth1
            var output = [Double](count: 3, repeatedValue: 0.0)
            output[0] = temp0 * pdh
            output[1] = temp1 * pdw
            output[0] = Double(centerH) - output[0]
            output[1] += Double(centerW)
            if(output[0] < 0.0) {output[0]=0}
            else if(output[0] > Double(scrH)) {output[0] = Double(scrH)}
            if(output[1] < 0) {output[1]=0}
            else if(output[1] > Double(scr_w)) {output[1] = Double(scr_w)}
            return output
    }


    func containsTime() -> Bool {
        return containsT
    }
    func updateCoordinates(newCoor:[[Double]]) {
        spCoor = newCoor
        ready = true
    }
    
    func isReady() -> Bool {
        return ready
    }
    func roll(x:Double, y:Double, roll:Double) -> [Double] {
        let roll2 = normalize(roll)
        var tmp:[Double] = [x, y]
        tmp[0] = sin(roll) * tmp[1] + cos(roll) * tmp[0]
        tmp[1] = cos(roll) * tmp[1] - sin(roll) * tmp[0]
        return tmp
    }
    
    func horizon(angle:Double, width:Double, pitch:Double, azimuth:Double, roll:Double) -> [Float] {
        var output:[Float] = [0.0, 0.0, 0.0, 0.0]
        var center:Double = angle.degreesToRadians - pitch
        center = Double(centerH) - center
        output[0] = Float(centerW) - Float(width/2.0)
        output[1] = Float(center)
        output[2] = Float(centerW) - Float(width/2.0)
        output[3] = Float(center)
        return output
    }
    
    func points(pitch:Double, azimuth:Double, roll:Double) -> [Double] {
        var output:[Double]!
        if(ready){
            //println(azimuth)
            var azimuth1 = normalize((azimuth - M_PI) * (180/M_PI)).degreesToRadians
            //println(azimuth1)
            
            output = [Double](count:(spCoor.count*2), repeatedValue: 0.0)
            var tmp = Array(count:spCoor.count, repeatedValue:[Double](count:2, repeatedValue:0.0))
            
            for var i = 0; i < spCoor.count; i++ {
                //degrees from phone pointing vector
                
                tmp[i][0] = (spCoor[i][0]) - pitch
                tmp[i][1] = (spCoor[i][1]) - azimuth1
                //pixels per degree from pointing vector
                tmp[i][0] = tmp[i][0] * pdh;
                //println(spCoor[i][0]*M_PI/180)
                tmp[i][1] = tmp[i][1] * pdw;
                //roll correction using expanded rotation matrix
                //roll +=
                //tmp[i][0] = Math.sin(roll) * tmp[i][1] + Math.cos(roll) * tmp[i][0]; //vertical component
                //tmp[i][1] = Math.cos(roll) * tmp[i][1] - Math.sin(roll) * tmp[i][0]; //horixontal component
                //correct coordinates to screen coordinates (0,0) top left and Y axis is inverted
                tmp[i][0] = Double(centerH) - tmp[i][0]
                tmp[i][1] += Double(centerW)
                
                i++;
            }
            for (var i = 0; i < tmp.count; i++) {
                //if (i != tmp.length-1) {
                output[i*2] = round(tmp[i][1])
                output[i*2 + 1] = round(tmp[i][0])
                //output[i * 4 + 2] = round(tmp[i+1][1])
                //output[i * 4 + 3] = round(tmp[i+1][0])
                }

        }
        return output
        
    }
    func getMap() -> [String: [Double]]! {
        return myMap
    }

    }



