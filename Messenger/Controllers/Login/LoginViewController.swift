//
//  LoginViewController.swift
//  Messenger
//
//  Created by Айтолкун Анарбекова on 28/1/23.
//

import UIKit
import FirebaseAuth
import Firebase
import FBSDKLoginKit
import GoogleSignIn

class LoginViewController: UIViewController {
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "logo")
        imageView.contentMode = .scaleAspectFit
        return imageView
        
    }()
    
    private let emailField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Email Address..."
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        return field
        
    }()
    
    private let passwordField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .done
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Password..."
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        field.isSecureTextEntry = true
        return field
        
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton()
        button.setTitle("Log In", for: .normal)
        button.backgroundColor = .link
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold )
        
        return button
    }()
    
    private let fcLoginButton: FBLoginButton = {
        let button = FBLoginButton()
        button.permissions = ["email, public_profile"]
        return button
    }()
    
    private let googleLogInButton = GIDSignInButton()
    
    
    private var loginObserver: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginObserver = NotificationCenter.default.addObserver(
            forName: .didLoginNotification,
            object: nil,
            queue: .main) { [weak self] _ in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.navigationController?.dismiss(animated: true)
            }
        title = "Log In"
        view.backgroundColor = .white
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Register",
            style: .done,
            target: self,
            action: #selector(didTapRegister)
        )
        
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        googleLogInButton.addTarget(self, action: #selector(googleSignInButton), for: .touchUpInside)
        emailField.delegate = self
        passwordField.delegate = self
        fcLoginButton.delegate = self
        
        //add subviews
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passwordField )
        scrollView.addSubview(loginButton)
        scrollView.addSubview(fcLoginButton)
        scrollView.addSubview(googleLogInButton)
        
    }
    
    deinit {
        if let observer = loginObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    @objc func googleSignInButton() {
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { signResult, error in
            
            if let error = error {
                print("failed to login w gogle \(error)")
                return
            }
            
            
            
            guard let user = signResult?.user,
                  let idToken = user.idToken else { return }
            
            let accessToken = user.accessToken
            
            print("did sugn in with google \(user)")
            
            guard let email = user.profile?.email,
                  let firstName = user.profile?.givenName,
                  let lastName = user.profile?.familyName else {
                return
            }
            
            DatabaseManager.shared.userExists(with: email) { exists in
                if !exists {
                    // insert to database
                    DatabaseManager.shared.insertUser(with: ChapAppUser(
                        firstName: firstName,
                        lastName: lastName,
                        emailAddress: email))
                }
            }
            
         
                    
            let credential = GoogleAuthProvider.credential(withIDToken: idToken.tokenString, accessToken: accessToken.tokenString)
            
            FirebaseAuth.Auth.auth().signIn(with: credential, completion: {[weak self] authResult, error in
                guard let strongSelf = self else {
                    return
                }
                guard authResult != nil, error == nil else {
                    if let error = error {
                        print("google credential login failed  - \(error)")
                    }
                    return
                }
                print("succesfully logged user in")
                NotificationCenter.default.post(name: .didLoginNotification, object: nil)
                strongSelf.navigationController?.dismiss(animated: true)
            })
        }
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        let size = scrollView.width / 3
        imageView.frame = CGRect(
            x: (scrollView.width - size) / 2,
            y: 80,
            width: size,
            height: size
        )
        
        emailField.frame = CGRect(
            x: 30,
            y: imageView.bottom + 10,
            width: scrollView.width - 60,
            height: 52
        )
        passwordField.frame = CGRect(
            x: 30,
            y: emailField.bottom + 10,
            width: scrollView.width - 60,
            height: 52
        )
        loginButton.frame = CGRect(
            x: 30,
            y: passwordField.bottom + 10,
            width: scrollView.width - 60,
            height: 52
        )
        fcLoginButton.frame = CGRect(
            x: 30,
            y: loginButton.bottom + 10,
            width: scrollView.width - 60,
            height: 52
        )
        
        googleLogInButton.frame = CGRect(
            x: 30,
            y: fcLoginButton.bottom + 10,
            width: scrollView.width - 60,
            height: 52
        )
    }
    
    @objc private func loginButtonTapped() {
        
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
        guard let email = emailField.text, let password = passwordField.text,
              !email.isEmpty, !password.isEmpty, password.count >= 6 else {
            alertUserLoginError()
            return
        }
        // FireBase Log In
        
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            guard let strongSelf = self else {
                return
            }
            guard let result = authResult, error == nil else {
                print("Failed to Log In user with email \(email)")
                return
            }
            let user = result.user
            print("Logged in User \(user)")
            strongSelf.navigationController?.dismiss(animated: true)
        }
        
    }
    
    func alertUserLoginError() {
        let alert = UIAlertController(
            title: "Woops",
            message: "Please enter all information to log in",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
        present(alert, animated: true)
    }
    
    @objc private func didTapRegister() {
        let RVC = RegisterViewController()
        RVC.title = "Create Account"
        navigationController?.pushViewController(RVC, animated: true)
    }

}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == emailField {
            passwordField.becomeFirstResponder()
        }
        else if textField == passwordField {
            loginButtonTapped()
        }
        
        return true
    }
}

extension LoginViewController: LoginButtonDelegate {
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginKit.FBLoginButton) {
        // no operation
    }
    
    func loginButton(_ loginButton: FBSDKLoginKit.FBLoginButton, didCompleteWith result: FBSDKLoginKit.LoginManagerLoginResult?, error: Error?) {
        guard let token = result?.token?.tokenString else {
            print("user failed to login with facebook ")
            return
        }
        
        let facebookRequest = FBSDKLoginKit.GraphRequest(
            graphPath: "me",
            parameters: ["fields": "email, name"],
            tokenString: token,
            version: nil,
            httpMethod: .get
        )
        
        facebookRequest.start(completion: { _, result, error in
            guard let result = result as? [String: Any], error == nil else {
                print("failed to make facebook graph request")
                return
            }
            
            
            guard let userName = result["name"] as? String,
                  let email = result["email"] as? String else {
                print("failed to get name and email from fb result")
                return
            }
            let nameComponents = userName.components(separatedBy: " ")
            guard nameComponents.count == 2 else {
                 return
            }
            let firstName = nameComponents[0]
            let lastName = nameComponents[1]
            
            DatabaseManager.shared.userExists(with: email) { exists in
                if !exists {
                    DatabaseManager.shared.insertUser(
                        with:
                            ChapAppUser(
                                firstName: firstName,
                                lastName: lastName, emailAddress: email))
                }
            }
            
            let credential = FacebookAuthProvider.credential(withAccessToken: token)
            FirebaseAuth.Auth.auth().signIn(with: credential, completion: {[weak self] authResult, error in
                guard let strongSelf = self else {
                    return
                }
                guard authResult != nil, error == nil else {
                    if let error = error {
                        print("fc credential login failed MFA needed - \(error)")
                    }
                    return
                }
                print("succesfully logged user in")
                strongSelf.navigationController?.dismiss(animated: true)
            })
        })
        
    }
    
}
