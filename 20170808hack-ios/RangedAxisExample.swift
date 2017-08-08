//
//  RangedAxisExample.swift
//  graph
//
//  Created by Daichi Shibata on 2017/08/08.
//  Copyright © 2017 Daichi Shibata. All rights reserved.
//

import UIKit
import SwiftCharts

class RangedAxisExample: CustomView{
    
    fileprivate var chart: Chart? //
    
    private var didLayout: Bool = false
    
    fileprivate var lastOrientation: UIInterfaceOrientation?
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame:CGRect){
        super.init(frame: frame)
        
        initChart()
        
        self.backgroundColor = UIColor(red: 0.894117647, green: 0.250980392, blue: 0.007843137, alpha: 0.5)
        
        self.addSubview(self.chart!.view)
    }
    
    public func getRangeChart() -> Chart{
        return chart!
    }
    
    private func initChart() {
        
        let labelSettings = ChartLabelSettings(font: ExamplesDefaults.labelFont, fontColor: UIColor.white)
        
        let firstYear: Double = 0
        let lastYear: Double = 24
        
        //////////////////////////////////////////////////////////////////////////////////////////////////////////
        // 1st x-axis model: Has an axis value (tick) for each year. We use this for the small x-axis dividers.
        
        let xValuesGenerator = ChartAxisGeneratorMultiplier(1)
        
        var labCopy = labelSettings
        labCopy.fontColor = UIColor.red
        let xEmptyLabelsGenerator = ChartAxisLabelsGeneratorFunc {value in return
            ChartAxisLabel(text: "", settings: labCopy)
        }
        
        let xModel = ChartAxisModel(lineColor: UIColor.white, firstModelValue: firstYear, lastModelValue: lastYear, axisTitleLabels: [], axisValuesGenerator: xValuesGenerator, labelsGenerator:
            xEmptyLabelsGenerator)
        
        
        //////////////////////////////////////////////////////////////////////////////////////////////////////////
        // 2nd x-axis model: Has an axis value (tick) for each <rangeSize>/2 years. We use this to show the x-axis labels
        
        let rangeSize: Double = self.frame.width < self.frame.height ? 12 : 6 // adjust intervals for orientation
        let rangedMult: Double = rangeSize / 2
        
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 0
        
        let xRangedLabelsGenerator = ChartAxisLabelsGeneratorFunc {value -> ChartAxisLabel in
            if value < lastYear && value.truncatingRemainder(dividingBy: rangedMult) == 0 && value.truncatingRemainder(dividingBy: rangeSize) != 0 {
                let val1 = value - rangedMult
                let val2 = value + rangedMult
                return ChartAxisLabel(text: "\(String(format: "%.0f", val1)) - \(String(format: "%.0f", val2))", settings: labelSettings)
            } else {
                return ChartAxisLabel(text: "", settings: labelSettings)
            }
        }
        
        let xValuesRangedGenerator = ChartAxisGeneratorMultiplier(rangedMult)
        
        let xModelForRanges = ChartAxisModel(lineColor: UIColor.white, firstModelValue: firstYear, lastModelValue: lastYear, axisTitleLabels: [], axisValuesGenerator: xValuesRangedGenerator, labelsGenerator: xRangedLabelsGenerator)
        
        
        //////////////////////////////////////////////////////////////////////////////////////////////////////////
        // 3rd x-axis model: Has an axis value (tick) for each <rangeSize> years. We use this to show the x-axis guidelines and long dividers
        
        let xValuesGuidelineGenerator = ChartAxisGeneratorMultiplier(rangeSize)
        let xModelForGuidelines = ChartAxisModel(lineColor: UIColor.white, firstModelValue: firstYear, lastModelValue: lastYear, axisTitleLabels: [], axisValuesGenerator: xValuesGuidelineGenerator, labelsGenerator: xEmptyLabelsGenerator)
        
        
        ////////////////////////////////////////////////////////////////////////////////////
        // y-axis model: Has an axis value (tick) for each 2 units. We use this to show the y-axis dividers, labels and guidelines.
        
        let generator = ChartAxisGeneratorMultiplier(2)
        let labelsGenerator = ChartAxisLabelsGeneratorFunc {scalar in
            return ChartAxisLabel(text: "\(scalar)", settings: labelSettings)
        }
        
        let yModel = ChartAxisModel(lineColor: UIColor.white, firstModelValue: 0, lastModelValue: 16, axisTitleLabels: [], axisValuesGenerator: generator, labelsGenerator: labelsGenerator)
        
        
        //////////////////////////////////////////////////////////////////////////////////////////////////////////
        // Chart frame, settings
        
        let chartFrame = ExamplesDefaults.chartFrame(self.bounds)
        
        var chartSettings = ExamplesDefaults.chartSettingsWithPanZoom
        
        chartSettings.axisStrokeWidth = 0.5
        chartSettings.labelsToAxisSpacingX = 10
        chartSettings.leading = -1
        chartSettings.trailing = 40
        
        
        //////////////////////////////////////////////////////////////////////////////////////////////////////////
        // In order to transform the axis models into axis layers, and get the chart inner frame size, we need to use ChartCoordsSpace.
        // Note that in the case of the x-axes we need to use ChartCoordsSpace multiple times - each of these axes represent essentially the same x-axis, so we can't use multi-axes functionality (i.e. pass an array of x-axes to ChartCoordsSpace).
        
        let coordsSpace = ChartCoordsSpaceRightBottomSingleAxis(chartSettings: chartSettings, chartFrame: chartFrame, xModel: xModel, yModel: yModel)
        let coordsSpaceForRanges = ChartCoordsSpaceRightBottomSingleAxis(chartSettings: chartSettings, chartFrame: chartFrame, xModel: xModelForRanges, yModel: yModel)
        let coordsSpaceForGuidelines = ChartCoordsSpaceRightBottomSingleAxis(chartSettings: chartSettings, chartFrame: chartFrame, xModel: xModelForGuidelines, yModel: yModel)
        
        var (xAxisLayer, yAxisLayer, innerFrame) = (coordsSpace.xAxisLayer, coordsSpace.yAxisLayer, coordsSpace.chartInnerFrame)
        var (xRangedAxisLayer, _, _) = (coordsSpaceForRanges.xAxisLayer, coordsSpaceForRanges.yAxisLayer, coordsSpaceForRanges.chartInnerFrame)
        let (xGuidelinesAxisLayer, _, _) = (coordsSpaceForGuidelines.xAxisLayer, coordsSpaceForGuidelines.yAxisLayer, coordsSpaceForGuidelines.chartInnerFrame)
        
        
        //////////////////////////////////////////////////////////////////////////////////////////////////////////
        // Lines layer
        
        let line1ChartPoints = line1ModelData.map{ChartPoint(x: ChartAxisValueDouble($0.0), y: ChartAxisValueDouble($0.1))}
        let line1Model = ChartLineModel(chartPoints: line1ChartPoints, lineColor: UIColor.white, lineWidth: 2, animDuration: 1, animDelay: 0)
        
        //        let line2ChartPoints = line2ModelData.map{ChartPoint(x: ChartAxisValueDouble($0.0), y: ChartAxisValueDouble($0.1))}
        //        let line2Model = ChartLineModel(chartPoints: line2ChartPoints, lineColor: UIColor.blue, lineWidth: 2, animDuration: 1, animDelay: 0)
        
        //        let line3ChartPoints = line3ModelData.map{ChartPoint(x: ChartAxisValueDouble($0.0), y: ChartAxisValueDouble($0.1))}
        //        let line3Model = ChartLineModel(chartPoints: line3ChartPoints, lineColor: UIColor.green, lineWidth: 2, animDuration: 1, animDelay: 0)
        
        let chartPointsLineLayer = ChartPointsLineLayer<ChartPoint>(xAxis: xAxisLayer.axis, yAxis: yAxisLayer.axis, lineModels: [line1Model], pathGenerator: CubicLinePathGenerator(tension1: 0.2, tension2: 0.2))
        
        //////////////////////////////////////////////////////////////////////////////////////////////////////////
        // Markers for the last chart points in each line, shown next to the right y-axis
        
        let viewGenerator = {(chartPointModel: ChartPointLayerModel, layer: ChartPointsViewsLayer, chart: Chart) -> UIView? in
            let h: CGFloat = Env.iPad ? 30 : 20
            let w: CGFloat = Env.iPad ? 60 : 50
            
            let center = chartPointModel.screenLoc
            let label = UILabel(frame: CGRect(x: chart.containerView.frame.maxX, y: center.y - h / 2, width: w, height: h))
            label.backgroundColor = {
                return chartPointsLineLayer.lineModels[chartPointModel.index].lineColor
            }()
            
            label.textAlignment = NSTextAlignment.center
            label.text = chartPointModel.chartPoint.y.description
            label.font = ExamplesDefaults.labelFont
            
            let shape = CAShapeLayer()
            let path = UIBezierPath()
            path.move(to: CGPoint(x: 0, y: h / 2))
            path.addLine(to: CGPoint(x: 20, y: 0))
            path.addLine(to: CGPoint(x: w, y: 0))
            path.addLine(to: CGPoint(x: w, y: h))
            path.addLine(to: CGPoint(x: 20, y: h))
            path.close()
            shape.path = path.cgPath
            label.layer.mask = shape
            
            return label
        }
        
        // Create layer with markers for last chart points.
        let chartPointsLayer = ChartPointsViewsLayer(xAxis: xAxisLayer.axis, yAxis: yAxisLayer.axis, chartPoints: [line1ChartPoints.last!], viewGenerator: viewGenerator, mode: .custom, clipViews: false)
        
        // In order for the x-position of the markers to remain fixed at the right y-axis during zooming and panning, we pass a custom transformer, which updates only the y-position of the markers.
        chartPointsLayer.customTransformer = {(model, view, layer) -> Void in
            var model = model
            model.screenLoc = layer.modelLocToScreenLoc(x: model.chartPoint.x.scalar, y: model.chartPoint.y.scalar)
            view.frame.origin = CGPoint(x: layer.chart?.containerView.frame.maxX ?? 0, y: model.screenLoc.y - 20 / 2)
        }
        
        // Finally we set a custom clip rect for the view where we display the markers, in order to not show them outside of the chart's boundaries, during zooming and panning. For now the size is hardcoded. This should be improved. Until then you can calculate the exact frame using the spacing settings and label (string) sizes.
        chartSettings.customClipRect = CGRect(x: 0, y: chartSettings.top, width: self.frame.width, height: self.frame.height - 120)
        
        
        //////////////////////////////////////////////////////////////////////////////////////////////////////////
        // Guidelines layer. Note how we pass the x-axis layer we created specifically for the guidelines.
        
        let guidelinesLayerSettings = ChartGuideLinesLayerSettings(linesColor: UIColor.white, linesWidth: 0.3)
        let guidelinesLayer = ChartGuideLinesLayer(xAxisLayer: xGuidelinesAxisLayer, yAxisLayer: yAxisLayer, settings: guidelinesLayerSettings)
        
        
        //////////////////////////////////////////////////////////////////////////////////////////////////////////
        // Dividers layer with small lines. This is used both in x and y axes
        
        let dividersSettings =  ChartDividersLayerSettings(linesColor: UIColor.white, linesWidth: 1, start: 2, end: 0)
        let dividersLayer = ChartDividersLayer(xAxisLayer: xAxisLayer, yAxisLayer: yAxisLayer, axis: .xAndY, settings: dividersSettings)
        
        
        //////////////////////////////////////////////////////////////////////////////////////////////////////////
        // Dividers layer with long lines. This is used only in the x axis. Note how we pass the same axis layer we passed to the guidelines - we want to use the same intervals.
        
        let dividersSettings2 =  ChartDividersLayerSettings(linesColor: UIColor.white, linesWidth: 0.5, start: 30, end: 0)
        let dividersLayer2 = ChartDividersLayer(xAxisLayer: xGuidelinesAxisLayer, yAxisLayer: yAxisLayer, axis: .x, settings: dividersSettings2)
        
        
        //////////////////////////////////////////////////////////////////////////////////////////////////////////
        // Disable frame updates for 2 of the 3 x-axis layers. This way the space will not be reserved multiple times. We need this only because the 3 layers represent the same x-axis (for a multi-axis chart this would not be necessary). Note that it's important to pass all 3 layers to the chart, although only one is actually visible, because otherwise the layers will not receive inner frame updates, which results in any layers that reference these layers not being positioned correctly.
        xRangedAxisLayer.canChangeFrameSize = false
        xAxisLayer.canChangeFrameSize = false
        
        //////////////////////////////////////////////////////////////////////////////////////////////////////////
        // create chart instance with frame and layers
        let chart = Chart(
            frame: chartFrame,
            innerFrame: innerFrame,
            settings: chartSettings,
            layers: [
                xAxisLayer,
                xRangedAxisLayer,
                xGuidelinesAxisLayer,
                yAxisLayer,
                guidelinesLayer,
                chartPointsLayer,
                chartPointsLineLayer,
                dividersLayer,
                dividersLayer2
            ]
        )
        
        self.chart = chart
    }
    
    fileprivate let line1ModelData: [(Double, Double)] = [(0, 9.07),(1, 9.47), (2, 10.23), (3, 10.93), (4, 6.51), (5, 8.37), (6, 6.76), (7, 9.30), (8, 8.30), (9, 10.00), (10, 8.73), (11, 5.75), (12, 6.42), (13, 5.30), (14, 6.30), (15, 4.95), (16, 8.40), (17, 7.78), (18, 10.45), (19, 9.21), (20, 12.24), (21, 9.78), (22, 11.47), (23, 9.54), (24, 6.99)]
    
    func rotated() {
        let orientation = UIApplication.shared.statusBarOrientation
        guard (lastOrientation.map{$0.rawValue != orientation.rawValue} ?? true) else {return}
        
        lastOrientation = orientation
        guard let chart = chart else {return}
        for view in chart.view.subviews {
            view.removeFromSuperview()
        }
        self.initChart()
        chart.view.setNeedsDisplay()
    }
    
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}

class CustomView: UIView {
    var corners: UIRectCorner = [.topLeft, .topRight, .bottomLeft, .bottomRight]
    var radius: CGFloat = 0
    
    func roundCorners(corners:UIRectCorner, radius: CGFloat) {
        self.corners = corners
        self.radius = radius
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let maskPath = UIBezierPath(roundedRect: self.bounds,
                                    byRoundingCorners: self.corners,
                                    cornerRadii: CGSize(width: self.radius, height: self.radius))
        
        let maskLayer = CAShapeLayer()
        maskLayer.frame = self.bounds
        maskLayer.path = maskPath.cgPath
        
        self.layer.mask = maskLayer
    }
}
