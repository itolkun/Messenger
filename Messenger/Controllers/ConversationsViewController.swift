//
//  ViewController.swift
//  Messenger
//
//  Created by Айтолкун Анарбекова on 28/1/23.
//

import UIKit
import FirebaseAuth

class ConversationsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
       validateAuth()
    
    }
    
    private func validateAuth() {
        if FirebaseAuth.Auth.auth().currentUser == nil {
            let LVC = LoginViewController()
            let NVC = UINavigationController(rootViewController: LVC)
            NVC.modalPresentationStyle = .fullScreen
            present(NVC, animated: false)
        }
    }
    


}

