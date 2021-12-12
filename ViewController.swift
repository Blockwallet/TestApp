//
//  ViewController.swift
//  Testapp
//
//  Created by Lucas Karlsson on 2021-12-11.
//  Copyright © 2021 Testapp. All rights reserved.
//

import UIKit
import Alamofire
import ESPullToRefresh
import SDWebImage

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var activitiesTableView: UITableView!
    
    private var nextToDate = Date().onlyDate
    private var haltAtDate: Date? = nil
    private var allactivities: [Activity] = []
    private var userCache: [String:User] = [:]
    private var isLoadingNewActivities = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activitiesTableView.register(UINib(nibName: "ActivitiesTableViewCell", bundle: nil), forCellReuseIdentifier: "ActivitiesTableViewCell")
    }

    override func viewDidAppear(_ animated: Bool) {
        
        activitiesTableView.es.addInfiniteScrolling {
            [unowned self] in
            
            self.loadNewActivities(toDate: self.nextToDate)
        }
        
        loadNewActivities(toDate: nextToDate)
    }
    
    @IBAction func trigger(_ sender: Any) {
        
        if let haltAtDate = haltAtDate, nextToDate >= haltAtDate{
            loadNewActivities(toDate: nextToDate)
        }
    }
    
    func loadNewActivities(toDate:Date){
        
        if !isLoadingNewActivities{
            
            isLoadingNewActivities = true
            
            let baseUrl = "http://qapital-ios-testtask.herokuapp.com/activities"
            let to = toDate.getDateAsFormattedString()
            let fromDate = generateNextFromDate(toDate)
            let from = fromDate.getDateAsFormattedString()
            
            print("Url: \("\(baseUrl)?from=\(from)&to=\(to)")")
            
            AF.request("\(baseUrl)?from=\(from)&to=\(to)").validate().responseDecodable(of: ActivitiesStruct.self) { (response) in
                
                defer { self.isLoadingNewActivities = false }
                
                if let value = response.value {
                    
                    self.nextToDate = self.dateOneDayFromDate(fromDate)
                    self.haltAtDate = value.oldest?.getFormattedDate()
                    
                    if let activities = value.activities{
                        
                        if activities.count > 0{
                            
                            print("activities.count: \(activities.count)")
                            
                            for activity in activities{
                                
                                self.allactivities.append(activity)
                                
                                self.activitiesTableView.insertRows(at: [IndexPath(row: self.allactivities.count - 1, section: 0)], with: .fade)
                            }
                            
                            self.activitiesTableView.es.stopLoadingMore()
                        }
                        else{
                            if let haltAtDate = self.haltAtDate, self.nextToDate >= haltAtDate{
                                self.isLoadingNewActivities = false
                                self.loadNewActivities(toDate: self.nextToDate)
                            }
                            else {
                                // "oldest" date was reached
                                print("oldest date was reached")
                                
                                self.activitiesTableView.es.noticeNoMoreData()
                            }
                        }
                    }
                }
            }
        }
    }
    
    func loadUser(withId id:Int, results:@escaping (_: User)-> Void){
        
        // Check for cached user before load
        if userCache.contains(where: {$0.key == "\(id)"}){
            if let user = userCache["\(id)"]{
                results(user)
            }
        }
        else{
            let baseUrl = "http://qapital-ios-testtask.herokuapp.com/users/"
            
            AF.request("\(baseUrl)\(id)").validate().responseDecodable(of: User.self) { (response) in
                
                if let user = response.value {
                    
                    guard let userID = user.userID else { return }
                    
                    self.userCache.updateValue(user, forKey: "\(userID)")
                    
                    results(user)
                }
            }
        }
    }
    
    private func generateNextFromDate(_ date: Date) -> Date{
        
        let fromDate = dateTwoWeekFromDate(date)
        
        if let haltAtDate = haltAtDate, fromDate < haltAtDate{
            // Return haltAtDate, due to fetched data backtrack limit
            return haltAtDate
        }
        else{
            // Return date two weeks before
            return fromDate
        }
    }
    
    private func dateTwoWeekFromDate(_ date: Date) -> Date{
        var dayComponent    = DateComponents()
        dayComponent.day    = -14
        let theCalendar     = Calendar.current
        let nextDate        = theCalendar.date(byAdding: dayComponent, to: date)
        return nextDate!
    }
    
    private func dateOneDayFromDate(_ date: Date) -> Date{
        var dayComponent    = DateComponents()
        dayComponent.day    = -1
        let theCalendar     = Calendar.current
        let nextDate        = theCalendar.date(byAdding: dayComponent, to: date)
        return nextDate!
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allactivities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ActivitiesTableViewCell", for: indexPath) as! ActivitiesTableViewCell
        
        let row = indexPath.row
        
        if allactivities.count > row{
            
            let activity = allactivities[row]
            
            if let userID = activity.userID{
                
                    
                    loadUser(withId: userID) { (user) in
                        
                        guard let avatarURL = user.avatarURL else { return }
                        
                        cell.userImg.sd_setImage(with: URL(string: avatarURL)) { (img, err, type, url) in }
                    }
            }
            
            let currencyFormatter = NumberFormatter()
            currencyFormatter.numberStyle = .decimal
            currencyFormatter.decimalSeparator = "."
            currencyFormatter.minimumFractionDigits = 2
            
            cell.dateLbl.text = "\(activity.timestamp?.getFormattedDate().getFormattedString() ?? "")"
            
            cell.mainLbl.attributedText = "<style type='text/css'> strong { font-size:14px;color:#000000;}</style><body style='color:#8F96A3;'>\(activity.message ?? "")</body>".htmlToAttributedString
            
            cell.amountLbl.text = "＄\(currencyFormatter.string(from: activity.amount as NSNumber? ?? 0) ?? "")"
        }
        
        return cell
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 44))
        headerView.backgroundColor = .white
        
        let label = UILabel()
        label.frame = CGRect.init(x: 0, y: 12, width: headerView.frame.width-10, height: headerView.frame.height-10)
        label.text = "Activity"
        label.textAlignment = .center
        label.font = UIFont(name: "FunkisQText-SemiBold", size:16)
        
        headerView.addSubview(label)
        
        return headerView
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.row >= allactivities.count - 4 {
            loadNewActivities(toDate: nextToDate)
        }
    }
}

private extension NSNumber {
    func applyDollarFormat() -> String{
        let currencyFormatter = NumberFormatter()
        currencyFormatter.usesGroupingSeparator = true
        currencyFormatter.numberStyle = .currency
        currencyFormatter.locale = Locale.current
        
        return currencyFormatter.string(from: self)!
    }
}

private extension String {
    func getFormattedDate() -> Date{
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        
        let date: Date? = dateFormatter.date(from: self)
        
        return date!.onlyDate
    }
    var htmlToAttributedString: NSMutableAttributedString? {
        guard let data = data(using: .utf8) else { return nil }
        
        var attribStr = NSMutableAttributedString()
        do {
            attribStr = try NSMutableAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
            
            let textRangeForFont : NSRange = NSMakeRange(0, attribStr.length)
            attribStr.addAttributes([NSAttributedString.Key.font : UIFont(name: "FunkisQText-Regular", size:16)!], range: textRangeForFont)
            
            return attribStr
        } catch {
            return nil
        }
    }
}

private extension Date {
    func getFormattedString() -> String{
        
        let relativeDateFormatter = DateFormatter()
        relativeDateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        relativeDateFormatter.timeStyle = .none
        relativeDateFormatter.dateStyle = .medium
        relativeDateFormatter.locale = Locale(identifier: "en_GB")
        relativeDateFormatter.doesRelativeDateFormatting = true
        
        let string: String? = relativeDateFormatter.string(from: self)
        
        return string ?? ""
    }
    func getDateAsFormattedString() -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        
        let string: String = dateFormatter.string(from: self)
        
        return string
    }
    
    var onlyDate: Date {
        get {
            let calender = Calendar.current
            var dateComponents = calender.dateComponents([.year, .month, .day], from: self)
            dateComponents.timeZone = TimeZone(secondsFromGMT: 0)
            return calender.date(from: dateComponents)!
        }
    }
}
