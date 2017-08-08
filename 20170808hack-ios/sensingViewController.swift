//
//  sensingViewController.swift
//  20170808hack-ios
//
//  Created by Daichi Shibata on 2017/08/08.
//  Copyright © 2017 rungineer. All rights reserved.
//


import UIKit

class sensingViewController: UIViewController{
    
    var text1 :UILabel!

    var myData :UILabel!
    var yourData :UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let frame = CGRect(x: 5, y: 30, width: self.view.frame.width - 10, height: self.view.frame.height/2 - 30)
        let rangedAxisExample = RangedAxisExample(frame: frame)
        rangedAxisExample.roundCorners(corners: [.topLeft, .topRight, .bottomLeft, .bottomRight], radius: 10)
        self.view.addSubview(rangedAxisExample)
        
        //text1
        text1 = UILabel(frame: CGRect(x: 15, y: self.view.frame.height/2 + 20, width: self.view.bounds.width, height: 30))
        text1.text = "今の状態"
        text1.font = UIFont(name: "HiraKakuProN-W3", size: 20)
        text1.textAlignment = NSTextAlignment.left
        text1.textColor = UIColor.black
        self.view.addSubview(text1!)
        
        
        
        //mydata..使う人の情報
        myData = UILabel(frame: CGRect(x: self.view.frame.width/2-120, y: self.view.frame.height/2 + 150, width: self.view.bounds.width, height: 30))
        myData.text = "60T"
        myData.font = UIFont(name: "HiraKakuProN-W3", size: 28)
        myData.textAlignment = NSTextAlignment.left
        myData.textColor = UIColor.black
        self.view.addSubview(myData!)
        
        //yourdata..お相手の情報
        yourData = UILabel(frame: CGRect(x: self.view.frame.width/2+80, y: self.view.frame.height/2 + 150, width: self.view.bounds.width, height: 30))
        yourData.text = "80T"
        yourData.font = UIFont(name: "HiraKakuProN-W3", size: 28)
        yourData.textAlignment = NSTextAlignment.left
        yourData.textColor = UIColor.black
        self.view.addSubview(yourData!)
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

