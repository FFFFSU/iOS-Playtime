//
//  TimerVC.swift
//  NanoChallenge
//
//  Created by Nico Christian on 28/04/21.
//

import UIKit

class TimerPickerVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        askNotificationPermission()
        pickerView.delegate = self
        pickerView.dataSource = self
        configureButtons(button: startButton, title: "Start", backgroundColor: primaryLightBlue, tintColor: primaryNavy)
    }
    
    let currentLimit = UserDefaults.standard.value(forKey: "currentLimit")
    var hour: Double = 0
    var min: Double = 0
    let minutes: [Double] = [0 ,5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55]

    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var pickerView: UIPickerView!
    
    @IBAction func startButtonTapped() {
        if hour == 0 && min == 0 {
            return
        }
        let durationInSeconds = (hour * 3600) + (min * 60)
        self.performSegue(withIdentifier: "TimerPickerToTimer", sender: durationInSeconds)
    }
    @IBAction func cancelButtonTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func askNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                //
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "TimerPickerToTimer" {
            let timerVC = segue.destination as? TimerVC
            timerVC?.totalDuration = sender as! Double
        }
    }
}

extension TimerPickerVC: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return currentLimit as! Int + 1
        }
        return minutes.count
    }
    
//    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//        if component == 0 {
//            return row == 0 ? "\(row) hour" : "\(row) hours"
//        }
//        return row == 0 ? "\(minutes[row]) minute" : "\(minutes[row]) minutes"
//    }
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let string = component == 0 ? (row == 0 ? "\(row) hour" : "\(row) hours") : (row == 0 ? "\(Int(minutes[row])) minute" : "\(Int(minutes[row])) minutes")
        return NSAttributedString(string: string, attributes: [NSAttributedString.Key.foregroundColor: secondaryLightBlue])
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            hour = Double(row)
        } else {
            min = Double((row * 5))
        }
    }
}
