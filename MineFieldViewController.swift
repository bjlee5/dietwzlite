//
//  MineFieldViewController.swift
//  Moblzip
//
//  Created by Sujit Maharana on 2/8/16.
//  Copyright © 2016 Moblzip LLC. All rights reserved.
//

import UIKit

class MineFieldViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.interactivePopGestureRecognizer!.delegate = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    @IBAction func onBack(_ sender: AnyObject) {
        _ = navigationController?.popViewController(animated: true)
    }
    
}
