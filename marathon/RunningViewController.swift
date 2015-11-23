//
//  RunningViewController.swift
//  marathon
//
//  Created by zhenwen on 9/11/15.
//  Copyright © 2015 zhenwen. All rights reserved.
//

import UIKit
import MapKit
import marathonKit
import RealmSwift

protocol RunningViewControllerDelegate: NSObjectProtocol {
    func saveDataSuccess(viewController: RunningViewController)
}

class RunningViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var paceLabel: UILabel!
    @IBOutlet weak var calLabel: UILabel!
    
    weak var delegate: RunningViewControllerDelegate?
    
    let dataAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont.boldSystemFontOfSize(18)]
    let descAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont.systemFontOfSize(10)]
    var paragraphStyle: NSMutableParagraphStyle {
        get {
            let style = NSMutableParagraphStyle()
            style.lineSpacing = 8
            style.alignment = .Center
            return style
        }
    }

    var locationManager: CLLocationManager!
    var isRunning = false, isPause = false, isStop = false
    
    var seconds = 0 {
        didSet {
            let timeString = stringSecondCount(seconds)
            let attributedTimesStr = NSMutableAttributedString(string: timeString, attributes: dataAttributes)
            attributedTimesStr.appendAttributedString(NSAttributedString(string: "\n时间", attributes: descAttributes))
            attributedTimesStr.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSMakeRange(0, attributedTimesStr.length))
            timeLabel.attributedText = attributedTimesStr
        }
    }
    var distance = 0.0 {
        didSet {
            let totalString = stringDistance(distance)
            let attributedStr = NSMutableAttributedString(string: totalString, attributes: [NSFontAttributeName: UIFont.systemFontOfSize(80)])
            attributedStr.appendAttributedString(NSAttributedString(string: "\n公里数", attributes: [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont.systemFontOfSize(12)]))
            distanceLabel.attributedText = attributedStr
        }
    }
    var cal = 0 {
        didSet {
            let calString = "\(cal)"
            let attributedCalStr = NSMutableAttributedString(string: calString, attributes: dataAttributes)
            attributedCalStr.appendAttributedString(NSAttributedString(string: "\n消耗的大卡", attributes: descAttributes))
            attributedCalStr.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSMakeRange(0, attributedCalStr.length))
            calLabel.attributedText = attributedCalStr
        }
    }
    var avgPace = 0.0 {
        didSet {
            let paceString = "\(avgPace)"// stringAvgPace(distance, seconds: seconds)
            let attributedPaceStr = NSMutableAttributedString(string: paceString, attributes: dataAttributes)
            attributedPaceStr.appendAttributedString(NSAttributedString(string: "\n平均速度", attributes: descAttributes))
            attributedPaceStr.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSMakeRange(0, attributedPaceStr.length))
            paceLabel.attributedText = attributedPaceStr
        }
    }
    
    var runModel: RunModel?
    
    var locations: [CLLocation] = [], timer: NSTimer?
    var currentLocation: CLLocation?
    var beginTime: NSDate?
    
    //args: NSDictionary
    func allocWithRouterParams(args: NSDictionary?) -> RunningViewController {
        
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("runningViewController") as! RunningViewController
        return viewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        title = "跑跑跑"
        setNeedsStatusBarAppearanceUpdate()
        configureUI()
        self.seconds = 0
        self.distance = 0.0
        self.cal = 0
        self.avgPace = 0.0
        
        mapView.showsUserLocation = true
        mapView.delegate = self
        
        if let run = runModel {
            leftButton.hidden = true; rightButton.hidden = true
            self.avgPace = (stringAvgPace(run.distance, seconds: run.total_time) as NSString).doubleValue
            self.cal = Int(getCalByMeter(run.distance))
            self.distance = run.distance
            self.seconds = run.total_time
            
            if run.locations.count > 0 {
                var coordinate2dS = run.locations.map {CLLocation(latitude: $0.latitude, longitude: $0.longitude).locationMarsFromEarth().coordinate}
                let line = MKPolyline(coordinates: &coordinate2dS, count: run.locations.count)
                if mapView.overlays.count > 0 {
                    mapView.removeOverlays(mapView.overlays)
                }
                mapView.addOverlay(line)
                
                // 起点
                let firstLocation = run.locations.first!
                let annotation = RunAnnotation()
                annotation.title = "起点"
                annotation.coordinate = CLLocation(latitude: firstLocation.latitude, longitude: firstLocation.longitude).locationMarsFromEarth().coordinate
                annotation.idString = "起点"
                mapView.addAnnotation(annotation)
                // 终点
                let lastLocation = run.locations.last!
                let annotation2 = RunAnnotation()
                annotation2.title = "终点"
                annotation2.coordinate = CLLocation(latitude: lastLocation.latitude, longitude: lastLocation.longitude).locationMarsFromEarth().coordinate
                annotation2.idString = "终点"
                mapView.addAnnotation(annotation2)
                
                let locationArr = run.locations.map {CLLocation(latitude: $0.latitude, longitude: $0.longitude).locationMarsFromEarth()!}
                let region = mapRegion(locationArr)
                mapView.regionThatFits(region)
                mapView.setRegion(region, animated: true)
            }
            
            return
        }
        
        self.locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10
        if #available(iOS 9.0, *) {
            locationManager.allowsBackgroundLocationUpdates = true
        }
//        locationManager.headingFilter
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestAlwaysAuthorization()
        } else {
            print("设备关闭了定位服务")
            
            let alertController = UIAlertController(
                title: "定位服务未开启",
                message: "如果不开启定位服务App将无法使用，请开启定位服务",
                preferredStyle: .Alert)
            
            let cancelAction = UIAlertAction(title: "取消", style: .Cancel, handler: nil)
            alertController.addAction(cancelAction)
            
            let openAction = UIAlertAction(title: "去开启", style: .Default) { (action) in
                if let url = NSURL(string:UIApplicationOpenSettingsURLString) {
                    UIApplication.sharedApplication().openURL(url)
                }
            }
            alertController.addAction(openAction)
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        for annotation in mapView.annotations {
            if (annotation as! RunAnnotation).idString == "起点" {
                mapView.selectAnnotation(annotation, animated: true)
                break
            }
        }
    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        if locationManager != nil {
            locationManager.stopUpdatingLocation()
        }
    }
    
    func eachSecond() {
        self.seconds++
//        self.distance += Double(randomInRange(1...4))
        self.avgPace = (stringAvgPace(distance, seconds: seconds) as NSString).doubleValue
        self.cal = Int(getCalByMeter(distance))

        if locations.count > 0 {
            var coordinate2dS = locations.map {$0.locationMarsFromEarth().coordinate}
            let line = MKPolyline(coordinates: &coordinate2dS, count: locations.count)
            if mapView.overlays.count > 0 {
                mapView.removeOverlays(mapView.overlays)
            }
            mapView.addOverlay(line)
        }
    }
    
    func randomInRange(range: Range<Int>) -> Int {
        let count = UInt32(range.endIndex - range.startIndex)
        return  Int(arc4random_uniform(count)) + range.startIndex
    }
}

// MARK: Button Tapped
extension RunningViewController {
    func leftButtonTapped(sender: AnyObject) {
        if isStop {
            // 保存数据
            let realm = try! Realm()
            let run = RunModel()
            run.run_id = Int(NSDate(timeIntervalSinceNow: 0).timeIntervalSince1970)
            run.distance = distance
            run.time = beginTime!
            run.total_time = seconds
            run.cal = cal
            
            for location in locations {
                let locationModel = LocationModel()
                locationModel.latitude = location.coordinate.latitude
                locationModel.longitude = location.coordinate.longitude
                run.locations.append(locationModel)
            }
            
            try! realm.write { () -> Void in
                realm.add(run)
                self.isStop = false
                self.leftButton.enabled = false
                self.leftButton.setTitle("Start", forState: .Normal)
                if (self.delegate?.respondsToSelector("saveDataSuccess:") != nil) {
                    self.delegate?.saveDataSuccess(self)
                }
                self.dismissViewControllerAnimated(true, completion: nil)
            }
            
            return
        }
        
        if isRunning && !isPause {
            isPause = true
            leftButton.setTitle("继续", forState: .Normal)
            // 暂停
            timer!.fireDate = NSDate.distantFuture()
            
        } else if isRunning && isPause {
            isPause = false
            leftButton.setTitle("暂停", forState: .Normal)
            
            timer!.fireDate = NSDate.distantPast()
        } else {
            isRunning = true
            leftButton.setTitle("暂停", forState: .Normal)
            rightButton.setTitle("结束", forState: .Normal)
            rightButton.backgroundColor = UIColor(hex: "#f2546e")
            self.beginTime = NSDate()
            
            // add annotation
            if let firstLocation = currentLocation?.coordinate {
                let annotation = RunAnnotation()
                annotation.title = "起点"
                annotation.coordinate = CLLocation(latitude: firstLocation.latitude, longitude: firstLocation.longitude).locationMarsFromEarth().coordinate
                annotation.idString = "起点"
                mapView.addAnnotation(annotation)
            }
            // 刷新
            mapView.showsUserLocation = false
            mapView.showsUserLocation = true
            
            self.timer = NSTimer(timeInterval: 1, target: self, selector: "eachSecond", userInfo: nil, repeats: true)
            NSRunLoop.mainRunLoop().addTimer(timer!, forMode: NSRunLoopCommonModes)
        }
    }
    func rightButtonTapped(sender: AnyObject) {
        
        if isRunning {
            isRunning = false
            isPause = false
            isStop = true
            rightButton.setTitle("取消", forState: .Normal)
            rightButton.backgroundColor = appNormalColor
            
            leftButton.setTitle("保存", forState: .Normal)
            timer?.invalidate()
            self.timer = nil
        } else {
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
}

// MARK: Configure UI
extension RunningViewController {
    
    private func configureUI() {
        
        distanceLabel.superview?.backgroundColor = appNormalColor
        distanceLabel.textColor = UIColor.whiteColor()
        distanceLabel.numberOfLines = 2
        timeLabel.numberOfLines = 2
        calLabel.numberOfLines = 2
        paceLabel.numberOfLines = 2

        leftButton.backgroundColor = appNormalColor
        leftButton.layer.cornerRadius = leftButton.width/2
        leftButton.addTarget(self, action: "leftButtonTapped:", forControlEvents: .TouchUpInside)
        leftButton.setTitle("开始", forState: .Normal)
        leftButton.titleLabel?.font = UIFont.systemFontOfSize(14)
        
        rightButton.backgroundColor = appNormalColor
        rightButton.layer.cornerRadius = rightButton.width/2
        rightButton.addTarget(self, action: "rightButtonTapped:", forControlEvents: .TouchUpInside)
        rightButton.setTitle("取消", forState: .Normal)
        rightButton.titleLabel?.font = leftButton.titleLabel?.font
    }
}

// MARK: CLLocationManagerDelegate
extension RunningViewController: CLLocationManagerDelegate {
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        print("status = \(status.rawValue)")
        if status == .AuthorizedAlways {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {

    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.currentLocation = locations.last?.locationMarsFromEarth()
        let region = MKCoordinateRegionMakeWithDistance((currentLocation?.coordinate)!, 1000, 1000)
        mapView.regionThatFits(region)
        mapView.setRegion(region, animated: true)
        print("locations = \(locations), 经度 = \(locations.last?.coordinate.latitude), 纬度 = \(locations.last?.coordinate.longitude), 高度 = \(locations.last?.altitude)")
        
        for one in locations {
            if one.horizontalAccuracy < 20 && isRunning && !isPause {
//                print("one = \(one)")
                if self.locations.count > 0 {
                    //TODO: 需要处理暂停之后，移动一段距离的情况，这个距离不能再计算进来
                    self.distance += one.distanceFromLocation(self.locations.last!)
                }
//                print("self.distance = \(self.distance)")
                self.locations.append(one)
            }
        }
    }
}

// MARK: MKMapViewDelegate
extension RunningViewController: MKMapViewDelegate {
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let polylineRenderer = MKPolylineRenderer(overlay: overlay)
            polylineRenderer.strokeColor = appNormalColor
            polylineRenderer.lineWidth = 5
            
            return polylineRenderer
        }
        return MKPolylineRenderer()
    }
    
    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
//        print("mapView 经度 = \(userLocation.coordinate.latitude), 纬度 = \(userLocation.coordinate.longitude)")
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if (annotation.isKindOfClass(MKUserLocation) && runModel == nil) || annotation.isKindOfClass(RunAnnotation) {
            let reusableId = "annoViewID"
            var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(reusableId)
            if annotationView == nil {
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: reusableId)
                annotationView?.canShowCallout = true
            }
            var imageString = "PinGreen"
            if annotation.isKindOfClass(MKUserLocation) && isRunning {
                imageString = "PinRed"
            } else if annotation.isKindOfClass(RunAnnotation) {
                imageString = (annotation as! RunAnnotation).idString == "起点" ? "PinGreen" : "PinRed"
            }
            let image = UIImage(named: imageString)
            annotationView?.annotation = annotation
            annotationView?.image = image
            annotationView?.centerOffset = CGPoint(x: 0, y: -image!.size.height / 2)
            
            return annotationView
        }
        return nil
    }
}
