//
//  forecastCollectionViewCell.swift
//  Woosan
//
//  Created by joe on 2017. 12. 23..
//  Copyright © 2017년 joe. All rights reserved.
//

import UIKit

class forecastCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var timeBGView: UIView!
    @IBOutlet weak var forecastHour: UILabel!
    @IBOutlet weak var weatherImageView: UIImageView!
    @IBOutlet weak var forecastTemp: UILabel!
    @IBOutlet weak var rainPopLable: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.forecastHour.text = ""
        self.forecastTemp.text = ""
        self.rainPopLable.text = ""
    }

    
    func weatherData(dataPerHour:[String:String]) -> (forecastTime: String, temperature: String, rainPOP: String, icon:String) {
       
        guard let tempTime = dataPerHour["fcstTime"],
        let tempRain = dataPerHour[Constants.api_rain],
        let tempTemper = dataPerHour["T3H"] else { return ("0","0","0","")}
        
        let realTime = Int(tempTime)! / 100
        let realRainPOP = "\(tempRain)%"
        let realTemp = tempTemper
        var realIcon = "weather_default"
        
        if dataPerHour["PTY"] == "0" {
            guard let sky = dataPerHour["SKY"] else { return ("\(realTime)", realTemp, realRainPOP, realIcon) }
            switch sky {
            case "1":
                if realTime > 07 && realTime < 20 {
                    realIcon = IconForCell.Sunny.convertIcon()
                } else {
                    realIcon = IconForCell.ClearNight.convertIcon()
                }
            case "2":
                if realTime > 07 && realTime < 20 {
                    realIcon = IconForCell.LittleCloudy.convertIcon()
                } else {
                    realIcon = IconForCell.LittleCloudyNight.convertIcon()
                }
            case "3":
                realIcon = IconForCell.MoreCloudy.convertIcon()
            case "4":
                realIcon = IconForCell.Cloudy.convertIcon()
            default:
                realIcon = "weather_default"
            }
        } else {
            guard let rain = dataPerHour["PTY"] else { return ("\(realTime)", realTemp, realRainPOP, realIcon) }
            switch rain {
            case "1":
                realIcon = IconForCell.Rainy.convertIcon()
            case "2":
                realIcon = IconForCell.Sleet.convertIcon()
            case "3":
                realIcon = IconForCell.Snow.convertIcon()
            default:
                realIcon = "weather_default"
            }
        }
        return ("\(realTime)시", realTemp, realRainPOP, realIcon)
    }
    
}

//아이콘 이름을 뱉게 하고싶다.

enum IconForCell {
    case Sunny
    case LittleCloudy
    case MoreCloudy
    case Cloudy
    case ClearNight
    case LittleCloudyNight
    case Rainy
    case Sleet
    case Snow
    
    func convertIcon() -> String {
        switch self {
        case .Sunny:
            return "SKY_M01"
        case .LittleCloudy:
            return "SKY_M02"
        case .MoreCloudy:
            return "SKY_M03"
        case .Cloudy:
            return "SKY_M04"
        case .ClearNight:
            return "SKY_M08"
        case .LittleCloudyNight:
            return "SKY_M09"
        case .Rainy:
            return "RAIN_M01"
        case .Sleet:
            return "SKY_M02"
        case .Snow:
            return "SKY_M03"
        }
    }
}


