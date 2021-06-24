//
//  ChangeLimitVC.swift
//  NanoChallenge
//
//  Created by Nico Christian on 03/05/21.
//

import UIKit

class ChangeLimitVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firstLaunchSetup()
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.selectRow(UserDefaults.standard.value(forKey: "currentLimit") as! Int - 1, inComponent: 0, animated: true)
    }
    
    let hours: [Double] = [1, 2, 3, 4, 5, 6, 7]
    var isFirstLaunch: Bool = false
    var selectedLimit: Double = UserDefaults.standard.value(forKey: "currentLimit") as! Double
    
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        currentPlaytimeLimit = selectedLimit
        UserDefaults.standard.setValue(currentPlaytimeLimit, forKey: "currentLimit")
        self.performSegue(withIdentifier: "ChangeLimitToSummary", sender: self)
    }
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func firstLaunchSetup() {
        if isFirstLaunch {
            print("masuk")
            self.title = "Set Your Limit"
            self.cancelButton.isEnabled = false
            self.saveButton.title = "Set"
        } else {
            self.imageView.image = UIImage(named: "StopwatchIcon")
        }
    }
}

extension ChangeLimitVC: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return hours.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return row == 0 ? "\(Int(hours[row])) hour" : "\(Int(hours[row])) hours"
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let string = row == 0 ? "\(Int(hours[row])) hour" : "\(Int(hours[row])) hours"
        return NSAttributedString(string: string, attributes: [NSAttributedString.Key.foregroundColor: secondaryLightBlue])
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedLimit = hours[row]
    }
}
