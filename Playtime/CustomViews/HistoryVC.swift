//
//  HistoryVC.swift
//  NanoChallenge
//
//  Created by Nico Christian on 28/04/21.
//

import UIKit

class HistoryVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        fetchPlaytimeData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        fetchPlaytimeData()
    }

    @IBOutlet weak var tableView: UITableView!
    let dataDummy = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    var addDay = 1
    
    var playtimes = PlaytimeData.sharedPlaytimeData
    
    // Core Data
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var playtimeData: [PlaytimeDataEntity]?
    
    func fetchPlaytimeData() {
        do {
            self.playtimeData = try context.fetch(PlaytimeDataEntity.fetchRequest())
            playtimeData?.sort { $0.datePlayed?.compare($1.datePlayed ?? Date()) == .orderedDescending }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } catch {
            print("error")
        }
    }
}

extension HistoryVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playtimeData?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let currentPlaytime = self.playtimeData?[indexPath.row] else { return UITableViewCell() }
        let entryFrom = currentPlaytime.entryFrom
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell") as? CustomCell
        cell?.titleLabel.text = "\(dateToString(date: currentPlaytime.datePlayed ?? Date()))"
        cell?.detailLabel.text = secondsToString(seconds: currentPlaytime.duration, forView: "History")
        cell?.customImage?.image = UIImage(named: entryFrom == "Timer" ? "TableStopwatchIcon" : "TablePencilIcon")
        cell?.customImage.layer.cornerRadius = 8
        
        return cell ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }
    
//    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
//        let action = UIContextualAction(style: .destructive, title: "Delete", handler: { (action, view, completionHandler) in
//            let dataToDelete = self.playtimeData![indexPath.row]
//            self.context.delete(dataToDelete)
//            do {
//
//                try self.context.save()
//            } catch {
//                print("delete failed")
//            }
//            self.fetchPlaytimeData()
//        })
//        return UISwipeActionsConfiguration(actions: [action])
//    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableView.beginUpdates()
            
            let dataToDelete = self.playtimeData![indexPath.row]
            self.playtimeData?.remove(at: indexPath.row)
            self.context.delete(dataToDelete)
            do {
                try self.context.save()
            } catch {
                print("delete failed")
            }
            
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.endUpdates()
        }
    }
}
