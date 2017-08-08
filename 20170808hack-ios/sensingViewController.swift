//
//  sensingViewController.swift
//  20170808hack-ios
//
//  Created by Daichi Shibata on 2017/08/08.
//  Copyright © 2017 rungineer. All rights reserved.
//


import UIKit
import Firebase
import FirebaseDatabase
import Alamofire
import SwiftyJSON

class sensingViewController: UIViewController{
    
    @IBOutlet var pulseLabel: UILabel!
    @IBOutlet weak var partnerImage: UIImageView!
    
    fileprivate let url = "http://192.168.179.7:4035/gotapi/health/heartrate?serviceId=E9%3A72%3AA6%3A7D%3A87%3A3B.e9484eb5107adfef1af6a0dc65c03232.localhost.deviceconnect.org"
    var timer: Timer!
    var databaseRef:DatabaseReference!
    var postArray = [String: Any]()
    
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

        //yourdata..お相手の情報
        var text2 :UILabel!
        text2 = UILabel(frame: CGRect(x: self.view.frame.width/2-40, y: self.view.frame.height/2 + 30, width: self.view.bounds.width, height: 30))
        text2.text = "今の状態"
        text2.font = UIFont(name: "HiraKakuProN-W3", size: 20)
        text2.textAlignment = NSTextAlignment.left
        text2.textColor = UIColor.black
        self.view.addSubview(text2!)

        partnerImage.image = image2
        self.view.addSubview(partnerImage!)

        pulseLabel.text = "80T"
        pulseLabel.font = UIFont(name: "HiraKakuProN-W3", size: 28)
        pulseLabel.textAlignment = NSTextAlignment.left
        pulseLabel.textColor = UIColor.black
        self.view.addSubview(pulseLabel!)
        
        
        //firebase
//        databaseRef = Database.database().reference()
//        //情報を取得したいユーザーの更新を取得する
//        databaseRef.child("user/"+"ユーザー1").observe(.value, with: { snapshot in
//            if let snapshotValue = snapshot.value as? [String:Any],
//                let name = snapshotValue["uid"] as? String,
//                let pulse = snapshotValue["pulse"] as? String {
//                if name == "ユーザー1" {
//                    self.pulseLabel.text = pulse + "T"
//                }
//            }
//        })
//        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateHeartRate), userInfo: nil, repeats: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func updateHeartRate() {
        Alamofire.request(url, method: .get)
            .responseJSON(completionHandler: { response in
                
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    let data = self.getParamData(json)
                    let root = "user/"+(data["uid"] as! String)
                    print(data)
                    self.databaseRef.child(root).setValue(data)
                    //self.post(data)
                    
                case .failure(let error):
                    print(error)
                }
            }
        )
    }
    
    func getParamData(_ json: JSON) -> [String : Any] {
        //タイムスタンプ
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd-HH-mm-ss"
        let strDate = format.string(from: Date())
        
        let data: [String : Any] = ["uid": "ユーザー1","time": strDate, "latitude":  100, "longitude": 100, "pulse": json["heartRate"].stringValue] as [String : Any]
        
        return data

    }
    
    func post(_ data: [String : Any]) {
        let tamuraURL = "http://masayuki.nkmr.io/docomo/"
        let headers = ["Content-Type": "application/json"]
        
        //ここで配列でためって一気に送信数する
        Alamofire.request(tamuraURL, method: .post, parameters: data, headers: headers)
            .response(completionHandler: { response in
                if let error = response.error {
                    print(error.localizedDescription)
                }
                if response.response?.statusCode == 200 {
                    print("成功")
                }
            }
        )
    }
}
