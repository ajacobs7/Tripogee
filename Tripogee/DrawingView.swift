//
//  DrawingView.swift
//  Tripogee
//
//  Created by Austin Jacobs on 3/7/17.
//  Copyright © 2017 Austin Jacobs. All rights reserved.
//

import UIKit
import CoreData

class DrawingView: UIView {
    
    private var container: NSPersistentContainer? =
        (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    
    private var curStroke: UIBezierPath?
    private var strokes: [Stroke] = []
    
    // Public interface
    
    var brainstorm: Brainstorm? {
        didSet {
            //Load strokes and color/width information
            strokes = Stroke.getAll(for: brainstorm!)
            if let color = brainstorm?.drawingColor as? UIColor {
                lineColor = color
                lineWidth = CGFloat((brainstorm?.drawingWidth)!)
            }
        }
    }
    
    var lineWidth: CGFloat = 2.5
    var lineColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1) // black
    
    func isEmpty() -> Bool {
        return strokes.count == 0
    }
    
    func clear() {
        for stroke in strokes {
            removeStroke(stroke)
        }
        strokes.removeAll()
        setNeedsDisplay()
    }
    
    func undo() {
        if !strokes.isEmpty {
            let stroke = strokes.removeLast()
            removeStroke(stroke)
        }
        setNeedsDisplay()
    }

    // Drawing
    
    override func draw(_ rect: CGRect) {
        for stroke in strokes {
            let path = NSKeyedUnarchiver.unarchiveObject(with: stroke.stroke as! Data) as! UIBezierPath
            let color = stroke.color as! UIColor
            color.setStroke()
            path.stroke()
        }
        lineColor.setStroke()
        curStroke?.stroke()
    }
    
    // Handle touches
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //Create/Setup new stroke
        curStroke = UIBezierPath()
        if let first = touches.first?.location(in: self) {
            curStroke?.move(to: first)
            curStroke?.lineWidth = lineWidth
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        //Add to current stroke
        if let new = touches.first?.location(in: self) {
            curStroke?.addLine(to: new)
        }
        setNeedsDisplay()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        //Finish current stroke
        if let stroke = createStroke(for: curStroke!) {
            strokes.append(stroke)
        }
        curStroke = nil
    }
    
    // Strokes
    
    private func createStroke(for path: UIBezierPath) -> Stroke? {
        if let context = container?.viewContext {
            let stroke = Stroke(context: context)
            stroke.brainstorm = brainstorm
            stroke.color = lineColor
            stroke.stroke = NSKeyedArchiver.archivedData(withRootObject: path) as NSData?
            stroke.created = Date() as NSDate?
            try? context.save()
            return stroke
        }
        return nil
    }
    
    private func removeStroke(_ stroke: Stroke){
        if let context = container?.viewContext {
            context.delete(stroke)
            try? context.save()
        }
    }


}
