//
//  sensingViewController.swift
//  20170808hack-ios
//
//  Created by Daichi Shibata on 2017/08/08.
//  Copyright © 2017 rungineer. All rights reserved.
//


import UIKit

class sensingViewController: UIViewController{
    

    var myData :UILabel!
    var yourData :UILabel!
    
    var myImage :UIImageView!
    var yourImage :UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let frame = CGRect(x: 5, y: 30, width: self.view.frame.width - 10, height: self.view.frame.height/2 - 30)
        let rangedAxisExample = RangedAxisExample(frame: frame)
        rangedAxisExample.roundCorners(corners: [.topLeft, .topRight, .bottomLeft, .bottomRight], radius: 10)
        self.view.addSubview(rangedAxisExample)
        
        // 画像
        let image1:UIImage = UIImage(named:"1.png")!//絶好調
        let image2:UIImage = UIImage(named:"2.png")!//ニコニコ
        //        let image3:UIImage = UIImage(named:"3.png")!//ビミョー
        //mydata..使う人の情報
//        var text1 :UILabel!
//        text1 = UILabel(frame: CGRect(x: self.view.frame.width/2-150, y: self.view.frame.height/2 + 30, width: self.view.bounds.width, height: 30))
//        text1.text = "I ♡"
//        text1.font = UIFont(name: "HiraKakuProN-W3", size: 20)
//        text1.textAlignment = NSTextAlignment.left
//        text1.textColor = UIColor.black
//        self.view.addSubview(text1!)

//        myImage = UIImageView(frame: CGRect(x: self.view.frame.width/2-145, y: self.view.frame.height/2 + 100, width: 100, height: 100))
//        myImage.image = image1
//        self.view.addSubview(myImage!)
//
//        myData = UILabel(frame: CGRect(x: self.view.frame.width/2-120, y: self.view.frame.height/2 + 220, width: self.view.bounds.width, height: 30))
//        myData.text = "60T"
//        myData.font = UIFont(name: "HiraKakuProN-W3", size: 28)
//        myData.textAlignment = NSTextAlignment.left
//        myData.textColor = UIColor.black
//        self.view.addSubview(myData!)

        //yourdata..お相手の情報
        var text2 :UILabel!
        text2 = UILabel(frame: CGRect(x: self.view.frame.width/2-50, y: self.view.frame.height/2 + 30, width: self.view.bounds.width, height: 30))
        text2.text = "Partner"
        text2.font = UIFont(name: "HiraKakuProN-W3", size: 20)
        text2.textAlignment = NSTextAlignment.left
        text2.textColor = UIColor.black
        self.view.addSubview(text2!)

        yourImage = UIImageView(frame: CGRect(x: self.view.frame.width/2, y: self.view.frame.height/2 + 100, width: 100, height: 100))
        yourImage.image = image2
        self.view.addSubview(yourImage!)

        yourData = UILabel(frame: CGRect(x: self.view.frame.width/2+30, y: self.view.frame.height/2 + 220, width: self.view.bounds.width, height: 30))
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

