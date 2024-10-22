//
//  AppStyles.swift
//  CalendarMap
//
//  Created by JeongHwan Seok on 2023/06/28.
//

import UIKit

enum AppStyles {
    enum Fonts {
        static let Body1 = UIFont(name: "NotoSansKR-Medium", size: 15)
        static let Body2 = UIFont(name: "NotoSansKR-Bold", size: 14)
        static let Body3 = UIFont(name: "NotoSansKR-Medium", size: 13)
        static let Body4 = UIFont(name: "NotoSansKR-Bold", size: 12)
        static let Heading1 = UIFont(name: "NotoSansKR-Bold", size: 16)
        static let Heading2 = UIFont(name: "NotoSansKR-Medium", size: 16)
    }
    
    enum Color {
        static let Gray1 = UIColor(hex: "F5F5F5")
        static let Gray2 = UIColor(hex: "EFEFEF")
        static let Gray3 = UIColor(hex: "E8E8E8")
        static let Gray4 = UIColor(hex: "DFDFDF")
        static let Gray5 = UIColor(hex: "B7B7B7")
        static let Gray6 = UIColor(hex: "949494")
        static let Gray7 = UIColor(hex: "777777")
        static let Gray8 = UIColor(hex: "555555")
        static let Gray9 = UIColor(hex: "111111")
        
        static let Black = UIColor(hex: "000000")
        static let Blue = UIColor(hex: "258FFB")
        static let Purple = UIColor(hex: "7562EE")
        static let Pink = UIColor(hex: "FF73F1")
        static let Red = UIColor(hex: "FF5964")
        static let Orange = UIColor(hex: "FF9900")
        static let Yellow = UIColor(hex: "F9E05F")
        static let Green = UIColor(hex: "59CD90")
        
        static let LightBlue = UIColor(hex: "B0D7FD")
        static let LightGreen = UIColor(hex: "D6F263")
        
        static let Shadow = UIColor(hex: "B7B7B7")
    }
    
    enum ColorCircle {
        static let colorImages = ["color_blue", "color_purple", "color_pink", "color_red", "color_orange",
                           "color_yellow", "color_green", "color_lightgreen", "color_gray7", "color_gray3"]
        static let colorCheckImages = ["color_check_blue", "color_check_purple", "color_check_pink", "color_check_red", "color_check_orange",
                          "color_check_yellow", "color_check_green", "color_check_lightgreen", "color_check_gray7", "color_check_gray3"]
        static let backgroundCircle = ["background_circle_color_blue", "background_circle_color_purple", "background_circle_color_pink", "background_circle_color_red", "background_circle_color_orange", "background_circle_color_yellow", "background_circle_color_green", "background_circle_color_lightgreen", "background_circle_color_gray7", "background_circle_color_gray3"]
        static let backgroundSquare = ["background_square_color_blue", "background_square_color_purple", "background_square_color_pink", "background_square_color_red", "background_square_color_orange", "background_square_color_yellow", "background_square_color_green", "background_square_color_lightgreen", "background_square_color_gray7", "background_square_color_gray3"]
    }
}
