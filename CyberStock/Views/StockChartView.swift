//
//  StockChartView.swift
//  CyberStock
//
//  Created by William Hinson on 3/4/22.
//

import UIKit
import Charts
import CoreML

class StockChartView: UIView {
    
    struct vieweModel {
        let data: [Double]
        let showLegend: Bool
        let showAxis: Bool
        let fillColor: UIColor
        let label: String
    }
    
    let chartView: LineChartView = {
       let chartView = LineChartView()
        chartView.pinchZoomEnabled = false
        chartView.setScaleEnabled(false)
        chartView.xAxis.enabled = false
        chartView.drawGridBackgroundEnabled = false
        chartView.leftAxis.enabled = false
        chartView.rightAxis.enabled = false
        chartView.animate(xAxisDuration: 0.25)
        return chartView
    }()
    


    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(chartView)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        chartView.frame = bounds
    }
    
    func reset() {
        chartView.data = nil
    }
    
    func configure(with viewModel: vieweModel) {
        var entries = [ChartDataEntry]()
        
        
        

        for (index, value) in viewModel.data.enumerated() {
            entries.append(
                .init(
                    x: Double(index),
                    y: value
                )
            )
        }
        
        chartView.legend.enabled = viewModel.showLegend
        let gradient = getGradientFilling(with: viewModel)


        let dataSet = LineChartDataSet(entries: entries, label: viewModel.label)
        dataSet.fill = Fill.fillWithLinearGradient(gradient, angle: 90)
        dataSet.lineWidth = 2
        dataSet.setColors(viewModel.fillColor)
        dataSet.drawFilledEnabled = true
        dataSet.drawValuesEnabled = false
        dataSet.drawCirclesEnabled = false
        dataSet.highlightColor = .label
        dataSet.drawIconsEnabled = false
        dataSet.drawHorizontalHighlightIndicatorEnabled = false
        dataSet.mode = .cubicBezier
        
        if dataSet.count == 10 {
            dataSet.drawValuesEnabled = true
            dataSet.drawCirclesEnabled = true

        }
        
        let data = LineChartData(dataSet: dataSet)
        chartView.data = data

    }
    
    private func getGradientFilling(with viewModel: vieweModel) -> CGGradient {
        let colorTop = viewModel.fillColor.cgColor
        let bottomColor = viewModel.fillColor.withAlphaComponent(0.0).cgColor
        
        let gradientColor = [colorTop,bottomColor] as CFArray
        
        let colorLocations: [CGFloat] = [0.5,0.0]
        
        return CGGradient.init(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: gradientColor, locations: colorLocations)!
    }

}


