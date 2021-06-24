//
//  AddDataVC.swift
//  NanoChallenge
//
//  Created by Nico Christian on 04/05/21.
//

import UIKit

class AddDataVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        pickerView.delegate = self
        pickerView.dataSource = self
    }
    let currentLimit = UserDefaults.standard.value(forKey: "currentLimit")
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var hour: Double = 0
    var min: Double = 0
    let minutes: [Double] = [0 ,5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55]
    var playtimeData: [PlaytimeDataEntity]?
    
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var pickerView: UIPickerView!
    
    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        if hour == 0 && min == 0 {
            return
        }
        let duration = (hour * 3600) + (min * 60)
        let newPlaytime = PlaytimeDataEntity(context: self.context)
        newPlaytime.datePlayed = Date()
        newPlaytime.duration = duration
        newPlaytime.limit = UserDefaults.standard.value(forKey: "currentLimit") as! Double
        newPlaytime.entryFrom = "Manual"
        do {
            try self.context.save()
        } catch {
            print("failed to save data")
        }
        self.performSegue(withIdentifier: "AddDataToSummary", sender: nil)
    }
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension AddDataVC: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return currentLimit as! Int + 1
        }
        return minutes.count
    }
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
