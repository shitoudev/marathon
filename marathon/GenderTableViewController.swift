//
//  GenderTableViewController.swift
//  marathon
//
//  Created by zhenwen on 11/25/15.
//  Copyright © 2015 zhenwen. All rights reserved.
//

import UIKit
import Bohr

class GenderTableViewController: BOTableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func setup() {
        super.setup()
        
        title = "性别选择"
        addSection(BOTableViewSection(headerTitle: "", handler: { (section) -> Void in
            
            section.addCell(BOOptionTableViewCell(title: "未知", key: "gender", handler: { (cell) -> Void in
                
            }))
            section.addCell(BOOptionTableViewCell(title: "男", key: "gender", handler: { (cell) -> Void in
                
            }))
            section.addCell(BOOptionTableViewCell(title: "女", key: "gender", handler: { (cell) -> Void in
                
            }))
        }))
    }

}
