//
//  PercentView.swift
//  BlueSocketNetworking
//
//  Created by Connor Espenshade on 1/6/19.
//  Copyright © 2019 Connor Espenshade. All rights reserved.
//

import UIKit

class PercentView: UIView {
    @IBOutlet private weak var progressBar: UIProgressView!
    @IBOutlet private weak var progressLabel: UILabel!
    
    /**
     Public method to set the progress of the view.
     - Parameter percent: The percent done with the task at hand. Starts at 0.0 and ranges between 0.0 and 1.0.
 */
    public func setProgress(percent: Float) {
        progressBar.progress = percent
        progressLabel.text = "\((percent * 100).rounded())% complete"
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        progressBar.progress = 0.0
        progressLabel.text = "0% complete"
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension DataCaptureViewController {
    func showPercentView() {
        percentView.center = self.view.center
        percentView.alpha = 0
        
        self.view.addSubview(percentView)
        
        UIView.animate(withDuration: 0.4) {
            self.view.alpha = 0.4
            self.percentView.alpha = 1
        }
    }
    
    func dismissPercentView() {
        UIView.animate(withDuration: 0.4) {
            self.view.alpha = 1
            self.percentView.alpha = 0
        }
        
        percentView.removeFromSuperview()
    }
}
