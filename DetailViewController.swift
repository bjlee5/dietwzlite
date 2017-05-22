//
//  DetailViewController.swift
//  Moblzip
//
//  Created by Moblzip, LLC on 27/10/14.
//  Copyright (c) 2014 Moblzip, LLC. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    let GRAPH_HISTORY = 15
    
    @IBOutlet weak var btnMoreHistory: UIButton!
    @IBOutlet weak var graphViw: UIView!
    var barChart: PNBarChart!

    override func viewDidLoad() {
        super.viewDidLoad()

                self.navigationController?.interactivePopGestureRecognizer!.delegate = nil
        
        // Do any additional setup after loading the view.
        btnMoreHistory.layer.cornerRadius = 5
        btnMoreHistory.layer.borderWidth = 0.5
        btnMoreHistory.layer.borderColor = UIColor.darkGray.cgColor //ThemeColors.Teal.CGColor 
//        btnMoreHistory.backgroundColor = UIColor.clearColor()
//        btnMoreHistory.setTitleColor(ThemeColors.Teal, forState: UIControlState.Normal)

        
        configGraph()
        
    }
    
    func configGraph() {
        let rctFrame = graphViw.bounds.insetBy(dx: 8, dy: 8)
        barChart = PNBarChart(frame: rctFrame)
        
        barChart.translatesAutoresizingMaskIntoConstraints = true
        barChart.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
        
        barChart.backgroundColor = UIColor(white: 71/255.0, alpha: 1.0)
        barChart.strokeColor = UIColor(red: 255/255.0, green: 158/255.0, blue: 55/255.0, alpha: 1.0)
        barChart.barBackgroundColor = UIColor(red: 51/255.0, green: 49/255.0, blue: 50/255.0, alpha: 1.0)
        // barChart.labelMarginTop = 5.0
        barChart.chartMargin = 20.0
        barChart.yMaxValue = 30
        barChart.yLabelSum = 3
        
        barChart.yLabelFormatter = ({(yValue: CGFloat) -> NSString in
            let yValueParsed:CGFloat = yValue
            let labelText = String(Int(yValueParsed))
            return labelText as NSString;
        })
        
        
//        var pointsAry: [Double] = []
//
//        let dailyHistory = Utils.sharedInstance.dailyHistory
//        var activeIdx = dailyHistory.count - 1
//        var points = 0
//        
//        for _ in 0...14 {
//            var dailyInfo = dailyHistory[activeIdx]
//            points = dailyInfo.getTotalPoint()
//            activeIdx -= 1;
//            if activeIdx < 0 {
//                pointsAry.insert(Double(points), atIndex: 0)
//                break
//            }
//            if dailyInfo.cycleDay == 2 {
//                dailyInfo = dailyHistory[activeIdx]
//                points += dailyInfo.getTotalPoint()
//                activeIdx -= 1;
//                if activeIdx < 0 {
//                    pointsAry.insert(Double(points), atIndex: 0)
//                    break
//                }
//            }
//            pointsAry.insert(Double(points), atIndex: 0)
//        }
        
    
//        activeIdx -= 1
//        if activeIdx >= 0 && activeIdx%2 == 0 {
//            points += dailyHistory[activeIdx].getTotalPoint()
//            activeIdx -= 1
//        }
//        
//        for _ in 2...GRAPH_HISTORY {
//            if activeIdx < 0 {
//                break
//            }
//            
//            points = dailyHistory[activeIdx].getTotalPoint()
//            activeIdx -= 1
//            points += dailyHistory[activeIdx].getTotalPoint()
//            activeIdx -= 1
//            pointsAry.insert(points, atIndex: 0)
//        }
        
        
        let pointsAry = Utils.sharedInstance.getLast15ChoicePoints()
        
        var labels: [String] = []
        for index in 0 ..< pointsAry.count {
            labels.append("\(index+1)")
        }
        
        barChart.xLabels = labels as NSArray
        barChart.yValues = pointsAry as NSArray
        barChart.barWidth = (rctFrame.size.width - 2 * barChart.chartMargin) / CGFloat(labels.count) - 2
        barChart.strokeChart()
        
        graphViw.addSubview(barChart)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - IBAction
    
    @IBAction func onBack(_ sender: AnyObject) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onInfo(_ sender: AnyObject) {
        let infoView = storyboard?.instantiateViewController(withIdentifier: "InfoViewController") as! InfoViewController
        infoView.infoItem = InfoItem.Data.PointDetail
        navigationController?.pushViewController(infoView, animated: true)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1 + 3 + (Utils.sharedInstance.DEFINED_COUNT-1) + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let FIXED_WIDTH: CGFloat = 140
        if (indexPath as NSIndexPath).item == 0 {
            return CGSize(width: FIXED_WIDTH, height: 27)
        } else {
            return CGSize(width: (collectionView.frame.width - FIXED_WIDTH) / 2.0 - 1, height: 27)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let detailCell = collectionView.dequeueReusableCell(withReuseIdentifier: "DetailCell", for: indexPath) as! DetailCollectionViewCell
        detailCell.configForIndex(indexPath)
        
        return detailCell
    }

}
