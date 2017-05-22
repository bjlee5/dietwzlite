//
//  DWChartModel.swift
//  Moblzip
//
//  Created by Sujit Maharana on 10/25/15.
//  Copyright © 2015 Moblzip LLC. All rights reserved.
//

import UIKit
import Charts

class DWChartModel {
    
    var title: String
    var plotZeroValues = false
    var chartType: String
    var category: CategoryInfo?
    var descriptionText: String
    var noDataText: String
    var mealType: MealType
    
    // MARK: - Init
    
    init(chartType: ChartType, cat: CategoryInfo?, title: String, descriptionText: String, noDataText: String) {
        self.title = title
        self.chartType = chartType.rawValue
        self.category = cat
        self.descriptionText = descriptionText
        self.noDataText = noDataText
        self.mealType = .Breakfast
    }
    
    // MARK: - Utility
    
    func createGraphWithType(_ chartType: ChartType, graphView: UIView) {
        
        switch chartType {
        case .Bar:
            createBarGraph(graphView)
        case .Line:
            createLineGraph(graphView)
        case .Scatter:
            createScatterGraph(graphView)
        case .ChoicePoints:
            createPointChart(graphView)
        case .MealChoices:
            createMealChoiceGraph(graphView)
        }
    }
    
    // MARK: - Class Functions
    
    class func allChartData() -> [DWChartModel] {
        
        var chartDatas = [DWChartModel]()
        
        let cd1 = DWChartModel(chartType: .ChoicePoints, cat: nil, title: "Choice Points", descriptionText: "Previous 2-day Cycle points - Total Choice Points", noDataText: "")
        chartDatas.append(cd1)
        
        for meal in MealType.allValues {
            let cd = DWChartModel(chartType: .MealChoices, cat: nil, title: "\(meal.rawValue) Choices", descriptionText: "Previous 30 days - \(meal.rawValue) Choices", noDataText: "")
            cd.mealType = meal
            chartDatas.append(cd)
        }
        
        for cat in Utils.sharedInstance.categoryAry {
            
            if let chartType = cat.mode.chartType {
                chartDatas.append(DWChartModel(chartType: chartType, cat: cat, title: cat.label, descriptionText: cat.label, noDataText: "No \(cat.label) data"))
            }
        }
        
        return chartDatas
    }
    
    // MARK: - Private
    
    //to do: Rendering of views should happen in the view "GraphCVCell" move it there, the problem being moving the data.
    
    //Create a Scatter graph and add it to the parent view passed.
    //this graph is for yes/no question
    //it is for breakfast/lunch/dinner view too.
    
    fileprivate func createScatterGraph(_ parentView: UIView) {
        
        let scatterChart = ScatterChartView(frame: getRectFrame(parentView))
        
        scatterChart.translatesAutoresizingMaskIntoConstraints = true
        scatterChart.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
        scatterChart.backgroundColor = UIColor.clear
        scatterChart.legend.enabled = false
        scatterChart.xAxis.labelPosition = .bottom
        scatterChart.xAxis.axisMinimum = 0
//
        let nf = YesNoValueFormatter.sharedInstance
        scatterChart.leftAxis.valueFormatter = DefaultAxisValueFormatter(formatter: nf)
        scatterChart.rightAxis.valueFormatter = DefaultAxisValueFormatter(formatter: nf)
        scatterChart.noDataText = noDataText //"Looks like today is your first day"
//        scatterChart.noDataTextDescription = ""
        scatterChart.chartDescription?.text = descriptionText //"Previous 2-day Cycle points - Total Choice Points"
        scatterChart.fitScreen()
//        scatterChart.fi
        
        let xLabelCount = 30
        let dataEntries: [ChartDataEntry]   = getScatterChartDataEntries(xLabelCount, cat: self.category!)
//        let labels: [String]                = DWChartModel.getLabels(xLabelCount)
        let chartDataSet                    = ScatterChartDataSet(values: dataEntries, label: title)
//        let chartData                       = ScatterChartData(xVals: labels, dataSets: [chartDataSet])
        let chartData                       = ScatterChartData(dataSets: [chartDataSet])
        
        chartDataSet.colors         = [UIColor(red: 230/255, green: 126/255, blue: 34/255, alpha: 1)]
//        chartDataSet.scatterShape   = .Circle
        chartDataSet.setScatterShape(.circle)
        chartDataSet.scatterShapeSize = 7.0
        chartData.highlightEnabled  = false
        chartData.setDrawValues(false)

        
        scatterChart.data = chartData
        parentView.addSubview(scatterChart)
        
        if scatterChart.data != nil {
            scatterChart.leftAxis.axisMinimum = -1.0
            scatterChart.leftAxis.axisMaximum = scatterChart.data!.yMax + 1.0
            scatterChart.leftAxis.labelCount = Int(scatterChart.leftAxis.axisMaximum - scatterChart.leftAxis.axisMinimum)
            scatterChart.rightAxis.enabled = false
        }
        
        scatterChart.notifyDataSetChanged()
    }
    
    
    //Create a Scatter graph and add it to the parent view passed.
    //this graph is for yes/no question
    //it is for breakfast/lunch/dinner view too.
    
    fileprivate func createMealChoiceGraph(_ parentView: UIView) {
        
        let scatterChart = ScatterChartView(frame: getRectFrame(parentView))
        
        scatterChart.translatesAutoresizingMaskIntoConstraints = true
        scatterChart.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
        scatterChart.backgroundColor = UIColor.clear
        scatterChart.legend.enabled = false
        scatterChart.xAxis.labelPosition = .bottom
        scatterChart.xAxis.axisMinimum = 0
        //
        let nf = ChoiceValueFormatter.sharedInstance
        scatterChart.leftAxis.valueFormatter = DefaultAxisValueFormatter(formatter: nf)
        scatterChart.noDataText = noDataText //"Looks like today is your first day"
//        scatterChart.noDataTextDescription = ""
        scatterChart.chartDescription?.text = descriptionText //"Previous 2-day Cycle points - Total Choice Points"
        
        let xLabelCount = 30
        let dataEntries: [ChartDataEntry]   = getMealChoiceChartDataEntries(xLabelCount, meal: self.mealType)
//        let labels: [String]                = DWChartModel.getLabels(xLabelCount)
        let chartDataSet                    = ScatterChartDataSet(values: dataEntries, label: title)
//        let chartData                       = ScatterChartData(xVals: labels, dataSets: [chartDataSet])
        let chartData                       = ScatterChartData(dataSets: [chartDataSet])
        
        chartDataSet.colors         = [UIColor(red: 230/255, green: 126/255, blue: 34/255, alpha: 1)]
//        chartDataSet.scatterShape   = .Circle
        chartDataSet.setScatterShape(.circle)
        chartDataSet.scatterShapeSize = 7.0
        chartData.highlightEnabled  = false
        chartData.setDrawValues(false)
        
        scatterChart.data = chartData
        parentView.addSubview(scatterChart)
        
        if scatterChart.data != nil {
//            scatterChart.leftAxis.customAxisMin = -1.0 //scatterChart.data!.yMin - 1.0 //max(0.0, scatterChart.data!.yMin - 1.0)
//            scatterChart.leftAxis.customAxisMax = 4.0 //scatterChart.data!.yMax + 1.0 //min(10.0, scatterChart.data!.yMax + 1.0)
//            scatterChart.leftAxis.labelCount = Int(scatterChart.leftAxis.customAxisMax - scatterChart.leftAxis.customAxisMin)

            scatterChart.leftAxis.axisMinimum = -1.0 //scatterChart.data!.yMin - 1.0 //max(0.0, scatterChart.data!.yMin - 1.0)
            scatterChart.leftAxis.axisMaximum = 4.0 //scatterChart.data!.yMax + 1.0 //min(10.0, scatterChart.data!.yMax + 1.0)
            scatterChart.leftAxis.labelCount = Int(scatterChart.leftAxis.axisMaximum - scatterChart.leftAxis.axisMinimum)

//            scatterChart.leftAxis.startAtZeroEnabled = false
            scatterChart.rightAxis.enabled = false
        }
        
        scatterChart.notifyDataSetChanged()
    }

    
    //Create a Line graph and add it to the parent view passed.
    //this graph is for numeric values, i.e, decimal places upto two places
    fileprivate func createLineGraph(_ parentView: UIView) {
//    func createLineGraph(parentView: UIView, cat: CategoryInfo, title: String, descriptionText: String, noDataText: String) {
//        parentView.frame = CGRectMake(parentView.frame.origin.x, parentView.frame.origin.y, 350, parentView.frame.height)
//        
//        var rctFrame = CGRectInset(parentView.bounds, 7, 7)
//        rctFrame.size.height -= 1
//        
        let lineChart = LineChartView(frame: getRectFrame(parentView))
        
        lineChart.translatesAutoresizingMaskIntoConstraints = true
        lineChart.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
        lineChart.backgroundColor = UIColor.clear
//        lineChart.highlightEnabled = false
        lineChart.legend.enabled = false
        lineChart.xAxis.labelPosition = .bottom
        
//        lineChart.leftAxis.startAtZeroEnabled = false
//        lineChart.rightAxis.startAtZeroEnabled = false
        
        let nf = NumberFormatter()
        nf.numberStyle = .decimal
//        nf.usesSignificantDigits = true
        nf.maximumFractionDigits = (self.category?.point)!
        
//        dlog("Point - \((self.category?.point)!)")
//        dlog("Line nf - \(nf)")
        
        lineChart.leftAxis.valueFormatter = DefaultAxisValueFormatter(formatter: nf)
//        lineChart.rightAxis.valueFormatter = nf
        
        
        lineChart.noDataText = noDataText //"Looks like today is your first day"
//        lineChart.noDataTextDescription = ""
        lineChart.chartDescription?.text = descriptionText //"Previous 2-day Cycle points - Total Choice Points"
        
        let xLabelCount = 30
        let dataEntries: [ChartDataEntry]   = getChartDataEntries(xLabelCount, cat: self.category!)
//        let labels: [String]                = DWChartModel.getLabels(xLabelCount)
        let chartDataSet                    = LineChartDataSet(values: dataEntries, label: title)
//        let chartData                       = LineChartData(xVals: labels, dataSets: [chartDataSet])
        let chartData                       = LineChartData(dataSets: [chartDataSet])
        
        chartDataSet.colors         = [UIColor(red: 230/255, green: 126/255, blue: 34/255, alpha: 1)]
        chartDataSet.lineWidth      = 0.5
        chartData.highlightEnabled  = false
        chartData.setDrawValues(false)
        
        lineChart.data = chartData
        parentView.addSubview(lineChart)
        
        if lineChart.data != nil {
//            lineChart.leftAxis.customAxisMin = 0 //max(0.0, lineChart.data!.yMin - 1.0)
//            lineChart.leftAxis.customAxisMax =  Double((self.category?.limit)!)  //min(10.0, lineChart.data!.yMax + 1.0)
//            lineChart.leftAxis.customAxisMax = max(abs(Double((self.category?.limit)!)), lineChart.data!.yMax)
//            lineChart.leftAxis.labelCount = Int(lineChart.leftAxis.customAxisMax - lineChart.leftAxis.customAxisMin)
//            lineChart.leftAxis.startAtZeroEnabled = false
            
            lineChart.leftAxis.axisMinimum = 0 //max(0.0, lineChart.data!.yMin - 1.0)
            lineChart.leftAxis.axisMaximum = max(abs(Double((self.category?.limit)!)), lineChart.data!.yMax)
            lineChart.rightAxis.enabled = false
        }
        
        lineChart.notifyDataSetChanged()

        
    }
    
    //Create a Bar graph and add it to the parent view passed.
    //this graph is for counters or numbers without decimal places
    //it is for graphs with no decimal places.
    fileprivate func createBarGraph(_ parentView: UIView) {
//    func createBarGraph(parentView: UIView, cat: CategoryInfo, title: String, descriptionText: String, noDataText: String) {
        
//        parentView.frame = CGRectMake(parentView.frame.origin.x, parentView.frame.origin.y, 350, parentView.frame.height)
//        
//        
//        var rctFrame = CGRectInset(parentView.bounds, 7, 7)
//        rctFrame.size.height -= 1

        
        let barChart = BarChartView(frame: getRectFrame(parentView))
        
        barChart.translatesAutoresizingMaskIntoConstraints = true
        barChart.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
        barChart.backgroundColor = UIColor.clear
//        barChart.highlightEnabled = false
        barChart.legend.enabled = false
        barChart.xAxis.labelPosition = .bottom
//        barChart.xAxis.axisMinimum = 0
        barChart.fitBars = true
//        barChart.xAxis.avoidFirstLastClippingEnabled = true
//        barChart.leftAxis.startAtZeroEnabled = false
//        barChart.rightAxis.startAtZeroEnabled = false
        
        let nf = NumberFormatter()
        nf.numberStyle = .none
        barChart.leftAxis.valueFormatter = DefaultAxisValueFormatter(formatter: nf)
//        barChart.rightAxis.valueFormatter = DefaultAxisValueFormatter(formatter: nf)
        
        
        barChart.noDataText = noDataText //"Looks like today is your first day"
//        barChart.noDataTextDescription = ""
        barChart.chartDescription?.text = descriptionText //"Previous 2-day Cycle points - Total Choice Points"
        
        let xLabelCount = 30
        let dataEntries: [ChartDataEntry]   = getBarChartDataEntries(xLabelCount, cat: self.category!)
//        let labels: [String]                = DWChartModel.getLabels(xLabelCount)
        let chartDataSet                    = BarChartDataSet(values: dataEntries, label: title)
//        let chartData                       = BarChartData(xVals: labels, dataSets: [chartDataSet])
        let chartData                       = BarChartData(dataSets: [chartDataSet])
        
        chartDataSet.colors         = [UIColor(red: 230/255, green: 126/255, blue: 34/255, alpha: 1)]
        // swift30changes check groupbars in chartdataset
//        chartDataSet.barSpace       = 0.1
        chartData.highlightEnabled  = false
        chartData.setDrawValues(false)
        
        
        barChart.data = chartData
        
        parentView.addSubview(barChart)
        
        if barChart.data != nil {
            barChart.leftAxis.axisMinimum = 0 //max(0.0, barChart.data!.yMin - 1.0)
            barChart.leftAxis.axisMaximum = max(abs(Double((self.category?.limit)!)), barChart.data!.yMax)  //min(10.0, barChart.data!.yMax + 1.0)
            barChart.leftAxis.labelCount = Int(barChart.leftAxis.axisMinimum - barChart.leftAxis.axisMaximum)
            barChart.rightAxis.enabled = false
        }
        barChart.notifyDataSetChanged()

    }

    //Create a Bar graph and add it to the parent view passed.
    //this graph is for counters or numbers without decimal places
    //it is for graphs with no decimal places.
    fileprivate func createPointChart(_ parentView: UIView) {
        //    func createBarGraph(parentView: UIView, cat: CategoryInfo, title: String, descriptionText: String, noDataText: String) {
        
        
        let barChart = BarChartView(frame: getRectFrame(parentView))
        
        barChart.translatesAutoresizingMaskIntoConstraints = true
        barChart.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
        barChart.backgroundColor = UIColor.clear
        barChart.legend.enabled = false
        barChart.xAxis.labelPosition = .bottom
        barChart.fitBars = true
//        barChart.xAxis.axisMinimum = 1
//        barChart.xAxis.avoidFirstLastClippingEnabled = true
//        barChart.leftAxis.startAtZeroEnabled = false
//        barChart.rightAxis.startAtZeroEnabled = false
        
        let nf = NumberFormatter()
        nf.numberStyle = .none
        barChart.leftAxis.valueFormatter = DefaultAxisValueFormatter(formatter: nf)
        
//        barChart.rightAxis.valueFormatter = DefaultAxisValueFormatter(formatter: nf)
        
        
        barChart.noDataText = noDataText //"Looks like today is your first day"
//        barChart.noDataTextDescription = ""
        barChart.chartDescription?.text = descriptionText //"Previous 2-day Cycle points - Total Choice Points"
        
        let xLabelCount = 15
        let dataEntries: [ChartDataEntry]   = getChoicePointsChartDataEntries(xLabelCount)
//        let labels: [String]                = DWChartModel.getLabels(xLabelCount)
        let chartDataSet                    = BarChartDataSet(values: dataEntries, label: title)
//        let chartData                       = BarChartData(xVals: labels, dataSets: [chartDataSet])
        let chartData                       = BarChartData(dataSets: [chartDataSet])
        
        chartDataSet.colors         = [UIColor(red: 230/255, green: 126/255, blue: 34/255, alpha: 1)]
        // #swift30changes see bargroup method for barspace
//        chartDataSet.barSpace       = 0.1
        chartData.highlightEnabled  = false
        //        chartDataSet.scatterShape   = .Circle
        chartData.setDrawValues(false)
        
        barChart.data = chartData
        parentView.addSubview(barChart)
        
        if barChart.data != nil {
            barChart.leftAxis.axisMinimum = 0 //max(0.0, barChart.data!.yMin - 1.0)
            barChart.leftAxis.axisMaximum = 31 //min(10.0, barChart.data!.yMax + 1.0)
            barChart.leftAxis.labelCount = 5 //Int(barChart.leftAxis.customAxisMax - barChart.leftAxis.customAxisMin)
//            barChart.leftAxis.startAtZeroEnabled = false
            barChart.rightAxis.enabled = false
        }
        
        barChart.notifyDataSetChanged()
        
    }
    
    //GET the frame rectangle to draw the graph
    fileprivate func getRectFrame(_ parentView: UIView) -> CGRect {
        parentView.frame = CGRect(x: parentView.frame.origin.x, y: parentView.frame.origin.y, width: 350, height: parentView.frame.height)
        
        var rctFrame = parentView.bounds.insetBy(dx: 15, dy: 15)
        rctFrame.size.height -= 1
        return rctFrame
    }

    
    //get line chart data entries for a given category and count of last n days
    func getChartDataEntries(_ count: Int, cat: CategoryInfo) -> [ChartDataEntry] {
        var dataEntries: [ChartDataEntry] = []
        var valAry: [Double] =  getChartDataEntriesByCategory(count, cat: cat)
        var y:Double = 0.0
        for i in 0..<count {
            if i < valAry.count {
                y = valAry[i]
                dataEntries.append(ChartDataEntry(x: Double(i)+1, y: y))
            } else {
                dataEntries.append(ChartDataEntry(x: Double(i)+1, y: -3.0))
            }
        }
        return dataEntries
    }
    
    
    //get line chart data entries for a given category and count of last n days
    func getScatterChartDataEntries(_ count: Int, cat: CategoryInfo) -> [ChartDataEntry] {
        return getChartDataEntries(count, cat: cat)
    }

    
    //get barchart data entries for a given category and count of last n days
    func getBarChartDataEntries(_ count: Int, cat: CategoryInfo) -> [BarChartDataEntry] {
        var dataEntries: [BarChartDataEntry] = []
        var valAry: [Double] =  getChartDataEntriesByCategory(count, cat: cat)
        var y:Double = 0.0
        for i in 0..<count {
            y = 0.0
            if valAry.count > i {
                y = valAry[i]
            }
            dataEntries.append(BarChartDataEntry(x: Double(i)+1, y: y))
        }
        return dataEntries
    }
    
    //find the values and getchartdata by category
    func getChartDataEntriesByCategory(_ count: Int, cat: CategoryInfo) -> [Double] {
        var valAry: [Double] = []
        
        let dailyHistory = Utils.sharedInstance.dailyHistory
        var activeIdx = dailyHistory.count - 1
        
        for _ in 1...count {
            if activeIdx < 0 {
                break
            }
            let val = Double(dailyHistory[activeIdx].getCategory(cat).value)
            valAry.insert(val, at: 0)
            activeIdx -= 1
        }
        
        return valAry
    }
    
    
    //find the values and getchartdata by meal type
    func getMealChoiceData(_ count: Int, meal: MealType) -> [Double] {
        
        var valAry = [Double]()
        
        let dailyHistory = Utils.sharedInstance.dailyHistory
        var activeIdx = dailyHistory.count - 1
        
        for _ in 1...count {
            if activeIdx < 0 {
                break
            }
            var mealVal = 0
            switch meal {
            case .Breakfast:
                mealVal = dailyHistory[activeIdx].breakfast
            case .Lunch:
                mealVal = dailyHistory[activeIdx].lunch
            case .Dinner:
                mealVal = dailyHistory[activeIdx].dinner
                
            }
            valAry.insert(Double(mealVal), at: 0)
            activeIdx -= 1
        }
        
        return valAry
    }

    
    func getMealChoiceChartDataEntries(_ count: Int, meal: MealType) -> [ChartDataEntry] {
        var dataEntries: [ChartDataEntry] = []
        var valAry: [Double] =  getMealChoiceData(count, meal: meal)
        
//        for i in 0..<valAry.count {
//            let dataEntry = ChartDataEntry(x: valAry[i], y: Double(i))
//            if valAry[i] > 0.1 {
//                dataEntries.append(dataEntry)
//            }
//        }
        
        var y:Double = 0.0
        for i in 0..<count {
            
            if i < valAry.count {
                y = valAry[i]
                if y < 0 {
                    y = -3.0
                }
                
                dataEntries.append(ChartDataEntry(x: Double(i)+1, y: y))
            } else {
                dataEntries.append(ChartDataEntry(x: Double(i)+1, y: -3.0))
            }
        }
        
        
        return dataEntries
    }
    
    //find the values and getchartdata for choice points
    func getChoicePointsChartDataEntries(_ count: Int) -> [BarChartDataEntry] {
//        var valAry: [Double] = []
        var dataEntries: [BarChartDataEntry] = []
        
        let dailyHistory = Utils.sharedInstance.dailyHistory
        var activeIdx = dailyHistory.count - 1
        
        var points = dailyHistory[activeIdx].getTotalPoint()
        activeIdx -= 1
        if activeIdx >= 0 && activeIdx%2 == 0 {
            points += dailyHistory[activeIdx].getTotalPoint()
            activeIdx -= 1
        }
        
        
//        var pointsAry: [Double] = [Double(points)]
//        
//        for _ in 2...15 {
//            if activeIdx < 0 {
//                break
//            }
//            
//            points = dailyHistory[activeIdx].getTotalPoint()
//            activeIdx -= 1
//            points += dailyHistory[activeIdx].getTotalPoint()
//            activeIdx -= 1
//            pointsAry.insert(Double(points), atIndex: 0)
//        }
        /////////////////============== start here
        
        let pointsAry = Utils.sharedInstance.getLast15ChoicePoints()
        
//        for i in 0..<pointsAry.count {
////            let dataEntry = BarChartDataEntry(value: pointsAry[i], xIndex: i)
//            let dataEntry = BarChartDataEntry(x: Double(i), y: pointsAry[i])
//            if pointsAry[i] > 0.1 {
//                dataEntries.append(dataEntry)
//            }
//        }
        
        for i in 0..<count {
            var y:Double = 0.0
            if pointsAry.count > i {
                y = pointsAry[i]
            }
            let dataEntry = BarChartDataEntry(x: Double(i)+1, y: y)
            dataEntries.append(dataEntry)
        }

        
        
        return dataEntries
    }
    
    // get all the labels, it is generally 1 to 30, so just the count is needed.
    class func getLabels(_ count: Int) -> [String] {
        var labels: [String] = []
        for index in 0 ..< count {
            labels.append("\(index+1)")
        }
        return labels
    }
    
}
