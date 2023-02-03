//
//  ViewController.swift
//  Messenger
//
//  Created by Айтолкун Анарбекова on 28/1/23.
//

import UIKit

class ConversationsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let isLoggedIn = UserDefaults.standard.bool(forKey: "logged_in")
        
        if !isLoggedIn {
            let LVC = LoginViewController()
            let NVC = UINavigationController(rootViewController: LVC)
            NVC.modalPresentationStyle = .fullScreen
            present(NVC, animated: false) 
        }
    }
    


}

