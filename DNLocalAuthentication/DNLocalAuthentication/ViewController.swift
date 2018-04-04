//
//  ViewController.swift
//  DNLocalAuthentication
//
//  Created by mainone on 16/10/12.
//  Copyright © 2016年 wjn. All rights reserved.
//

import UIKit
import LocalAuthentication

class ViewController: UIViewController {

    @IBOutlet weak var message: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        DNLocalAuthentication.share.authenticationLogin(reply: { (success, error, errorMessage) in
            if success {
                self.message.text = "验证成功"
            } else {
                self.message.text = errorMessage
            }
        }) { (success, error) in
            if success {
                self.message.text = "重置成功"
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

