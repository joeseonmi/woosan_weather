//
//  IntroduceViewController.swift
//  Woosan
//
//  Created by joe on 2017. 12. 10..
//  Copyright © 2017년 joe. All rights reserved.
//

import UIKit
import MessageUI

class IntroduceViewController: UIViewController,MFMailComposeViewControllerDelegate {
    
    @IBAction func sendMail(_ sender: UIButton) {
        let mailViewcontroller = MFMailComposeViewController()
        mailViewcontroller.mailComposeDelegate = self
        mailViewcontroller.setToRecipients(["jemma3136@gmail.com"])
        mailViewcontroller.setSubject("[우산챙기개]: 제목을 적어주세요")
        mailViewcontroller.setMessageBody("\n\n\n\n소중한 의견 감사합니다.🤗", isHTML: false)
        
        if MFMailComposeViewController.canSendMail(){
            self.present(mailViewcontroller, animated: true, completion: nil)
        } else {
            falseSendMailalert(title: "메일전송 실패", message: "메일 전송에 실패하였습니다.")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "만든 사람"
        
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        switch result {
        case .cancelled:
            print("취소됨")
        case .failed:
            print("실패됨")
        case .saved:
            print("임시저장됨")
        case .sent:
            print("전송됨")
        }
        dismiss(animated: true, completion: nil)
    }
    
    func falseSendMailalert(title text:String, message messageText:String){
        let alert = UIAlertController.init(title: text, message: messageText, preferredStyle: .alert)
        let action = UIAlertAction.init(title: "확인", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}

