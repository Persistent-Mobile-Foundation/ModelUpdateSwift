//
//  UserLoginChallengeHandler.swift
//  mfp-Insurance

//

import Foundation
import IBMMobileFirstPlatformFoundation
import UIKit


public class UserLoginChallengeHandler : SecurityCheckChallengeHandler {
    public static let securityCheckName = "UserLogin"
   
  //  var userLoginViewController : UserLoginViewController?
    
    override init() {
        super.init(name: UserLoginChallengeHandler.securityCheckName)
        WLClient.sharedInstance().registerChallengeHandler(challengeHandler: self)
    }
    
    
    override public func handleChallenge(_ challenge: [AnyHashable : Any]!) {
        let viewcontroller : LoginViewController =  UserLoginChallengeHandler.getTopViewController().topViewController  as! LoginViewController
        viewcontroller.showInvalidScreen()
        self.cancel()
    }
    
    override public func handleSuccess(_ success:  [AnyHashable : Any]!) {
        self.cancel()
    }
    
    
    override public func handleFailure(_ failure:  [AnyHashable : Any]!) {
         let viewcontroller : LoginViewController =  UserLoginChallengeHandler.getTopViewController().topViewController  as! LoginViewController
        viewcontroller.showInvalidScreen()
        self.cancel()
    }
    
    static func getTopViewController() -> UINavigationController {
        
        var viewController = UIViewController()
        
        if let vc =  UIApplication.shared.delegate?.window??.rootViewController {
            
            viewController = vc
            var presented = vc
            
            while let top = presented.presentedViewController {
                presented = top
                viewController = top
            }
        }
        
        return viewController as! UINavigationController
    }
   
    
}


extension UIWindow {
    
    func visibleViewController() -> UIViewController? {
        if let rootViewController: UIViewController  = self.rootViewController {
            return UIWindow.getVisibleViewControllerFrom(vc: rootViewController)
        }
        return nil
    }
    
    class func getVisibleViewControllerFrom(vc:UIViewController) -> UIViewController {
        
        if vc.isKind(of:UINavigationController.self) {
            let navigationController = vc as! UINavigationController
            return UIWindow.getVisibleViewControllerFrom( vc: navigationController.visibleViewController!)
            
        } else if vc.isKind(of:UITabBarController.self) {
            
            let tabBarController = vc as! UITabBarController
            return UIWindow.getVisibleViewControllerFrom(vc: tabBarController.selectedViewController!)
            
        } else {
            
            if let presentedViewController = vc.presentedViewController {
                
                return UIWindow.getVisibleViewControllerFrom(vc: presentedViewController.presentedViewController!)
                
            } else {
                
                return vc;
            }
        }
    }
}
