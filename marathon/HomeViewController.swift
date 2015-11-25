//
//  HomeViewController.swift
//  marathon
//
//  Created by zhenwen on 9/8/15.
//  Copyright © 2015 zhenwen. All rights reserved.
//

import UIKit
import marathonKit
import BubbleTransition
import RealmSwift

class HomeViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var totalKMLabel: UILabel!
    @IBOutlet weak var timesLabel: UILabel!
    @IBOutlet weak var avgPaceLabel: UILabel!
    @IBOutlet weak var totalTimeLabel: UILabel!
    @IBOutlet weak var runningButton: UIButton!
    
    let transition = BubbleTransition()
    var realm: Realm!
    var dataSouce: Results<RunModel>!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        title = "我的马拉松"
        navigationController?.navigationBar.barStyle = .Black
        configureUI()
        self.realm = try! Realm()
        reloadTableViewData()
        
        let barButton = UIBarButtonItem(title: "设置", style: .Plain, target: self, action: "settingTapped:")
        barButton.tintColor = UIColor.whiteColor()
        navigationItem.rightBarButtonItem = barButton
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if #available(iOS 9.0, *) {
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            if let shortcut = appDelegate.launchedShortcutItem as? UIApplicationShortcutItem where shortcut.type == "marathon.run" {
//                appDelegate.handleShortcut(shortcut)
                performSegueWithIdentifier("marathon.run", sender: nil)
                appDelegate.launchedShortcutItem = nil
            }
        }
        // 提醒未设置个人信息
        guard let _ = NSUserDefaults.standardUserDefaults().valueForKey("weight") else {
            let alertController = UIAlertController(title: "先来设置个人基本信息", message: "性别、身高、体重什么的", preferredStyle: .Alert)
            let okAction = UIAlertAction(title: "去设置", style: .Default) { (alert) -> Void in
                self.settingTapped(nil)
            }
            let cancelAction = UIAlertAction(title: "取消", style: .Cancel) { (action) -> Void in}
            alertController.addAction(cancelAction)
            alertController.addAction(okAction)
            presentViewController(alertController, animated: true) { () -> Void in}
            return
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let controller = segue.destinationViewController
        if controller is RunningViewController {
            controller.transitioningDelegate = self
            controller.modalPresentationStyle = .Custom
            (controller as! RunningViewController).delegate = self
        }
    }
    
    func reloadTableViewData() {
        let logs = realm.objects(RunModel).sorted("time", ascending: false)
        reloadTableHeader(logs)
        self.dataSouce = logs
        tableView.reloadData()
    }
    
    func reloadTableHeader(logs: Results<RunModel>) {
        var distance = 0.0, seconds = 0
        for log in logs {
            distance = distance + log.distance
            seconds = seconds + log.total_time
        }
        // 总的距离
        let totalString = stringDistance(distance)
        let attributedStr = NSMutableAttributedString(string: totalString, attributes: [NSFontAttributeName: UIFont.systemFontOfSize(80)])
        attributedStr.appendAttributedString(NSAttributedString(string: "\n总公里数", attributes: [NSForegroundColorAttributeName: UIColor.grayColor(), NSFontAttributeName: UIFont.systemFontOfSize(12)]))
        totalKMLabel.attributedText = attributedStr
        
        let dataAttributes = [NSFontAttributeName: UIFont.boldSystemFontOfSize(18)]
        let descAttributes = [NSForegroundColorAttributeName: UIColor.grayColor(), NSFontAttributeName: UIFont.systemFontOfSize(10)]
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 8
        paragraphStyle.alignment = .Center
        // 次数
        let timesString = String(logs.count)
        let attributedTimesStr = NSMutableAttributedString(string: timesString, attributes: dataAttributes)
        attributedTimesStr.appendAttributedString(NSAttributedString(string: "\n总的跑步次数", attributes: descAttributes))
        attributedTimesStr.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSMakeRange(0, attributedTimesStr.length))
        timesLabel.attributedText = attributedTimesStr
        // 平均速度
        let paceString = stringAvgPace(distance, seconds: seconds)
        let attributedPaceStr = NSMutableAttributedString(string: paceString, attributes: dataAttributes)
        attributedPaceStr.appendAttributedString(NSAttributedString(string: "\n平均速度", attributes: descAttributes))
        attributedPaceStr.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSMakeRange(0, attributedPaceStr.length))
        avgPaceLabel.attributedText = attributedPaceStr
        // 总的时间
        let timeString = stringSecondCount(seconds)
        let attributedTimeStr = NSMutableAttributedString(string: timeString, attributes: dataAttributes)
        attributedTimeStr.appendAttributedString(NSAttributedString(string: "\n总的跑步时间", attributes: descAttributes))
        attributedTimeStr.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSMakeRange(0, attributedTimeStr.length))
        totalTimeLabel.attributedText = attributedTimeStr
    }
    
    func settingTapped(sender: UIBarButtonItem?) {
        let viewController = SettingTableViewController()
        let nav = UINavigationController(rootViewController: viewController)
        nav.navigationBar.barStyle = .Black
        navigationController?.presentViewController(nav, animated: true, completion: {})
    }
}

// MARK: Configure UI
extension HomeViewController {
    
    private func configureUI() {
        
        totalKMLabel.textColor = appNormalColor
        totalKMLabel.numberOfLines = 2
        timesLabel.numberOfLines = 2
        avgPaceLabel.numberOfLines = 2
        totalTimeLabel.numberOfLines = 2
        
        let runningImage = UIImage(named: "running")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        runningButton.setImage(runningImage, forState: .Normal)
        runningButton.backgroundColor = appNormalColor
        runningButton.layer.cornerRadius = runningButton.width/2
        runningButton.tintColor = UIColor.whiteColor()
    }
}


// MARK: UITableViewDataSource & UITableViewDelegate
extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    // UITableViewDataSource
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("postCellId") as! RunCell

        let obj = dataSouce[indexPath.row]
        cell.updateCell(obj)
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSouce.count
    }
    
    // UITableViewDelegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let viewController = RunningViewController().allocWithRouterParams(nil)
        viewController.runModel = dataSouce[indexPath.row]
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "记录"
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let run = dataSouce[indexPath.row]
            try! realm.write({ () -> Void in
                self.realm.delete(run)
            })
            let logs = realm.objects(RunModel).sorted("time", ascending: false)
            reloadTableHeader(logs)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        }
    }
}

// MARK: UIViewControllerTransitioningDelegate
extension HomeViewController: UIViewControllerTransitioningDelegate {
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .Present
        transition.startingPoint = CGPoint(x: runningButton.center.x, y: runningButton.center.y+64)
        transition.bubbleColor = runningButton.backgroundColor!
        return transition
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .Dismiss
        transition.startingPoint = CGPoint(x: runningButton.center.x, y: runningButton.center.y+64)
        transition.bubbleColor = runningButton.backgroundColor!
        return transition
    }
}

// MARK: RunningViewControllerDelegate
extension HomeViewController: RunningViewControllerDelegate {
    func saveDataSuccess(viewController: RunningViewController) {
        reloadTableViewData()
    }
}


