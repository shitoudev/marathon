//
//  RunCell.swift
//  marathon
//
//  Created by zhenwen on 9/10/15.
//  Copyright © 2015 zhenwen. All rights reserved.
//

import UIKit
import marathonKit
import FontAwesome_swift

class RunCell: UITableViewCell {
    
    @IBOutlet weak var kmLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var paceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        timeLabel.font = UIFont.fontAwesomeOfSize(13)
        paceLabel.font = UIFont.systemFontOfSize(14)
    }
    
    func updateCell(run: RunModel) {
        let totalString = stringDistance(run.distance)
        let attributedStr = NSMutableAttributedString(string: totalString, attributes: [NSFontAttributeName: UIFont.boldSystemFontOfSize(22)])
        attributedStr.appendAttributedString(NSAttributedString(string: " km", attributes: [NSForegroundColorAttributeName: UIColor.grayColor(), NSFontAttributeName: UIFont.systemFontOfSize(11)]))
        kmLabel.attributedText = attributedStr
        
        let timeString = stringSecondCount(run.total_time)
        timeLabel.text = String.fontAwesomeIconWithName(.ClockO) + " \(timeString)"
        dateLabel.text = run.time.toString(format: DateFormat.Custom("yy/MM/dd HH:mm"))
        paceLabel.text = stringAvgPace(run.distance, seconds: run.total_time) + "/km"
    }
}
