//
//  DateExtension.swift
//  VariableHolidays
//
//  Created by Jerzy Żerdziński on 20/05/2025.
//

import Foundation

extension Date {
    
    static func fromYMD(year: Int, month: Int, day: Int) -> Date {
        let calendar = Calendar.current
        let components = DateComponents(year: year, month: month, day: day, hour: 0, minute: 0, second: 0)
        return calendar.date(from: components)!
    }
    
    init?(year: Int, month: Int, day: Int) {
        let calendar = Calendar.current
        let components = DateComponents(year: year, month: month, day: day, hour: 0, minute: 0, second: 0)
        if let newDate = calendar.date(from: components) {
            self = newDate
        } else {
            return nil
        }
    }
    
    mutating func addDays(numberOfDays: Int) {
        let calendar = Calendar.current
        var dateComponent = DateComponents()
        dateComponent.hour = 24 * numberOfDays
        let newDate = calendar.date(byAdding: dateComponent, to: self) ?? Date()
        self = newDate
    }
    
    func dayNumberOfWeek() -> Int {
        return Calendar.current.dateComponents([.weekday], from: self).weekday!
    }
    
    var ymd: DateComponents {
        let calendar = Calendar.current
        return calendar.dateComponents([.year, .month, .day], from: self)
    }
    
    func isSameDate(date: Date) -> Bool {
        let me = self.ymd
        let other = date.ymd
        return me == other
    }
    
    func daysBetween(date: Date) -> Int {
        let calendar = Calendar.current
        let dateMe = calendar.startOfDay(for: self)
        let dateOther = calendar.startOfDay(for: date)
        let numberOfDays = calendar.dateComponents([.day], from: dateMe, to: dateOther)
        return numberOfDays.day!
    }
    
    func isWeekend() -> Bool {
        switch self.dayNumberOfWeek() {
        case 1, 7: return true // 1 = niedziela, 7 = sobota
        default: return false
        }
    }
    static func easterDate(for year: Int) -> Date {
        let a = year % 19
        let b = year / 100
        let c = year % 100
        let d = b / 4
        let e = b % 4
        let f = (b + 8) / 25
        let g = (b - f + 1) / 3
        let h = (19 * a + b - d - g + 15) % 30
        let i = c / 4
        let k = c % 4
        let l = (32 + 2 * e + 2 * i - h - k) % 7
        let m = (a + 11 * h + 22 * l) / 451
        let p = (h + l - 7 * m + 114)
        let day = (p % 31) + 1
        let month = p / 31
        return Date.fromYMD(year: year, month: month, day: day)
    }
    func countWorkdays(to endDate: Date) -> Int {
        var workdays = 0
        var currentDate = Calendar.current.startOfDay(for: self)
        let end = Calendar.current.startOfDay(for: endDate)
        
        let calendar = Calendar.current
        let yearRange = calendar.dateComponents([.year], from: currentDate, to: end).year ?? 0
        var holidays: Set<Date> = []
        
        for offset in 0...yearRange {
            let year = calendar.component(.year, from: currentDate) + offset
            
            // Stałe dni wolne od pracy
            let fixedHolidays = [
                Date.fromYMD(year: year, month: 1, day: 1),
                Date.fromYMD(year: year, month: 1, day: 6),
                Date.fromYMD(year: year, month: 5, day: 1),
                Date.fromYMD(year: year, month: 5, day: 3),
                Date.fromYMD(year: year, month: 8, day: 15),
                Date.fromYMD(year: year, month: 11, day: 1),
                Date.fromYMD(year: year, month: 11, day: 11),
                Date.fromYMD(year: year, month: 12, day: 25),
                Date.fromYMD(year: year, month: 12, day: 26),
            ].compactMap { $0 }
            
            // Wielkanoc i święta ruchome
            let easter = Date.easterDate(for: year)
            let easterMonday = Calendar.current.date(byAdding: .day, value: 1, to: easter)!
            let corpusChristi = Calendar.current.date(byAdding: .day, value: 60, to: easter)!
            
            holidays.formUnion(fixedHolidays)
            holidays.insert(Calendar.current.startOfDay(for: easterMonday))
            holidays.insert(Calendar.current.startOfDay(for: corpusChristi))
        }
        
        while currentDate <= end {
            let isWeekend = currentDate.isWeekend()
            let isHoliday = holidays.contains(currentDate)
            
            if !isWeekend && !isHoliday {
                workdays += 1
            }
            
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        return workdays
    }
}
