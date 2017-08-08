//
//  detailViewController.swift
//  20170808hack-ios
//
//  Created by Daichi Shibata on 2017/08/08.
//  Copyright © 2017 rungineer. All rights reserved.
//

import UIKit

class detailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textView: UILabel!
    
    @IBOutlet weak var manGageImage: UIImageView!
    @IBOutlet weak var allGageImage: UIImageView!
    @IBOutlet weak var womanGageImage: UIImageView!
    
    @IBOutlet weak var reviewTableView: UITableView!

    //最初からあるメソッド
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //前画面ボタンとトップ画面ボタンの2つを設定する。
//        let leftButton1 = UIBarButtonItem(title: "前画面", style: UIBarButtonItemStyle.plain, target: self, action: "goBefore")
//        self.navigationItem.leftBarButtonItems = [leftButton1]
        
        let image1:UIImage = UIImage(named:"1.png")!//絶好調
        let image2:UIImage = UIImage(named:"2.png")!//ビミョー
        let image3:UIImage = UIImage(named:"3.png")!//にこにこ

        
        imageView.image = selectedImage
        textView.text = selectedText!
        
        allGageImage.image = image3
        manGageImage.image = image3
        womanGageImage.image = image1
        
        // Delegate設定
        reviewTableView.delegate = self
        
        // DataSource設定
        reviewTableView.dataSource = self
        
        // 画面に UITableView を追加
        self.view.addSubview(reviewTableView)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // セルを作る
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "mycell")
        cell.accessoryType = .detailButton
        cell.textLabel?.text = "dokidoki\(indexPath.row + 1)"
        cell.detailTextLabel?.text = "\(indexPath.row + 1)kittol 最高 です"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // セルの数を設定
        return 5
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // セルがタップされた時の処理
        print("タップされたセルのindex番号: \(indexPath.row)")
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // セルの高さを設定
        return 64
    }
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        // アクセサリボタン（セルの右にあるボタン）がタップされた時の処理
        print("タップされたアクセサリがあるセルのindex番号: \(indexPath.row)")
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
