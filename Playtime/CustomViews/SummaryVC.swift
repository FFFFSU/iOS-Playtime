//
//  SummaryVC.swift
//  NanoChallenge
//
//  Created by Nico Christian on 28/04/21.
//

import UIKit
import UserNotifications

class SummaryVC: UIViewController {
    
    let todayCircleTrack = CAShapeLayer()
    let todayCircle = CAShapeLayer()
    let weekCircleTrack = CAShapeLayer()
    let weekCircle = CAShapeLayer()
    
    // Core Data
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var playtimeData: [PlaytimeDataEntity]?

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchPlaytimeData()
        checkFirstLaunch()
        makeCircle()
        configureButtons(button: letsPlayButton, title: "Let's Play", backgroundColor: primaryLightBlue, tintColor: primaryNavy)
        updateSummaryLabels()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        updateUI()
    }
    
    // MARK: Outlets
    @IBOutlet weak var letsPlayButton: UIButton!
    @IBOutlet weak var todaysPlaytimeLabel: UILabel!
    @IBOutlet weak var thisWeeksPlaytimeLabel: UILabel!
    
    // MARK: IBActions
    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        presentAlert(choice: "AddData")
    }
    @IBAction func letsPlayButtonTapped(_ sender: UIButton) {
        
    }
    @IBAction func unwindToSummaryVC(_ segue: UIStoryboardSegue) {
        if segue.identifier == "AddDataToSummary" || segue.identifier == "ChangeLimitToSummary" {
            updateUI()
        } else {
            return
        }
    }
    
    // MARK: Functions
    private func presentAlert(choice: String) {
        
        let ac = UIAlertController(
            title: "Change Limit",
            message: "Enter in your new daily limit (in hours)",
            preferredStyle: .alert)
        
        // Add Text Field & Configuration
        ac.addTextField(configurationHandler: nil)
        let alertTextField = ac.textFields![0]
        alertTextField.placeholder = "In hours"
        alertTextField.keyboardType = .numberPad
        
        // Add, Change, Cancel Button
        let addDataAction = UIAlertAction(title: "Add", style: .default) { [self] _ in
            let userInput = Double(alertTextField.text ?? "0") ?? 0
            let newPlaytime = PlaytimeDataEntity(context: self.context)
            newPlaytime.datePlayed = Date()
            newPlaytime.duration = userInput
            newPlaytime.limit = UserDefaults.standard.value(forKey: "currentLimit") as! Double
            
            do {
                try self.context.save()
            } catch {
                print("failed to save data")
            }
            updateUI()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        // Add Action to alert and present
        ac.addAction(addDataAction)
        ac.addAction(cancelAction)
        present(ac, animated: true)
    }
    
    func updateSummaryLabels() {
        let today = fullDateToString(date: Date())
        let todayArray = playtimeData?.filter { (fullDateToString(date: $0.datePlayed ?? Date()) == today)}
        guard let todaysPlaytime = (todayArray?.reduce(0) { $0 + $1.duration }) else { return }
        todaysPlaytimeLabel.text = "\(String(format: "%.1f", todaysPlaytime / 3600)) / \(Int(currentPlaytimeLimit)) hr"
        thisWeeksPlaytimeLabel.text = "\(String(format: "%.1f", todaysPlaytime / 3600)) / \(Int(currentPlaytimeLimit * 7)) hr"
    }
    
    func animateCircle() {
        guard let dailyLimit = UserDefaults.standard.value(forKey: "currentLimit") as? Double else { return }
        let todayStep = 0.8 / (dailyLimit * 3600)
        let weeklyStep = 0.8 / (dailyLimit * 7 * 3600)
        
        let today = fullDateToString(date: Date())
        let todayArray = playtimeData?.filter { (fullDateToString(date: $0.datePlayed ?? Date()) == today)}
        guard let todayValue = (todayArray?.reduce(0) {$0 + $1.duration}),
              let totalPlaytime = (playtimeData?.reduce(0) { $0 + $1.duration }) else { return }
        let firstThreshold = dailyLimit * 1 / 3 * 3600
        let secondThreshold = dailyLimit * 2 / 3 * 3600
        let weekFirstThreshold = firstThreshold * 7
        let weekSecondThreshold = secondThreshold * 7
        
        UIView.animate(withDuration: 1, animations: {
            self.todayCircle.strokeEnd = CGFloat(todayValue * todayStep)
            self.weekCircle.strokeEnd = CGFloat(todayValue * weeklyStep)
        })
        
        var todayColor = primaryGreen.cgColor
        if todayValue >= firstThreshold && todayValue <= secondThreshold {
            todayColor = primaryOrange.cgColor
        } else if todayValue > secondThreshold {
            todayColor = primaryRed.cgColor
        }
        var weekColor = primaryGreen.cgColor
        if totalPlaytime >= weekFirstThreshold && totalPlaytime <= weekSecondThreshold {
            weekColor = primaryOrange.cgColor
        } else if totalPlaytime > weekSecondThreshold {
            weekColor = primaryRed.cgColor
        }
        UIView.animate(withDuration: 1, animations: {
            self.todayCircle.strokeColor = todayColor
            self.weekCircle.strokeColor = weekColor
        })
    }
    
    func fetchPlaytimeData() {
        do {
            self.playtimeData = try context.fetch(PlaytimeDataEntity.fetchRequest())
        } catch {
            print("error")
        }
    }
    
    func makeCircle() {
        let radius = CGFloat(120)
        let todayCenter = CGPoint(x: view.center.x, y: todaysPlaytimeLabel.frame.midY)
        var circularShape = UIBezierPath(arcCenter: todayCenter, radius: radius, startAngle: -CGFloat.pi / 2, endAngle: 2 * CGFloat.pi, clockwise: true)
        todayCircleTrack.path = circularShape.cgPath
        todayCircleTrack.strokeColor = secondaryNavy.cgColor
        todayCircleTrack.fillColor = UIColor.clear.cgColor
        todayCircleTrack.lineWidth = 8
        todayCircleTrack.strokeEnd = 1
        view.layer.addSublayer(todayCircleTrack)
        
        todayCircle.path = circularShape.cgPath
        todayCircle.strokeColor = primaryGreen.cgColor
        todayCircle.fillColor = UIColor.clear.cgColor
        todayCircle.lineWidth = 8
        todayCircle.strokeStart = 0
        todayCircle.strokeEnd = 0.8
        todayCircle.lineCap = CAShapeLayerLineCap.round
        view.layer.addSublayer(todayCircle)
        
        let weekCenter = CGPoint(x: view.center.x, y: thisWeeksPlaytimeLabel.frame.midY)
        circularShape = UIBezierPath(arcCenter: weekCenter, radius: radius, startAngle: -CGFloat.pi / 2, endAngle: 2 * CGFloat.pi, clockwise: true)
        
        weekCircleTrack.path = circularShape.cgPath
        weekCircleTrack.strokeColor = secondaryNavy.cgColor
        weekCircleTrack.fillColor = UIColor.clear.cgColor
        weekCircleTrack.lineWidth = 8
        weekCircleTrack.strokeEnd = 1
        view.layer.addSublayer(weekCircleTrack)
        
        weekCircle.path = circularShape.cgPath
        weekCircle.strokeColor = primaryGreen.cgColor
        weekCircle.fillColor = UIColor.clear.cgColor
        weekCircle.lineWidth = 8
        weekCircle.strokeEnd = 0.8
        weekCircle.lineCap = CAShapeLayerLineCap.round
        view.layer.addSublayer(weekCircle)
        
    }
    
    func updateUI() {
        fetchPlaytimeData()
        updateSummaryLabels()
        animateCircle()
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToChangeLimit" {
            guard let firstLaunch = sender as? String,
                  let navController = segue.destination as? UINavigationController,
                  let changeLimitVC = navController.viewControllers.first as? ChangeLimitVC
                  else { return }
            if firstLaunch == "firstLaunch" {
                print("to change limit")
                navController.modalPresentationStyle = .fullScreen
                changeLimitVC.navigationItem.leftBarButtonItem?.isEnabled = false
                changeLimitVC.isFirstLaunch = true
            }
        }
    }
    
    func checkFirstLaunch() {
        guard let isFirstLaunch = UserDefaults.standard.value(forKey: "firstLaunch") as? Int,
              let limit = UserDefaults.standard.value(forKey: "currentLimit") as? Int
        else { return }
        if isFirstLaunch == 1 || limit == 0 {
            performSegue(withIdentifier: "ToChangeLimit", sender: "firstLaunch")
        } else {
            return
        }
    }
}
