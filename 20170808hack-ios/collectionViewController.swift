//
//  collectionViewController.swift
//  20170808hack-ios
//
//  Created by Daichi Shibata on 2017/08/08.
//  Copyright © 2017 rungineer. All rights reserved.
//

import UIKit

var selectedImage: UIImage?
var selectedText: String?

class collectionViewController: UIViewController ,UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate {
    
    // サムネイル画像のタイトル
    let photos = ["rittu.jpg","六本木の夜景.jpg","LaQua.jpg","すみだ水族館.jpg","とよしまえん.jpg","上野動物園.jpg","代々木公園.jpg","六本木ヒルズ.jpg","日比谷公園.jpg","東京スカイツリー.jpg", "東京ミッドタウン.jpg", "東京都庁展望室.jpg", "浜離宮恩賜庭園.jpg", "花やしき.jpg", "表参道.jpg"]

    let cellMargin: CGFloat = 0
    
    @IBOutlet weak var uisearchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        uisearchBar.placeholder = "検索キーワードを入力してください"
        uisearchBar.delegate = self
        uisearchBar.showsCancelButton = true
        self.view.addSubview(uisearchBar)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        
        // Cell はストーリーボードで設定したセルのID
        let testCell:UICollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        
        // Tag番号を使ってImageViewのインスタンス生成
        let imageView = testCell.contentView.viewWithTag(1) as! UIImageView
        // 画像配列の番号で指定された要素の名前の画像をUIImageとする
        let cellImage = UIImage(named: photos[(indexPath as NSIndexPath).row])
        // UIImageをUIImageViewのimageとして設定
        imageView.image = cellImage
        
        // Tag番号を使ってLabelのインスタンス生成
        let label = testCell.contentView.viewWithTag(2) as! UILabel
        label.text = photos[(indexPath as NSIndexPath).row]
        label.text = label.text?.replacingOccurrences(of: ".jpg", with: "")
        return testCell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // section数は１つ
        return 1
    }
    
    // Screenサイズに応じたセルサイズを返す
    // UICollectionViewDelegateFlowLayoutの設定が必要
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellSize:CGFloat = self.view.frame.size.width/2
        // 正方形で返すためにwidth,heightを同じにする
        return CGSize(width: cellSize, height: cellSize)
    }
    
    // Cell が選択された場合
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // [indexPath.row] から画像名を探し、UImage を設定
        selectedImage = UIImage(named: photos[(indexPath as NSIndexPath).row])
        print(photos[(indexPath as NSIndexPath).row])

        if selectedImage != nil {
            // SubViewController へ遷移するために Segue を呼び出す
//            performSegue(withIdentifier: "toSubViewController",sender: nil)
//            print(selectedText?.text)
            selectedText = photos[(indexPath as NSIndexPath).row]
            selectedText = selectedText?.replacingOccurrences(of: ".jpg", with: "")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // 要素数を入れる、要素以上の数字を入れると表示でエラーとなる
        return 15;
    }
    
    //セルの垂直方向のマージンを設定
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return cellMargin
    }
    
    //セルの水平方向のマージンを設定
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return cellMargin
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.uisearchBar.endEditing(true)
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.uisearchBar.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
