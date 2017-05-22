//
//  GraphCVCell.swift
//  Moblzip
//
//  Created by Sujit Maharana on 10/25/15.
//  Copyright © 2015 Moblzip LLC. All rights reserved.
//

import UIKit
import Charts

class GraphCVCell: UICollectionViewCell {
    
    @IBOutlet fileprivate weak var lblTitle: UILabel!
    @IBOutlet fileprivate weak var graphView: UIView!
    
    var chartData: DWChartModel? {
        didSet {
//            dlog("\(chartData?.title) is loaded")
            if let chartData = chartData {
                lblTitle.text = chartData.title
                chartData.createGraphWithType(ChartType(rawValue: chartData.chartType)!, graphView: graphView)
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        clipsToBounds = false
    }
    
    override func prepareForReuse() {
        graphView.subviews.forEach { subview in
            subview.removeFromSuperview()
        }
    }
    
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        
//        imageView.transform = CGAffineTransformMakeRotation(degreesToRadians(14))
    }
    
//    func updateParallaxOffset(collectionViewBounds bounds: CGRect) {
//        let center = CGPoint(x: CGRectGetMidX(bounds), y: CGRectGetMidY(bounds))
//        let offsetFromCenter = CGPoint(x: center.x - self.center.x, y: center.y - self.center.y)
//        let maxVerticalOffset = (CGRectGetHeight(bounds) / 2) + (CGRectGetHeight(self.bounds) / 2)
//        let scaleFactor = 40 / maxVerticalOffset
//        parallaxOffset = -offsetFromCenter.y * scaleFactor
//    }
    
    func createGraph() -> UIView {
//        let graph5View = UIView()
//        graph5View.frame.origin.x = 0
//        graph5View.frame.origin.y = 250
        
//        dlog("lblTitle \(lblTitle.text)")
//        dlog("graphView  \(graphView.frame)")
        
        graphView.frame = CGRect(x: graphView.frame.origin.x, y: graphView.frame.origin.y, width: 350, height: graphView.frame.height)
        
        var rctFrame = graphView.bounds.insetBy(dx: 7, dy: 7)
        rctFrame.size.height -= 1
        
//        var newPointsChart = UIView()
        let newPointsChart = ScatterChartView(frame: rctFrame)
//        let newPointsChart = LineChartView(frame: rctFrame)
        
        newPointsChart.translatesAutoresizingMaskIntoConstraints = true
        newPointsChart.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
        newPointsChart.backgroundColor = UIColor.clear
        
        
        newPointsChart.noDataText = "Looks like today is your first day"
//        newPointsChart.noDataTextDescription = ""
        
        
        let dailyHistory = Utils.sharedInstance.dailyHistory
        var activeIdx = dailyHistory.count - 1
        
        var points = dailyHistory[activeIdx].getTotalPoint()
        activeIdx -= 1
        if activeIdx >= 0 && activeIdx%2 == 0 {
            points += dailyHistory[activeIdx].getTotalPoint()
            activeIdx -= 1
        }
        var pointsAry: [Double] = [Double(points)]
        
        for _ in 2...15 {
            if activeIdx < 0 {
                break
            }
            
            points = dailyHistory[activeIdx].getTotalPoint()
            activeIdx -= 1
            points += dailyHistory[activeIdx].getTotalPoint()
            activeIdx -= 1
            pointsAry.insert(Double(points), at: 0)
        }
        
        var labels: [String] = []
        for index in 0 ..< pointsAry.count {
            labels.append("\(index+1)")
        }
        
        var dataEntries: [ChartDataEntry] = []
        
        for i in 0..<pointsAry.count {
            let dataEntry = ChartDataEntry(x: pointsAry[i], y: Double(i))
            if pointsAry[i] > 0.1 {
                dataEntries.append(dataEntry)
            }
        }
        
        let chartDataSet = ScatterChartDataSet(values: dataEntries, label: "Points")
//        chartDataSet.scatterShape = .Circle
        chartDataSet.setScatterShape(.circle)
        
//        let chartData = ScatterChartData(xVals: labels, dataSets: [chartDataSet])
        
        let chartData = ScatterChartData(dataSets: [chartDataSet])
//        chartData.setla
        chartData.highlightEnabled  = false
        chartData.setDrawValues(false)
        
        newPointsChart.data = chartData
        newPointsChart.chartDescription?.text = "Previous 2-day Cycle points - Total Choice Points"
        
        chartDataSet.colors = [UIColor(red: 230/255, green: 126/255, blue: 34/255, alpha: 1)]
        //        chartDataSet.colors = ChartColorTemplates.colorful()
        
        
        newPointsChart.xAxis.labelPosition = .bottom
        let nf = NumberFormatter()
        nf.numberStyle = .none
        newPointsChart.leftAxis.valueFormatter = DefaultAxisValueFormatter(formatter: nf)
        newPointsChart.rightAxis.valueFormatter = DefaultAxisValueFormatter(formatter: nf)
        newPointsChart.notifyDataSetChanged()
        
        graphView.addSubview(newPointsChart)
        return graphView
    }
    
    
    //graph logic
    //There are fixed graphs and user generated graphs
    //Most graphs have a x-axis for last 30 days
    //Except the points chart it is 15 cycles (each cycle is 2 days)
    
    //Fixed Graph
    //1. Weight Chart (lbs & kgs)
    //2. Total Choice Points - Bar Graph (15 days)
    //3. Breakfast Choices (4 lines of scatter chart)
    //4. Lunch Choices (4 lines of scatter chart)
    //5. Dinner Choices (4 lines of scatter chart)
    //6. System defined categories (Fruits, Veggies, Healthy Snacks, Sugary Snacks, Unhealthy Carbs, Sugary Drinks, Alcohol) - Bar Graph
    //7. Exercise - Yes/No chart (2 line scatter chart of 1/2)
    //8. 
    
    
    //usergenerated graphs of three types based on the category type
    //1. Question (yes/no) - Scatter Chart
    //2. Counter (Bar Graph with no decimal places) - there is a upper limit defined
    //3. Numeric (Line Graph - Decimal places upto two places)
    
    
}
