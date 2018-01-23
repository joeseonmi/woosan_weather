//
//  CheckPermission.swift
//  Woosan
//
//  Created by joe on 2018. 1. 23..
//  Copyright © 2018년 joe. All rights reserved.
//

import UIKit
import CoreLocation

class CheckPermission: UIViewController, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    var permission:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        let status = CLLocationManager.authorizationStatus()
        switch status {
        case .authorizedAlways, .authorizedWhenInUse :
            self.permission = true
        case .notDetermined :
            locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted : break
        }

        if let realLat = locationManager.location?.coordinate.latitude, let realLon = locationManager.location?.coordinate.longitude {
            
        }

    }
    override func viewDidAppear(_ animated: Bool) {
        super .viewDidAppear(true)
        
        if self.permission {
            self.presentMain()
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            self.permission = true
            self.presentMain()
        } else if status == .denied || status == .restricted {
            self.alert()
        }
    }
    
    func checkPermission(){
        let status = CLLocationManager.authorizationStatus()
        switch status {
        case .authorizedAlways, .authorizedWhenInUse :
            self.permission = true
        case .notDetermined :
            locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted :
            self.alert()
        }
    }
    
    func presentMain(){
        let nextVC:ViewController = storyboard?.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        self.present(nextVC, animated: true, completion: nil)
    }
    
    func alert(){
        let alert:UIAlertController = UIAlertController.init(title: "위치정보 가져오기 실패", message: "설정에서 위치정보를 허용해주세요!🤗", preferredStyle: .alert)
        let alertAction:UIAlertAction = UIAlertAction.init(title: "확인", style: .cancel, handler: nil)
        alert.addAction(alertAction)
        self.present(alert, animated: true, completion: nil)
    }

}
