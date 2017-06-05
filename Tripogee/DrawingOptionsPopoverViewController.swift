//
//  DatePopoverViewController.swift
//  Tripogee
//
//  Created by Austin Jacobs on 2/27/17.
//  Copyright © 2017 Austin Jacobs. All rights reserved.
//

import UIKit

class DrawingOptionsPopoverViewController: UIViewController {
    
    var currentColor: UIColor?
    var currentWidth: CGFloat = 5
    private var currentSelectedButton: UIButton?
    
    var currentWeather = 0
    @IBOutlet weak var weatherType: UISegmentedControl!
    
    @IBOutlet var colorButtons: [UIButton]!
    @IBOutlet weak var widthController: UISlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        for button in colorButtons {
            if button.backgroundColor == currentColor {
                selectButton(button)
            }
            button.layer.cornerRadius = button.bounds.width / 2
        }
        widthController.value = Float(currentWidth)
        weatherType.selectedSegmentIndex = currentWeather
    }

    @IBAction func colorSelected(_ sender: UIButton) {
        deselectButton(currentSelectedButton!)
        selectButton(sender)
    }

    
    private func selectButton(_ button: UIButton) {
        currentSelectedButton = button
        currentColor = button.backgroundColor
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.blue.cgColor
    }
    
    private func deselectButton(_ button: UIButton) {
        button.layer.borderWidth = 0
    }
    
    @IBAction func weatherChanged(_ sender: UISegmentedControl) {
        currentWeather = sender.selectedSegmentIndex
    }

}
