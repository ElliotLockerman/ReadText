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
    
    func setParentView(_ _parentView: ActionViewController) {
        parentView = _parentView;
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        invertSwitch.isOn = parentView!.dark
    }
    
    @IBAction func invert(_ sender: UISwitch) {
        parentView!.dark = sender.isOn;
    }
    
}





