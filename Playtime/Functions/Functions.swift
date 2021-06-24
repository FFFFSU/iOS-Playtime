//
//  Functions.swift
//  NanoChallenge
//
//  Created by Nico Christian on 29/04/21.
//

import Foundation
import UIKit

func configureButtons(button: UIButton, title: String, backgroundColor: UIColor, tintColor: UIColor) {
    button.layer.cornerRadius = 8
    button.backgroundColor = backgroundColor
    button.tintColor = tintColor
    button.setTitle(title, for: .normal)
}

func dateToString(date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "E, MMM d"
    return formatter.string(from: (date))
}

func fullDateToString(date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "E, MMM d yyyy"
    return formatter.string(from: (date))
}

func secondsToString(seconds: Double, forView: String) -> String {
    let hour = Int(seconds / 3600)
    let min = Int((seconds / 60).truncatingRemainder(dividingBy: 60))
    let second = Int(seconds.truncatingRemainder(dividingBy: 3600).truncatingRemainder(dividingBy: 60))
    if forView == "History" {
        return "\(hour) hr, \(min) min, \(second) sec"
    } else if forView == "Timer" {
        return String(format: "%02d:%02d:%02d", hour, min, second)
    }
    return ""
}
