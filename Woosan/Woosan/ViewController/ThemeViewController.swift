//
//  ThemeViewController.swift
//  Woosan
//
//  Created by joe on 2017. 12. 10..
//  Copyright © 2017년 joe. All rights reserved.
//

import UIKit

class ThemeViewController: UIViewController {
    
    /*******************************************/
    //MARK:-          Property                 //
    /*******************************************/
    
    @IBOutlet weak var tableView: UITableView!
    
    // TODO: - :: 지금은 model과 controller가 다 붙어있는...고쳐야댕
    let shareData = UserDefaults(suiteName: DataShare.widgetShareDataKey)

    
    /*******************************************/
    //MARK:-          LifeCycle                //
    /*******************************************/
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "테마"
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.register(UINib(nibName: "ThemeTableViewCell", bundle: nil), forCellReuseIdentifier: "ThemeTableViewCell")

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func touchSelect(sender:UIButton){
//        sender.isSelected = !sender.isSelected
        //디폴트는 인덱스 0번이 Selected 상태.
        //다른 태그의 버튼이 눌리면 그 태그 버튼 빼고 전부 off 되야되는 상황
        //어떤 테마를 선택했는지 userDefault에 저장하고 그 값으로 스위치를 켜야되나..
        UserDefaults.standard.set(sender.tag, forKey: DataShare.selectedThemeKey)
        saveShareData()
        print("선택됨", sender.tag)
        print("여기코드!: ",UserDefaults.standard.integer(forKey: DataShare.selectedThemeKey))
        self.tableView.reloadData()
        themAlert()
    }
    
    func themAlert(){
        let alert = UIAlertController.init(title: "테마 적용 완료!", message: "적용한 테마: \(ThemeInfo.titles[UserDefaults.standard.integer(forKey: DataShare.selectedThemeKey)]) 😘", preferredStyle: .alert)
        let action = UIAlertAction.init(title: "확인", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func saveShareData(){
        guard let shareData = UserDefaults(suiteName: DataShare.widgetShareDataKey) else { return }
        shareData.set(UserDefaults.standard.integer(forKey: DataShare.selectedThemeKey), forKey: DataShare.widgetShareDataKey)
        shareData.synchronize()
    }
}


extension ThemeViewController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ThemeInfo.titles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ThemeTableViewCell", for: indexPath) as! ThemeTableViewCell
        cell.selectionStyle = .none
        cell.themeTitle.text = ThemeInfo.titles[indexPath.row]
        cell.themeSubsc.text = ThemeInfo.subscrip[indexPath.row]
        cell.themeImage.image = UIImage(named: ThemeInfo.image[indexPath.row])
        cell.clickedCheck.tag = indexPath.row
        cell.clickedCheck.addTarget(self, action: #selector(touchSelect(sender:)), for: .touchUpInside)
        //유저디폴트에있는것만 on, 나머지는 off
        let selectThem = UserDefaults.standard.integer(forKey: DataShare.selectedThemeKey)
        switch selectThem {
        case indexPath.row :
            cell.clickedCheck.isSelected = true
        default:
            cell.clickedCheck.isSelected = false
        }
        return cell
    }
}

extension ThemeViewController : UITableViewDelegate {
   
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
}
