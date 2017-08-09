//
//  RangedAxisExample.swift
//  graph
//
//  Created by Daichi Shibata on 2017/08/08.
//  Copyright © 2017 Daichi Shibata. All rights reserved.
//

import UIKit
import SwiftCharts
import Alamofire
import SwiftyJSON

class RangedAxisExample: CustomView{

    fileprivate var chart: Chart? //

    private var didLayout: Bool = false
    
    var keepAlive = true

    fileprivate var lastOrientation: UIInterfaceOrientation?
    
    var done: Bool = false

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(frame:CGRect){
        super.init(frame: frame)

        updateHeartRate()

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

        let yModel = ChartAxisModel(lineColor: UIColor.white, firstModelValue: 0, lastModelValue: 30, axisTitleLabels: [], axisValuesGenerator: generator, labelsGenerator: labelsGenerator)


        //////////////////////////////////////////////////////////////////////////////////////////////////////////
        // Chart frame, settings

        let chartFrame = ExamplesDefaults.chartFrame(self.bounds)

        var chartSettings = ExamplesDefaults.chartSettingsWithPanZoom

        chartSettings.axisStrokeWidth = 0.5
        chartSettings.labelsToAxisSpacingX = 30
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
        let line1ChartPoints = nulineData.map{ChartPoint(x: ChartAxisValueDouble($0.0), y: ChartAxisValueDouble($0.1))}
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

    var kolineData: [(Double, Double)]!
    var nulineData: [(Double, Double)]!
    var nelineData: [(Double, Double)]!

    var time:[Double] = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
    var ko:[Double] = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
    var nu:[Double] = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
    var ne:[Double] = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]

    func updateHeartRate() {

        let tamuraURL = "http://masayuki.nkmr.io/docomo/index4.php"
        
        self.nulineData = [(0, 0),(1, 0), (2, 0), (3, 0), (4, 0), (5, 0), (6, 0), (7, 0), (8, 0), (9, 0), (10, 0), (11, 0),
                           (12, 0),(13, 0),(14, 0),(15, 0),(16, 0),(17, 0),(18, 0),(19, 0),(20, 0),(21, 0),(22, 0),(23, 0)]

        //ロックが解除されるまで待つ
        Alamofire.request(tamuraURL, method: .get)
            .responseJSON(completionHandler: { response in
                switch response.result {
                case .success(let value):
                    print("success!!!!!!!!!!!!!!!!!!!")
                    let json = JSON(value)
//                    let data = self.getParamData(json)
//                    self.postArray.append(data)
//                    let root = "user/"+String(data["id"] as! Int)

                    print(json)
                    for i in 0..<24{
                        self.time[i] = Double(json["emotionList"].arrayValue[i]["id"].intValue)
                        self.ko[i] = Double(json["emotionList"].arrayValue[i]["ko"].intValue)
                        self.nu[i] = Double(json["emotionList"].arrayValue[i]["nu"].intValue)
                        self.ne[i] = Double(json["emotionList"].arrayValue[i]["ne"].intValue)
                        
                        print(Double(json["emotionList"].arrayValue[i]["nu"].intValue))
                    }
                    self.kolineData = [(0, self.ko[0]),(1, self.ko[1]), (2, self.ko[2]), (3, self.ko[3]), (4, self.ko[4]), (5, self.ko[5]), (6, self.ko[6]), (7, self.ko[7]), (8, self.ko[8]), (9, self.ko[9]), (10, self.ko[10]), (11, self.ko[11]), (12, self.ko[12]), (13, self.ko[13]), (14, self.ko[14]), (15, self.ko[15]), (16, self.ko[16]), (17, self.ko[17]), (18, self.ko[18]), (19, self.ko[19]), (20, self.ko[20]), (21, self.ko[21]), (22, self.ko[22]), (23, self.ko[23])]
                    
                    self.nulineData = [(0, self.nu[0]),(1, self.nu[1]), (2, self.nu[2]), (3, self.nu[3]), (4, self.nu[4]), (5, self.nu[5]), (6, self.nu[6]), (7, self.nu[7]), (8, self.nu[8]), (9, self.nu[9]), (10, self.nu[10]), (11, self.nu[11]), (12, self.nu[12]), (13, self.nu[13]), (14, self.nu[14]), (15, self.nu[15]), (16, self.nu[16]), (17, self.nu[17]), (18, self.nu[18]), (19, self.nu[19]), (20, self.nu[20]), (21, self.nu[21]), (22, self.nu[22]), (23, self.nu[23])]
                    
                    self.nelineData = [(0, self.ne[0]),(1, self.ne[1]), (2, self.ne[2]), (3, self.ne[3]), (4, self.ne[4]), (5, self.ne[5]), (6, self.ne[6]), (7, self.ne[7]), (8, self.ne[8]), (9, self.ne[9]), (10, self.ne[10]), (11, self.ne[11]), (12, self.ne[12]), (13, self.ne[13]), (14, self.ne[14]), (15, self.ne[15]), (16, self.ne[16]), (17, self.ne[17]), (18, self.ne[18]), (19, self.ne[19]), (20, self.ne[20]), (21, self.ne[21]), (22, self.ne[22]), (23, self.ne[23])]
                    
//                    print(self.nulineData)
                    self.chart?.clearView()
                    
                    print(self.nelineData)
                    
                    self.initChart()

                    self.addSubview(self.chart!.view)

                case .failure(let error):
                    print("error:")
                    print(error)
                }
        })
    }

    func getParamData(_ json: JSON) -> [String : Any] {
        //タイムスタンプ
//        let format = DateFormatter()
//        format.dateFormat = "yyyy-MM-dd-HH-mm-ss"
//        let strDate = format.string(from: Date())
        let data: [String : Any] = ["id": json["id"].intValue, "ko": json["ko"].intValue, "nu":json["nu"].intValue, "ne": json["ne"].intValue] as [String : Any]

        return data
    }
    
//    func get() -> [String : Any]{
//        let tamuraURL = "http://masayuki.nkmr.io/docomo/index3.php"
//        let headers = ["Content-Type": "application/json"]
//
//        Alamofire.request(.get, tamuraURL, headers:headers) // APIへリクエストを送信
        //ここで配列でためって一気に送信数する
//        Alamofire.request(tamuraURL, method: .get, parameters: data, encoding: JSONEncoding.default, headers: headers)
//            .response(completionHandler: { response in
//                if let error = response.error {
//                    print(error.localizedDescription)
//                }
//                if response.response?.statusCode == 200 {
//                    print("成功")
//                }
//            }
//        )
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
