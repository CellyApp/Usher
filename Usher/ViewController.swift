//
//  ViewController.swift
//  Usher
//
//  Created by Jeremy Lawrence on 4/28/15.
//  Copyright (c) 2015 Celly. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var presenting = false
    var overlay: HighlightOverlayView?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @IBAction func buttonTapped(sender: UIButton) {
        if !presenting {
            var overlay = HighlightOverlayView()
            overlay.highlight([sender], withText: "Okay sure a long demo string")
            self.overlay = overlay
        } else {
            overlay?.dismiss(nil)
        }
        presenting = !presenting
    }
}

