//
//  ProfileViewController.swift
//  Messenger
//
//  Created by Айтолкун Анарбекова on 28/1/23.
//

import UIKit
import FirebaseAuth
import FBSDKLoginKit
import GoogleSignIn

class ProfileViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    
    let data = ["Log Out"]

    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self

        
    }
    

    
}


extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        data.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        content.text = data[indexPath.row]
        cell.contentConfiguration = content
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true )
        
        let actionSheet = UIAlertController(
            title: "",
            message: "",
            preferredStyle: .actionSheet)
        actionSheet.addAction(
            UIAlertAction(
                title: "Log Out",
                style: .destructive,
                handler: { [weak self]_ in
                    guard let strongSelf = self else {
                        return
                    }
                    // facebook log out
                    FBSDKLoginKit.LoginManager().logOut()
                    // google log out
                    GIDSignIn.sharedInstance.signOut()
                    
                    do {
                        try FirebaseAuth.Auth.auth().signOut()
                        
                        let LVC = LoginViewController()
                        let NVC = UINavigationController(rootViewController: LVC)
                        NVC.modalPresentationStyle = .fullScreen
                        strongSelf.present(NVC, animated: true)
                    }
                    catch {
                        print("Failed to Logout")
                    }
                }
            )
        )
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel  ))
        present(actionSheet, animated: true)
        
        
    }
    
}
