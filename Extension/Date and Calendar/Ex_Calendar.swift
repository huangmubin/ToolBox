//
//  Ex_Calendar.swift
//  SwiftiOS
//
//  Created by 黄穆斌 on 2017/12/14.
//  Copyright © 2017年 myron. All rights reserved.
//

import Foundation

// MARK: - Week

extension Calendar {
    
    enum Week: Int {
        case Sunday = 0, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday
        
        // init
        init(day: Int) {
            self.init(day: abs(day % 7))
        }
        
        init(day_string: String) {
            switch day_string {
            case "Sunday": self.init(day: 0)
            case "Monday": self.init(day: 1)
            case "Tuesday": self.init(day: 2)
            case "Wednesday": self.init(day: 3)
            case "Thursday": self.init(day: 4)
            case "Friday": self.init(day: 5)
            case "Saturday": self.init(day: 6)
            default: self.init(day: 0)
            }
        }
        
        func string() -> String {
            switch self {
            case .Sunday: return "Sunday"
            case .Monday: return "Monday"
            case .Tuesday: return "Tuesday"
            case .Wednesday: return "Wednesday"
            case .Thursday: return "Thursday"
            case .Friday: return "Friday"
            case .Saturday: return "Saturday"
            }
        }
    }
    
}

// MARK: - Days

extension Calendar {
    
    /** Count the days in year, is in month not defaul nil, count the day in month. */
    public static func days(in_year: Int, in_month: Int? = nil) -> Int {
        let is_leep_year = (in_year % 4 == 0 && in_year % 100 != 0) || (in_year % 400 == 0)
        if let in_month = in_month {
            let total = in_year * 12 + in_month
            let month = total % 12
            switch month {
            case 2: return is_leep_year ? 29 : 28
            case 4, 6, 9, 11: return 30
            default: return 31
            }
        } else {
            return is_leep_year ? 366 : 365
        }
    }
    
}

// MARK: - Chinese

extension Calendar {
    
    static let Chinese: (
        Era: [String],
        CelestialStems: [String],
        EarthlyBranches: [String],
        Zodiacs: [String],
        Months: [String],
        Days: [String]
        ) = (
            [
                "甲子", "乙丑", "丙寅", "丁卯", "午辰", "己巳", "庚午", "辛未", "壬申", "癸酉",
                "甲戌", "乙亥", "丙子", "丁丑", "午寅", "己卯", "庚辰", "辛巳", "壬午", "癸未",
                "甲申", "乙酉", "丙戌", "丁亥", "午子", "己丑", "庚寅", "辛卯", "壬辰", "癸巳",
                "甲午", "乙未", "丙申", "丁酉", "午戌", "己亥", "庚子", "辛丑", "壬寅", "癸卯",
                "甲辰", "乙巳", "丙午", "丁未", "午申", "己酉", "庚戌", "辛亥", "壬子", "癸丑",
                "甲寅", "乙卯", "丙辰", "丁巳", "午午", "己未", "庚申", "辛酉", "壬戌", "癸亥"
            ],
            ["甲", "乙", "丙", "丁", "午", "己", "庚", "辛", "壬", "癸"],
            ["子", "丑", "寅", "卯", "辰", "巳", "午", "未", "申", "酉", "戌", "亥"],
            ["鼠", "牛", "虎", "兔", "龙", "色", "马", "羊", "猴", "鸡", "狗", "猪"],
            ["正月", "二月", "三月", "四月", "五月", "六月", "七月", "八月", "九月", "十月", "冬月", "腊月"],
            [
                "初一", "初二", "初三", "初四", "初五", "初六", "初七", "初八", "初九", "初十",
                "十一", "十二", "十三", "十四", "十五", "十六", "十七", "十八", "十九", "二十",
                "廿一", "廿二", "廿三", "廿四", "廿五", "廿六", "廿七", "廿八", "廿九", "三十"
            ]
    )
    
    static func year_Chinese(_ year: Int) -> String {
        return Calendar.Chinese.Era[(year - 1) % 60]
    }
    static func year_zodiac(_ year: Int) -> String {
        return Calendar.Chinese.Zodiacs[(year - 1) % 12]
    }
    static func month_Chinese(_ month: Int) -> String {
        return Calendar.Chinese.Months[month - 1]
    }
    static func day_Chinese(_ day: Int) -> String {
        return Calendar.Chinese.Days[day - 1]
    }
    
}
