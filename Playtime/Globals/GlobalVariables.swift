//
//  PlaytimeClass.swift
//  NanoChallenge
//
//  Created by Nico Christian on 29/04/21.
//

import Foundation
import UIKit

var currentPlaytimeLimit: Double = -1
var enteringBackgroundTime: Date = Date()
var enteringForegroundTime: Date = Date()
let primaryNavy = #colorLiteral(red: 0.06666666667, green: 0.2509803922, blue: 0.4, alpha: 1)
let secondaryNavy = #colorLiteral(red: 0.1882352941, green: 0.4274509804, blue: 0.6196078431, alpha: 1)
let primaryLightBlue = #colorLiteral(red: 0.6941176471, green: 0.831372549, blue: 0.8784313725, alpha: 1)
let secondaryLightBlue = #colorLiteral(red: 0.8588235294, green: 0.9647058824, blue: 1, alpha: 1)
let primaryGreen = #colorLiteral(red: 0.01568627451, green: 0.8784313725, blue: 0, alpha: 1)
let primaryOrange = #colorLiteral(red: 1, green: 0.6588235294, blue: 0, alpha: 1)
let primaryRed = #colorLiteral(red: 1, green: 0.3019607843, blue: 0, alpha: 1)

struct Playtime {
    let datePlayed: Date
    let duration: Double
    let limit: Double
}

class PlaytimeData {
    static let sharedPlaytimeData = PlaytimeData()
    
    var playtimes: [Playtime] = [Playtime]()
    
    func getCount() -> Int {
        return playtimes.count
    }
    
    func addPlaytime(playtime: Playtime) {
        playtimes.append(playtime)
    }
}
