//
//  SettingTableViewController.swift
//  marathon
//
//  Created by zhenwen on 11/25/15.
//  Copyright © 2015 zhenwen. All rights reserved.
//

import UIKit
import Bohr

class SettingTableViewController: BOTableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        let barButton = UIBarButtonItem(title: "完成", style: .Plain, target: self, action: "doneTapped:")
        navigationItem.leftBarButtonItem = barButton
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func setup() {
        super.setup()
        title = "设置"
        addSection(BOTableViewSection(headerTitle: "", handler: { (section) -> Void in
            section.addCell(BOChoiceTableViewCell(title: "性别", key: "gender", handler: { (cell) -> Void in
                let cellOne = cell as! BOChoiceTableViewCell
                cellOne.options = ["未知", "男", "女"]
                cellOne.destinationViewController = GenderTableViewController()
            }))
            section.addCell(BONumberTableViewCell(title: "身高", key: "height", handler: { (cell) -> Void in
                let cellOne = cell as! BONumberTableViewCell
                cellOne.textField.placeholder = "cm"
                cellOne.numberOfDecimals = 3
            }))
            section.addCell(BONumberTableViewCell(title: "体重", key: "weight", handler: { (cell) -> Void in
                let cellOne = cell as! BONumberTableViewCell
                cellOne.textField.placeholder = "kg"
                cellOne.numberOfDecimals = 3
            }))
        }))
    }
    
    func doneTapped(sender: UIBarButtonItem) {
        UIApplication.sharedApplication().keyWindow?.endEditing(true)
        parentViewController?.dismissViewControllerAnimated(true, completion: {})
    }

}
