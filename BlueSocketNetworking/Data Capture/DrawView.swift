//
//  DrawView.swift
//  BlueSocketNetworking
//
//  Created by Connor Espenshade on 1/5/19.
//  Copyright © 2019 Connor Espenshade. All rights reserved.
//

import UIKit


class HandlesView: UIView {
    private var rectangle: UIView!
    private var handles: [UIView] = []
    private var touchedHandles: [UIView] = []
    private var circleTL: UIView!
    private var circleTR: UIView!
    private var circleBL: UIView!
    private var circleBR: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        rectangle = UIView(frame: bounds.insetBy(dx: 22.0, dy: 22.0))
        addSubview(rectangle)
        
        // Create the handles and position.
        circleTL = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 44.0, height: 44.0))
        circleTL.center = CGPoint(x: rectangle.frame.minX, y: rectangle.frame.minY)
        circleTL.tag = 1
        
        circleTR = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 44.0, height: 44.0))
        circleTR.center = CGPoint(x: rectangle.frame.maxX, y: rectangle.frame.minY)
        circleTR.tag = 2
        
        circleBL = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 44.0, height: 44.0))
        circleBL.center = CGPoint(x: rectangle.frame.minX, y: rectangle.frame.maxY)
        circleBL.tag = 3
        
        circleBR = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 44.0, height: 44.0))
        circleBR.center = CGPoint(x: rectangle.frame.maxX, y: rectangle.frame.maxY)
        circleBR.tag = 4
        
        handles = [circleTL, circleTR, circleBL, circleBR]
        
        for handle in handles {
            // Round the corners into a circle.
            handle.layer.cornerRadius = handle.frame.size.width / 2.0
            clipsToBounds = true
            
            // Add a drag gesture to the handle.
            handle.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(self.handlePan(_:))))
            
            // Add the handle to the screen.
            addSubview(handle)
            
        }
        
        self.backgroundColor = UIColor.white
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setSelectedFrame(_ selectedFrame: CGRect) {
        rectangle.frame = selectedFrame
        
        circleTL.center = CGPoint(x: rectangle.frame.minX, y: rectangle.frame.minY)
        circleTR.center = CGPoint(x: rectangle.frame.maxX, y: rectangle.frame.minY)
        circleBL.center = CGPoint(x: rectangle.frame.minX, y: rectangle.frame.maxY)
        circleBR.center = CGPoint(x: rectangle.frame.maxX, y: rectangle.frame.maxY)
    }
    
    var selectedFrame: CGRect! {
        return rectangle.frame
    }
    
    override var backgroundColor: UIColor? {
        get {
            return super.backgroundColor
        }
        set(backgroundColor) {
            // Set the container to clear.
            super.backgroundColor = UIColor.clear
            
            // Set our rectangle's color.
            rectangle.backgroundColor = backgroundColor?.withAlphaComponent(0.5)
            
            for handle in handles {
                handle.backgroundColor = backgroundColor
            }
        }
    }
    
    @objc func handlePan(_ gesture: UIPanGestureRecognizer?) {
        guard let gesture = gesture else { return }
        // The handle we're moving.
        let touchedHandle = gesture.view
        
        switch gesture.state {
        case .began:
            if let touchedHandle = touchedHandle {
                touchedHandles.append(touchedHandle)
            }
        case .changed:
            let tranlation = gesture.translation(in: self)
            
            // Calculate this handle's new center
            let newCenter = CGPoint(x: (touchedHandle?.center.x ?? 0.0) + tranlation.x, y: (touchedHandle?.center.y ?? 0.0) + tranlation.y)
            
            // Move corresponding circles
            for handle in handles {
                
                if handle != touchedHandle && !touchedHandles.contains(handle) {
                    // Match the handles horizontal movement
                    if handle.center.x == touchedHandle?.center.x {
                        handle.center = CGPoint(x: newCenter.x, y: handle.center.y)
                    }
                    
                    // Match the handles vertical movement
                    if handle.center.y == touchedHandle?.center.y {
                        handle.center = CGPoint(x: handle.center.x, y: newCenter.y)
                    }
                }
            }
            // Move this circle
            touchedHandle?.center = newCenter
            
            // Adjust the Rectangle
            // The origin and just be based on the Top Left handle.
            let x: CGFloat = circleTL.center.x
            let y: CGFloat = circleTL.center.y
            let width: CGFloat = abs(circleTR.center.x - circleTL.center.x)
            let height: CGFloat = abs(circleBL.center.y - circleTL.center.y)
            
            rectangle.frame = CGRect(x: x, y: y, width: CGFloat(width), height: CGFloat(height))
            
            gesture.setTranslation(CGPoint.zero, in: self)
            
            
        case .ended:
            touchedHandles.removeAll(where: { element in element == touchedHandle })
        default:
            break
        }
    }
    
    func remove() {
        rectangle.removeFromSuperview()
        for handle in handles {
            handle.removeFromSuperview()
        }
        self.removeFromSuperview()
    }
}

func returnGreatest(object1: CGFloat, object2: CGFloat) -> CGFloat {
    if object1 > object2 {
        return object1
    } else if object2 > object1 {
        return object2
    } else {
        return object1
    }
}
