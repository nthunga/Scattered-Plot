//
//  GrowthGraphView.swift
//  Graph
//
//  Created by Y Media Labs on 12/9/15.
//  Copyright © 2015 Y Media Labs. All rights reserved.
//

import UIKit

enum GrowthGraphViewAxis {
    case xAxis
    case yAxis
}


// MARK: GrowthGraphViewDataSource -

protocol GrowthGraphViewDataSource: class {
    
    func graphView(view: GrowthGraphView, labelsForAxis axis: GrowthGraphViewAxis) -> [String]
    
    func numberOfPoints(view: GrowthGraphView) -> Int
    
    func graphView(view: GrowthGraphView, pointAtIndex index: Int) -> Float
    
    func graphViewYAxisRange(view: GrowthGraphView) -> (min: Float, max: Float)
    
}

extension GrowthGraphViewDataSource {
    
    func graphView(view: GrowthGraphView, labelsForAxis axis: GrowthGraphViewAxis) -> [String] {
        return []
    }
    
    func numberOfPoints(view: GrowthGraphView) -> Int {
        return 0
    }
    
    func graphView(view: GrowthGraphView, pointAtIndex index: Int) -> Float {
        return 0
    }
    
    func graphViewYAxisRange(view: GrowthGraphView) -> (min: Float, max: Float) {
        return (200, 900)
    }
    
}


// MARK: GrowthGraphViewDataSource -

protocol GrowthGraphViewDelegate: class {
    
    func graphView(view: GrowthGraphView, willAddLayer layer: CAShapeLayer, forPoint point: Float, atIndex index: Int)
    
}

extension GrowthGraphViewDelegate {
    
    func graphView(view: GrowthGraphView, willAddLayer layer: CAShapeLayer, forPoint point: Float, atIndex index: Int) { }
    
}



// MARK: GrowthGraphView -

private let yAxisTopInset: CGFloat = 30.0

private let xAxisLeftInset: CGFloat = -30.0

private let yAxisLabelHeight: CGFloat = 12.0

private let yAxisLabelWidth: CGFloat = 60.0

private let xAxisLabelHeight: CGFloat = 50.0

@IBDesignable class GrowthGraphView: UIView {
    
    lazy var graphCanvasView = UIView()
    
    lazy var lineLayer = CAShapeLayer()
    
    lazy var backgroundView = UIImageView()
    
    
    weak var dataSource: GrowthGraphViewDataSource?
    
    weak var delegate: GrowthGraphViewDelegate?
    
    
    private var segmentWidth: CGFloat = 0
    
    private var segmentHeight: CGFloat = 0
    
    
    @IBInspectable var pointSize: CGFloat = 4
    
    @IBInspectable var pointFillColor: UIColor = UIColor.whiteColor()
    
    @IBInspectable var latestPointFillColor: UIColor = UIColor.whiteColor()
    
    @IBInspectable var pointBorderColor: UIColor = UIColor.whiteColor()
    
    @IBInspectable var labelColor: UIColor = UIColor.blackColor()
    
    @IBInspectable var lineColor: UIColor = UIColor.whiteColor()
    
    @IBInspectable var canvasColor: UIColor = UIColor.blackColor()
    
    @IBInspectable var connectPoints: Bool = true
    
    @IBInspectable var backgroundImage: UIImage?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupView()
    }
    
    
    // MARK: Public Methods -
    
    func reloadGraph() {
        // Clear Previous Values
        for view in self.subviews {
            if view is UILabel {
                view.removeFromSuperview()
            }
        }
        
        if let sublayers = graphCanvasView.layer.sublayers {
            for sublayer in sublayers {
                if sublayer == lineLayer {
                    continue
                }
                
                sublayer.removeFromSuperlayer()
            }
        }
        
        for subview in graphCanvasView.subviews {
            if subview is UILabel {
                subview.removeFromSuperview()
            }
        }
        
        lineLayer.removeAllAnimations()
        
        // Draw New Values
        setupXAxis()
        setupYAxis()
        setupPoints()
    }
    
    
    // MARK: Private Methods -
    
    private func setupView() {
        self.clipsToBounds = true
        
        backgroundView.image = backgroundImage
        self.addSubview(backgroundView)
        
        graphCanvasView.backgroundColor = canvasColor
        graphCanvasView.clipsToBounds = false
        self.addSubview(graphCanvasView)
        
        lineLayer.allowsEdgeAntialiasing = true
        lineLayer.fillColor = UIColor.clearColor().CGColor
        lineLayer.lineWidth = 0.5
        lineLayer.strokeColor = lineColor.CGColor
        graphCanvasView.layer.addSublayer(lineLayer)
    }
    
    private func setupXAxis() {
        guard let points = dataSource?.graphView(self, labelsForAxis: .xAxis) where points.count > 0 else {
            return
        }
        
        let numberOfPoints = points.count
        
        segmentWidth = CGFloat(Float(CGRectGetWidth(graphCanvasView.frame)/CGFloat(8)))
        
        for i in 0..<numberOfPoints {
            var rect = CGRectMake(0, 0, segmentWidth, xAxisLabelHeight)
            
            let label = UILabel(frame: rect)
            label.text = points[i]
            label.minimumScaleFactor = 0.5
            label.textAlignment = .Right
            label.textColor = labelColor
            label.alpha = 0.8
            self.addSubview(label)
            
            let size = label.sizeThatFits(CGSizeMake(segmentWidth, xAxisLabelHeight))
            var x = yAxisLabelWidth + xAxisLeftInset
            x += CGFloat(i + 1) * segmentWidth
            x -= size.width * 0.5
            
            rect.origin.x = x
            rect.origin.y = CGRectGetMaxY(graphCanvasView.frame) + 8
            rect.size.width = size.width
            label.frame = rect
            
            let centerX = (CGFloat(i + 1) * segmentWidth) + xAxisLeftInset
            let startPoint = CGPointMake(centerX, 18)
            let endPoint = CGPointMake(centerX, graphCanvasView.frame.size.height + 15)
            
            let path = UIBezierPath()
            path.moveToPoint(startPoint)
            path.addLineToPoint(endPoint)
            
            let layer = CAShapeLayer()
            layer.strokeColor = lineColor.CGColor
            layer.lineDashPattern = [ 2, 2 ]
            layer.lineWidth = 0.5
            layer.path = path.CGPath
            layer.allowsEdgeAntialiasing = true
            layer.fillColor = UIColor.clearColor().CGColor
            graphCanvasView.layer.addSublayer(layer)
        }
    }
    
    private func setupYAxis() {
        guard let points = dataSource?.graphView(self, labelsForAxis: .yAxis) where points.count > 0 else {
            return
        }
        
        let numberOfPoints = points.count
        
        segmentHeight = CGFloat(Float(CGRectGetHeight(graphCanvasView.frame)/CGFloat(numberOfPoints)))
        
        for i in 1...numberOfPoints {
            var rect = CGRectMake(0, yAxisTopInset, yAxisLabelWidth, yAxisLabelHeight)
            rect.origin.y += (CGFloat(i) * segmentHeight) - (yAxisLabelHeight/2)
            
            let label = UILabel(frame: rect)
            label.text = points[numberOfPoints - i]
            label.minimumScaleFactor = 0.5
            label.textAlignment = .Center
            label.textColor = labelColor
            label.alpha = 0.8
            self.addSubview(label)
            
            
            let centerY = label.center.y - yAxisTopInset
            let startPoint = CGPointMake(0, centerY)
            let endPoint = CGPointMake(graphCanvasView.frame.size.width, centerY)
            
            let path = UIBezierPath()
            path.moveToPoint(startPoint)
            path.addLineToPoint(endPoint)
            
            let layer = CAShapeLayer()
            layer.strokeColor = lineColor.CGColor
            layer.lineDashPattern = [ 2, 2 ]
            layer.lineWidth = 0.5
            layer.path = path.CGPath
            layer.allowsEdgeAntialiasing = true
            layer.fillColor = UIColor.clearColor().CGColor
            graphCanvasView.layer.addSublayer(layer)
        }
    }
    
    private func setupPoints() {
        guard let numberOfPoints = dataSource?.numberOfPoints(self) where numberOfPoints > 0 else {
            return
        }
        
        guard let range = dataSource?.graphViewYAxisRange(self) else {
            return
        }
        
        let path = UIBezierPath()
        let size = CGSizeMake(pointSize, pointSize)
        
        for i in 0..<numberOfPoints {
            guard let value = dataSource?.graphView(self, pointAtIndex: i) else {
                continue
            }
            
            let yRatio = CGFloat(Math.straightLineY(value, x1: range.min, x2: range.max, y1: 0.0, y2: 1.0))
            
            
            let graphBoundingHeight = CGRectGetHeight(graphCanvasView.frame) - segmentHeight
            
            let centerX = (CGFloat(i + 1) * segmentWidth) + xAxisLeftInset
            let centerY = CGRectGetHeight(graphCanvasView.frame) - (graphBoundingHeight * yRatio)
            
            let rect = CGRectMake(centerX - (size.width * 0.5), centerY - (size.height * 0.5), size.width, size.height)
            let layer = CAShapeLayer()
            layer.lineWidth = 0.5
            layer.strokeColor = pointBorderColor.CGColor
            layer.path = UIBezierPath(roundedRect: rect, cornerRadius: rect.size.width/2).CGPath
            layer.allowsEdgeAntialiasing = true
            if i < numberOfPoints - 1 {
                layer.fillColor = pointFillColor.CGColor
            }
            else {
                layer.fillColor = latestPointFillColor.CGColor
            }
            
            delegate?.graphView(self, willAddLayer: layer, forPoint: value, atIndex: i)
            
            graphCanvasView.layer.addSublayer(layer)
            
            if connectPoints {
                if i == 0 {
                    path.moveToPoint(CGPointMake(centerX, centerY))
                }
                else {
                    path.addLineToPoint(CGPointMake(centerX, centerY))
                }
            }
            
            
            // Caption Label
            let textLabel = UILabel(frame: CGRectMake(0, 0, 60, 12))
            // Mark: FIXME - uncomment following code once correct data is fetched from api
            let isNan = centerY.isNaN
            if isNan != true{
                textLabel.center = CGPointMake(centerX, centerY - 15)
            }
            textLabel.text = "\(Int(value))"
            textLabel.textColor = UIColor.whiteColor()
            textLabel.textAlignment = .Center
            graphCanvasView.addSubview(textLabel)
        }
        
        if connectPoints {
            self.lineLayer.path = path.CGPath
            
            let animation = CABasicAnimation(keyPath: "strokeEnd")
            animation.duration = 1.0
            animation.fromValue = NSNumber(float: 0.0)
            animation.toValue = NSNumber(float: 1.0)
            animation.removedOnCompletion = true
            lineLayer.addAnimation(animation, forKey: nil)
        }
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        backgroundView.frame = self.bounds
        
        var rect = self.bounds
        rect.origin.x = yAxisLabelWidth
        rect.origin.y = yAxisTopInset
        rect.size.width -= yAxisLabelWidth
        rect.size.height -= (xAxisLabelHeight + yAxisTopInset)
        graphCanvasView.frame = rect
        
        reloadGraph()
    }
    
}
