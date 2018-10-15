//
//  OptionsController.swift
//  ReadTextAction
//
//  Created by EL on 10/14/18.
//  Copyright © 2018 el. All rights reserved.
//

import UIKit

class OptionsController : UIViewController {
    
    var parentView: ActionViewController?
    @IBOutlet var invertSwitch: UISwitch!
    @IBOutlet var marginStepper: UIStepper!
    
    func setParentView(_ _parentView: ActionViewController) {
        parentView = _parentView;
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        invertSwitch.isOn = parentView!.dark
        marginStepper.stepValue = 10
        marginStepper.value = parentView!.insetWidth.native
        marginStepper.maximumValue = 200
        marginStepper.minimumValue = 5
    }
    
    @IBAction func invert(_ sender: UISwitch) {
        parentView!.dark = sender.isOn;
    }
    
    
    @IBAction func margins(_ stepper: UIStepper) {
        parentView?.insetWidth = CGFloat(stepper.value)
    }
}





