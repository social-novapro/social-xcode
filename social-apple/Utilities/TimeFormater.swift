//
//  TimeFormater.swift
//  social-apple
//
//  Created by Daniel Kravec on 2023-12-03.
//

import Foundation


func dateTimeFormatterInt64(date: Date) -> Int64 {
    // convert Date to TimeInterval (typealias for Double)
    let timeInterval = date.timeIntervalSince1970
    let myInt = Int64(timeInterval) // seconds
    return myInt*1000; // ms
}

func stringTimeFormatter(timestamp: String) -> String{
    if let epochTime = Double(timestamp) {
        let timeInterval = TimeInterval(epochTime)
        return timeFormater(timestampInMilliseconds: timeInterval)

    } else {
        print("Error: Unable to convert the string to TimeInterval.")
        return "Error"
    }
}

func int64TimeFormatter(timestamp: Int64) -> String {
    let timeInterval = TimeInterval(timestamp)
    return timeFormater(timestampInMilliseconds: timeInterval)
}

func int64TimeUntilFormatter(timestamp: Int64) -> String {
    let timeInterval = TimeInterval(timestamp)
    return timeFormaterUntil(timestampInMilliseconds: timeInterval)
}

func timeFormater(timestampInMilliseconds: TimeInterval) -> String {
    let timestampInSeconds = timestampInMilliseconds / 1000
    
    let date = Date(timeIntervalSince1970: timestampInSeconds)
    let currentDate = Date()

    let formatter = DateFormatter()
    formatter.dateFormat = "MMM d, yyyy"

    let dateString = formatter.string(from: date)

    let calendar = Calendar.current
    let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date, to: currentDate)
    
    var timeAgoString = ""


    if let year = components.year, year > 0 {
        timeAgoString = "\(year) " + (year == 1 ? "year" : "years")
    } else if let month = components.month, month > 0 {
        timeAgoString = "\(month) " + (month == 1 ? "month" : "months")
    } else if let day = components.day, day > 0 {
        timeAgoString = "\(day) " + (day == 1 ? "day" : "days")
    } else if let hour = components.hour, hour > 0 {
        timeAgoString = "\(hour) " + (hour == 1 ? "hour" : "hours")
    } else if let minute = components.minute, minute > 0 {
        timeAgoString = "\(minute) " + (minute == 1 ? "minute" : "minutes")
    } else {
        timeAgoString = "a moment"
    }

    let finalString = "\(dateString) - \(timeAgoString) ago"
//    print(finalString)
    return finalString
}


func timeFormaterUntil(timestampInMilliseconds: TimeInterval) -> String {
    let timestampInSeconds = timestampInMilliseconds / 1000
    
    let date = Date(timeIntervalSince1970: timestampInSeconds)
    let currentDate = Date()

    let formatter = DateFormatter()
    formatter.dateFormat = "MMM d, yyyy"

    let calendar = Calendar.current
    let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: currentDate, to: date)
    
    var timeAgoString = ""


    if let day = components.day, day > 0 {
        if let hour = components.hour, hour > 0 {
            timeAgoString = "\(day)" + ("d ") + "\(hour)" + ("h")
        } else {
            timeAgoString = "\(day)" + ("d")
        }
    } else if let hour = components.hour, hour > 0 {
        if let minute = components.minute, minute > 0 {
            timeAgoString = "\(hour)" + ("h ") + "\(minute)" + ("m")
        } else {
            timeAgoString = "\(hour)" + ("h")
        }
    } else if let minute = components.minute, minute > 0 {
        if let second = components.second, second > 0 {
            timeAgoString = "\(minute)" + ("m ") + "\(second)" + ("s ")
        } else {
            timeAgoString = "\(minute)" + ("m ")

        }
    } else {
        timeAgoString = "poll expired"
        return timeAgoString;
    }

    let finalString = "\(timeAgoString) left"
    return finalString
}
