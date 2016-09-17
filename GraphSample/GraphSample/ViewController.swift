//
//  ViewController.swift
//  GraphSample
//
//  Created by Naveen Thunga on 01/09/16.
//  Copyright © 2016 YMedia Labs. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    private let viewModel = GraphViewModel()
    
    @IBOutlet weak var graphView: GrowthGraphView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        graphView.delegate = self
        graphView.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension ViewController: GrowthGraphViewDataSource {
    
    func graphView(view: GrowthGraphView, labelsForAxis axis: GrowthGraphViewAxis) -> [String] {
        if axis == .xAxis {
            return ["1st","2nd","3rd","4th","5th","6th","7th","8th"]
        }
        else{
            return ["300","400","500","600"]
        }
    }
    
    func numberOfPoints(view: GrowthGraphView) -> Int {
        return 8
    }
    
    func graphViewYAxisRange(view: GrowthGraphView) -> (min: Float, max: Float) {
        return (200,600)
    }
    
    func graphView(view: GrowthGraphView, pointAtIndex index: Int) -> Float {
        let graphValue: [Float] = [350.0,450.0,290.0,480.0,300.0,420.0,490.0,380.0]
        return graphValue[index]
    }
    
}


// MARK: GrowthGraphViewDelegate -

extension ViewController: GrowthGraphViewDelegate {
    
    func graphView(view: GrowthGraphView, willAddLayer layer: CAShapeLayer, forPoint point: Float, atIndex index: Int) {
        
    }
    
}