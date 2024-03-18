//
//  ViewController.swift
//  mfp-Insurance
//

//

import UIKit
import IBMMobileFirstPlatformFoundation

class LoginViewController: UIViewController {

    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func login(_ sender: Any) {
        if let user = username.text, let pass = password.text{
            WLAuthorizationManager.sharedInstance()?.login(UserLoginChallengeHandler.securityCheckName, withCredentials: ["username": user, "password" : pass], withCompletionHandler: { (error) in
                if (error == nil) {
                    self.navigationController?.pushViewController( (self.storyboard?.instantiateViewController(withIdentifier: "Home"))!, animated: true)
                }
            })
        }
    }
    
    func showInvalidScreen() {
        let alert = UIAlertController(title: "Invalid", message: "Username/Password is invalid, Kindly Retry.", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Okay", style: UIAlertAction.Style.cancel, handler: {(alert: UIAlertAction!) in
            self.username.text = ""
            self.password.text = ""
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
}

