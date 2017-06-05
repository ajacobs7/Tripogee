//
//  BrainstormViewController.swift
//  Tripogee
//
//  Created by Austin Jacobs on 2/28/17.
//  Copyright © 2017 Austin Jacobs. All rights reserved.
//

import UIKit
import CoreData
import MapKit
import AVFoundation

class BrainstormViewController: UIViewController, UIPopoverPresentationControllerDelegate, MKMapViewDelegate {
    
    var container: NSPersistentContainer? =
        (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer

    @IBOutlet weak var drawingView: DrawingView!
    @IBOutlet weak var drawButton: UIButton!
    
    private var drawingButtons: [UIButton] = []
    private var mapLoaded = false
    private var currentWeather: Int? //sun
    
    var brainstorm: Brainstorm?
    @IBOutlet weak var map: MKMapView!
    var drawing = false {
        didSet {
            map.isZoomEnabled = !drawing
            map.isScrollEnabled = !drawing
            map.isRotateEnabled = !drawing
            map.isUserInteractionEnabled = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //Lock as portrait
        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        appdelegate.supportAllOrientations = false
        
        drawingView.backgroundColor = UIColor.clear
        map.delegate = self
        if brainstorm == nil {
            setUpBrainstorm()
        } else {
            reloadBrainstorm()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if brainstorm != nil && (brainstorm?.strokes?.allObjects.count)! > 0 {
            changeDrawingMode(drawButton)
        }
    }
    
    private func setUpBrainstorm() {
        let alert = UIAlertController(title: "Brainstorm Name", message:
            nil, preferredStyle: UIAlertControllerStyle.alert)
        alert.addTextField(configurationHandler: nil)
        alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: { [weak alert] (_) in
            let field = alert?.textFields![0]
            DispatchQueue.main.async {
                if let context = self.container?.viewContext {
                    self.brainstorm = Brainstorm(context: context)
                    self.brainstorm?.name = field!.text!
                    self.brainstorm?.dateCreated = Date() as NSDate
                    self.navigationItem.title = self.brainstorm?.name
                    self.drawingView.brainstorm = self.brainstorm
                }
            }
        }))
        self.present(alert, animated: true, completion: nil)
        drawingView.isUserInteractionEnabled = false
    }
    
    private func reloadBrainstorm() {
        if let camera = brainstorm?.camera as? MKMapCamera {
            map.camera = camera
        }
        self.navigationItem.title = self.brainstorm?.name
        drawingView.brainstorm = brainstorm
        changeWeather(to: Int(brainstorm!.weather))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if mapLoaded {
            takeScreenShot()
        }
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        appdelegate.supportAllOrientations = true
        super.viewWillDisappear(animated)
    }
    
    //http://stackoverflow.com/questions/2214957/how-do-i-take-a-screen-shot-of-a-uiview
    func takeScreenShot() {
        UIGraphicsBeginImageContextWithOptions(drawingView.bounds.size, false, UIScreen.main.scale)
        view.drawHierarchy(in: drawingView.bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        //Save screenshot to document directory
        if let image_data = UIImagePNGRepresentation(image) {
            let docDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let filename = docDir.appendingPathComponent((brainstorm?.dateCreated?.description)! + ".summary.png")
            try? image_data.write(to: filename)
        }
    }


    func mapViewDidFinishRenderingMap(_ mapView: MKMapView, fullyRendered: Bool) {
        mapLoaded = true
    }
    
    @IBAction func changeDrawingMode(_ sender: UIButton) {
        if drawing {
            //turn off
            if drawingView.isEmpty() {
                //can move map around
                sender.layer.borderWidth = 0
                removeButtons(drawingButtons)
                drawing = false
                drawingView.isUserInteractionEnabled = false
                self.view.sendSubview(toBack: drawingView)
            } else {
                let alert = UIAlertController(title: "Cannot Turn Off Drawing Mode", message: "Clear drawings to reposition the map.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default ,handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        } else {
            //turn on
            if let context = self.container?.viewContext {
                brainstorm?.camera = map.camera //Save map coordinates
                try? context.save()
            }
            sender.layer.borderColor = UIColor.red.cgColor
            sender.layer.borderWidth = 2
            drawing = true
            drawingView.isUserInteractionEnabled = true
            self.view.bringSubview(toFront: drawingView)
            self.view.bringSubview(toFront: drawButton)
            displayDrawingButtons(with: drawButton.frame)
        }
    }
    
    private func displayDrawingButtons(with frame: CGRect){
        let clear = UIButton(frame: frame)
        clear.setBackgroundImage(UIImage(named: "clear.png"), for: UIControlState.normal)
        clear.addTarget(self, action: #selector(clearDrawings), for: UIControlEvents.touchUpInside)
        let undo = UIButton(frame: frame)
        undo.setBackgroundImage(UIImage(named: "undo.png"), for: UIControlState.normal)
        undo.addTarget(self, action: #selector(undoLastStroke), for: UIControlEvents.touchUpInside)
        
        moveButtonsUp([clear, undo], at: frame.origin)
    }
    
    private func moveButtonsUp(_ buttons: [UIButton], at origin: CGPoint) {
        if buttons.count > 0{
            var buttonsCopy = buttons
            let button = buttonsCopy.removeFirst()
            button.frame.origin = origin
            view.addSubview(button)
            drawingButtons.append(button)
            UIView.animate(withDuration: 0.5, animations: { (_) in
                button.transform = CGAffineTransform(translationX: 0, y:  -(button.frame.size.height + 5))
            }, completion: { (finished) in
                self.moveButtonsUp(buttonsCopy, at: button.frame.origin)
            })
        }
    }
    
    private func removeButtons(_ buttons: [UIButton]) {
        if buttons.count > 0 {
            var buttonsCopy = buttons
            let button = buttonsCopy.removeLast()
            UIView.transition(with: button, duration: 0.5, options: .transitionFlipFromLeft, animations: {
            }, completion: { (finished) in
                self.removeButtons(buttonsCopy)
                button.removeFromSuperview()
            })
        }
    }
    
    func clearDrawings(){
        drawingView.clear()
    }
    
    func undoLastStroke(){
        drawingView.undo()
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    //Popover delegate
    
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        let popover = popoverPresentationController.presentedViewController as! DrawingOptionsPopoverViewController
        drawingView.lineColor = popover.currentColor!
        drawingView.lineWidth = CGFloat(popover.widthController.value)
        if currentWeather != popover.currentWeather {
            changeWeather(to: popover.currentWeather)
        }
        if let context = container?.viewContext {
            brainstorm?.drawingColor = popover.currentColor
            brainstorm?.drawingWidth = popover.widthController.value
            brainstorm?.weather = Int32(popover.currentWeather)
            try? context.save()
        }
    }
    
    //Weather control
    
    private func changeWeather(to state: Int) {
        if currentWeather == 1 { //rain
            stopRain()
        }
        switch state {
        case 1:
            rain()
        case 2:
            cloud()
        case 3: ()
            lightning()
        default:
            break //sun
        }
        currentWeather = state
    }
    
    private func cloud(){
        //add cloud
        let cloud_img = UIImageView(image: UIImage(named: "cloud.png"))
        let width = CGFloat(arc4random_uniform(UInt32(view.frame.width/4)) + 100) // must be bigger than 100 width
        let height = CGFloat(width) * 0.75 //aspect ratio of 4:3
        let rand_y = CGFloat(arc4random_uniform(UInt32(view.frame.height - height)))
        cloud_img.frame = CGRect(x: -width, y: rand_y, width: width, height: height)
        view.addSubview(cloud_img)
        
        //animate
        UIView.animate(withDuration: TimeInterval(view.frame.width/CGFloat(20.0)), animations: {
            let d_x = cloud_img.frame.width*2 + self.view.frame.width
            cloud_img.transform = CGAffineTransform(translationX: d_x, y: 0)
        }, completion: { (finished) in
            cloud_img.removeFromSuperview()
            if self.currentWeather == 2 {
                self.cloud()
            }
        })
    }
    
    private func lightning(){
        let lightning_img = UIImageView(image: UIImage(named: "lightning.png"))
        let height = CGFloat(arc4random_uniform(UInt32(view.frame.height/6)) + 100)
        let width = CGFloat(height) * 0.9
        let rand_y = CGFloat(arc4random_uniform(UInt32(view.frame.height - height)))
        let rand_x = CGFloat(arc4random_uniform(UInt32(view.frame.width - width)))
        lightning_img.frame = CGRect(x: rand_x, y: rand_y, width: width, height: height)
        lightning_img.alpha = 0.0
        view.addSubview(lightning_img)
        
        let random_interval = TimeInterval(arc4random_uniform(10))
        UIView.animate(withDuration: 0.5, delay: random_interval, options: UIViewAnimationOptions.transitionCrossDissolve, animations: {
            if self.currentWeather == 3 {
                lightning_img.alpha = 1.0
            }
        }) { (finished) in
            lightning_img.removeFromSuperview()
            if self.currentWeather == 3{
                self.lightning()
            }
        }
        
    }
    
    var animator: UIDynamicAnimator!
    var gravity = UIGravityBehavior()
    var drops: [UIImageView] = []
    var rainTimer: Timer?
    
    private func rain(){
        animator = UIDynamicAnimator(referenceView: self.view)
        animator.addBehavior(gravity)
        rainTimer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(createDrop), userInfo: nil, repeats: true)
    }
    
    func createDrop(){
        let x = CGFloat(arc4random_uniform(UInt32(view.frame.width - 20)))
        let drop_img = UIImageView(image: UIImage(named: "drop.png"))
        drop_img.frame = CGRect(x: x, y: 0, width: 20, height: 20)
        view.addSubview(drop_img)
        gravity.addItem(drop_img)
        drops.append(drop_img)

        
        for drop in drops {
            if drop.frame.origin.y > view.frame.height {
                drop.removeFromSuperview()
            }
        }
    }
    
    private func stopRain(){
        rainTimer?.invalidate()
        for drop in drops {
            drop.removeFromSuperview()
        }
        drops = []
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //Color/Line width pallet
        if let destination = segue.destination as? DrawingOptionsPopoverViewController {
            destination.modalPresentationStyle = UIModalPresentationStyle.popover
            destination.currentWidth = drawingView.lineWidth
            destination.currentColor = drawingView.lineColor
            if currentWeather != nil {
                destination.currentWeather = currentWeather!
            }
            
            //set size
            let width = (view.frame.width > 220) ? 220 : view.frame.width/2
            let height = (view.frame.height > 350) ? 350 : view.frame.height/2
            destination.preferredContentSize = CGSize(width: width, height: height)
            
            if let popover = destination.popoverPresentationController {
                popover.delegate = self
            }
        }
    }
    
    
}
