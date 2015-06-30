//
//  DrawingView.swift
//  ARsun
//
//  Created by Jeffrey Nolen on 6/30/15.
//  Copyright (c) 2015 Jeffrey Nolen. All rights reserved.
//

import UIKit


class DrawingView: UIView {




override func drawRect(rect: CGRect) {
    var path = UIBezierPath(ovalInRect: rect)
    UIColor.greenColor().setFill()
    path.fill()
}

}


