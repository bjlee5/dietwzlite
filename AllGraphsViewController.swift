//
//  AllGraphsViewController.swift
//  Moblzip
//
//  Created by Sujit Maharana on 10/25/15.
//  Copyright © 2015 Moblzip LLC. All rights reserved.
//

import UIKit
import Charts

class AllGraphsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    let chartData = DWChartModel.allChartData()
    
    @IBOutlet weak var weightView: UIView!
    @IBOutlet weak var graphCollectionView: UICollectionView!
    
    // MARK: - View Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        graphCollectionView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 350, right: 0)
        let layout = graphCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: graphCollectionView.bounds.width, height: 250)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        drawWeightChart(weightView)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Actions
    
    @IBAction func onClose(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - UICollectionViewDataSource
    
     func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return chartData.count
    }
    
     func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GraphCVCell", for: indexPath) as! GraphCVCell
        cell.chartData = chartData[(indexPath as NSIndexPath).item]
        return cell
    }

    // MARK: - Private
 
    /// Draw the fixed weight chart at top, it is a line graph too.
    fileprivate func drawWeightChart(_ parentView: UIView) {

        parentView.frame = CGRect(x: parentView.frame.origin.x, y: parentView.frame.origin.y, width: 350, height: parentView.frame.height)
        
        var rctFrame = parentView.bounds.insetBy(dx: 15, dy: 15)
        rctFrame.size.height -= 1
        
        let weightChart = LineChartView(frame: rctFrame)
        weightChart.translatesAutoresizingMaskIntoConstraints = true
        weightChart.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
        weightChart.backgroundColor = UIColor.clear
        
        weightChart.noDataText = "Looks like today is your first day"
//        weightChart.noDataTextDescription = ""
        
        let dailyHistory = Utils.sharedInstance.dailyHistory
        var weightAry: [Double] = []
        var weightMax: Double = 0
        var weightMin: Double = 0
        var activeIdx = dailyHistory.count - 1
        var nonZeroWeight: Double = 0
        
        for _ in 1...30 {
            if activeIdx < 0 {
                break
            }
            var weight = dailyHistory[activeIdx].getWeight()
            
            if weight > 0 {
                nonZeroWeight = weight
            } else {
                weight = nonZeroWeight
            }
            
            if weightMin < 0.1 && weight > 0 {
                weightMin = weight
            }
            
            if weight > weightMax {
                weightMax = weight
            } else if weight < weightMin && weight > 0 {
                weightMin = weight
            }
            
            weightAry.insert(weight, at: 0)
            activeIdx -= 1
        }
        
        if weightMin > 1 {
            weightMin = weightMin - 1
        }
        weightMax = weightMax + 1
        
        var labels: [String] = []
        for index in 0 ..< weightAry.count {
            if index%5 == 4 {
                labels.append("\(index+1)")
            } else {
                labels.append("")
            }
        }
        
        var dataEntries: [ChartDataEntry] = []
//        for i in 0..<weightAry.count  {
////            let dataEntry = ChartDataEntry(x: weightAry[i], y: Double(i))
//            let dataEntry = ChartDataEntry(x: Double(i) + 1, y: weightAry[i])
//            if weightAry[i] > 0.1 {
//                dataEntries.append(dataEntry)
//            }
//        }
        var dataEntriesEmpty: [ChartDataEntry] = []
        var y:Double = 0.0
        for i in 0..<30 {
            y = 0.0
            if i < weightAry.count {
                y = weightAry[i]
                dataEntries.append(ChartDataEntry(x: Double(i) + 1, y: y))
            } else {
                dataEntriesEmpty.append(ChartDataEntry(x: Double(i) + 1, y: y))
            }
        }
        
        let chartDataSet = LineChartDataSet(values: dataEntries, label: "Weight")
//        chartDataSet.drawCirclesEnabled = false
        
        let chartDataSetEmpty = LineChartDataSet(values: dataEntriesEmpty, label: "WeightZero")
        chartDataSetEmpty.drawCirclesEnabled = false

        
//        #swift30changes removed xVals
//        let chartData = LineChartData(xVals: labels, dataSets: [chartDataSet])
        let chartData = LineChartData(dataSets: [chartDataSet, chartDataSetEmpty])
        chartData.setDrawValues(false)
        chartData.highlightEnabled  = false
        
        weightChart.data = chartData
        weightChart.chartDescription?.text = "Weight for last 30 days"
        
        chartDataSet.colors = [UIColor(red: 230/255, green: 126/255, blue: 34/255, alpha: 1)]
        chartDataSet.lineWidth = 3.0
        
        chartDataSet.circleColors = [UIColor(red: 230/255, green: 126/255, blue: 34/255, alpha: 1)]
        chartDataSet.circleRadius = 3.0
        
        weightChart.xAxis.labelPosition = .bottom
        weightChart.legend.enabled = false
        weightChart.xAxis.axisMinimum = 0
        
        let nf = NumberFormatter()
        nf.numberStyle = .none
        weightChart.leftAxis.valueFormatter = DefaultAxisValueFormatter(formatter: nf)
        weightChart.leftAxis.axisMinimum = weightMin - 5
        weightChart.leftAxis.axisMaximum = weightMax + 5
        weightChart.rightAxis.valueFormatter = DefaultAxisValueFormatter(formatter: nf)
        weightChart.rightAxis.axisMinimum = weightMin - 5
        weightChart.rightAxis.axisMaximum = weightMax + 5
        
        parentView.addSubview(weightChart)
    }
}
