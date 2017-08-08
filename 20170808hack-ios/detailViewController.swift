//
//  detailViewController.swift
//  20170808hack-ios
//
//  Created by Daichi Shibata on 2017/08/08.
//  Copyright © 2017 rungineer. All rights reserved.
//

import UIKit

class detailViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textView: UILabel!
    
    //最初からあるメソッド
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //前画面ボタンとトップ画面ボタンの2つを設定する。
//        let leftButton1 = UIBarButtonItem(title: "前画面", style: UIBarButtonItemStyle.plain, target: self, action: "goBefore")
//        self.navigationItem.leftBarButtonItems = [leftButton1]
        
        imageView.image = selectedImage
        textView.text = selectedText!
    }
    
    
    //トップ画面ボタン押下時の呼び出しメソッド
    func goTop() {
        //トップ画面に戻る。
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    
    //前画面ボタン押下時の呼び出しメソッド
    func goBefore() {
        
        //前画面に戻る。
        self.navigationController?.popToRootViewController(animated: true)
    }
}
