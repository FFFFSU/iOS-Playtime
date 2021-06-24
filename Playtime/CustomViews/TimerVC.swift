//
//  TimerVC.swift
//  NanoChallenge
//
//  Created by Nico Christian on 29/04/21.
//

import UIKit

class TimerVC: UIViewController {

    var totalDuration: Double = -1
    var timeRemaining: Double = 0
    var elapsedTime: Double = 0
    let shapeLayer = CAShapeLayer()
    let trackLayer = CAShapeLayer()
    var timer: Timer!
    var timerIsPaused: Bool = false
    var animationStep: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        notification(scheduled: true)
        timeRemaining = totalDuration
        updateTimeRemainingLabel()
        animationStep = CGFloat(0.8 / totalDuration)
        configureButtons(button: pauseButton, title: "Pause", backgroundColor: UIColor.systemGray, tintColor: UIColor.white)
        configureButtons(button: stopButton, title: "Stop", backgroundColor: primaryRed, tintColor: UIColor.white)
        makeCircle()
        startTimer()
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(enteringBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(enteringForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    let currentLimit = UserDefaults.standard.value(forKey: "currentLimit")
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBAction func pauseButtonTapped(_ sender: UIButton) {
        timerIsPaused.toggle()
        if timerIsPaused == true {
            timer.invalidate()
            configureButtons(button: pauseButton, title: "Resume", backgroundColor: primaryLightBlue, tintColor: primaryNavy)
        } else {
            startTimer()
            configureButtons(button: pauseButton, title: "Pause", backgroundColor: UIColor.systemGray, tintColor: UIColor.white)
        }
    }
    
    @IBAction func stopButtonTapped(_ sender: UIButton) {
        timer.invalidate()
        let alert = UIAlertController(title: "Stop Timer", message: "Are you sure?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {_ in
            self.startTimer()
        })
        let confirmAction = UIAlertAction(title: "Stop", style: .destructive, handler: { _ in
            self.addData()
            self.performSegue(withIdentifier: "TimerToSummary", sender: self)
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        })
        alert.addAction(cancelAction)
        alert.addAction(confirmAction)
        present(alert, animated: true, completion: nil)
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(step), userInfo: nil, repeats: true)
    }
    
    func makeCircle() {
        let center = view.center
        let circularShape = UIBezierPath(arcCenter: center, radius: 160, startAngle: -CGFloat.pi / 2, endAngle: 2 * CGFloat.pi, clockwise: true)
        
        trackLayer.path = circularShape.cgPath
        trackLayer.strokeColor = secondaryNavy.cgColor
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.lineWidth = 8
        trackLayer.strokeEnd = 1
        view.layer.addSublayer(trackLayer)
        
        shapeLayer.path = circularShape.cgPath
        shapeLayer.strokeColor = UIColor.green.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = 8
        shapeLayer.strokeStart = 0
        shapeLayer.strokeEnd = 0.8
        shapeLayer.lineCap = CAShapeLayerLineCap.round
        view.layer.addSublayer(shapeLayer)
    }
    
    @objc func step() {
        if timeRemaining > 0 {
            timeRemaining -= 1
            if timeRemaining > totalDuration * 1 / 3 && timeRemaining < totalDuration * 2 / 3 {
                UIView.animate(withDuration: 1, animations: {
                    self.shapeLayer.strokeColor = primaryOrange.cgColor
                })
            } else if timeRemaining < totalDuration * 1 / 3 {
                UIView.animate(withDuration: 1, animations: {
                    self.shapeLayer.strokeColor = primaryRed.cgColor
                })
            }
            UIView.animate(withDuration: 0.5, animations: {
                self.shapeLayer.strokeEnd = self.shapeLayer.strokeEnd - self.animationStep
            })
            elapsedTime += 1
        } else {
            timer.invalidate()
            notification(scheduled: false)
            let alert = UIAlertController(title: "Time's Up!", message: "Play time’s over! Hope you had fun, now it’s time to take a break and do something productive!", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: { _ in
                self.addData()
                self.performSegue(withIdentifier: "TimerToSummary", sender: self)
            })
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }
        updateTimeRemainingLabel()
    }
    func updateTimeRemainingLabel() {
        durationLabel.text = secondsToString(seconds: timeRemaining, forView: "Timer")
    }
    
    func addData() {
        if elapsedTime == 0 {
            return
        }
        let duration = elapsedTime
        let newPlaytime = PlaytimeDataEntity(context: self.context)
        newPlaytime.datePlayed = Date()
        newPlaytime.duration = duration
        newPlaytime.limit = UserDefaults.standard.value(forKey: "currentLimit") as! Double
        newPlaytime.entryFrom = "Timer"
        do {
            try self.context.save()
        } catch {
            print("failed to save data")
        }
    }
    
    func notification(scheduled: Bool) {
        let content = UNMutableNotificationContent()
        content.title = "Time's Up!"
        content.subtitle = "Hey, your playtime is up!"
        content.sound = UNNotificationSound.default

        // show this notification five seconds from now
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: scheduled ? totalDuration : 1, repeats: false)

        // choose a random identifier
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        // add our notification request
        UNUserNotificationCenter.current().add(request)
    }
    
    
    @objc func enteringBackground() {
        timer.invalidate()
        enteringBackgroundTime = Date()
    }
    @objc func enteringForeground() {
        let backgroundTime = DateInterval(start: enteringBackgroundTime, end: Date()).duration.timeIntervalToSeconds()
        timeRemaining -= backgroundTime
        elapsedTime += backgroundTime
        UIView.animate(withDuration: 0.5, animations: {
            self.shapeLayer.strokeEnd = self.shapeLayer.strokeEnd - self.animationStep * CGFloat(backgroundTime)
        })
        startTimer()
    }
}

extension TimeInterval {
    func timeIntervalToSeconds() -> Double {
        let time = NSInteger(self)
        let seconds = time % 60
        return Double(seconds)
    }
}
