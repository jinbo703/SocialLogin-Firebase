//
//  ViewController.swift
//  SocialLogin
//
//  Created by PAC on 5/2/17.
//  Copyright © 2017 PAC. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import Firebase
import GoogleSignIn
import TwitterKit

//@UIApplicationMain
class ViewController: UIViewController, FBSDKLoginButtonDelegate, GIDSignInUIDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupFacebookButtons()
        
        setupGoogleButtons()
        
        setupTwitterButton()
        
    }
    
    fileprivate func setupTwitterButton() {
        
        let twitterButton = TWTRLogInButton { (session, error) in
            
            if let err = error {
                print("Failed to login via Twitter: ", err)
                return
            }
            print("Successfully logged in Twitter")
            
            guard let token = session?.authToken else { return }
            guard let secret = session?.authTokenSecret else { return }
            let credentials = FIRTwitterAuthProvider.credential(withToken: token, secret: secret)
            
            FIRAuth.auth()?.signIn(with: credentials, completion: { (user, err) in
                
                if let err = error {
                    print("Failed to log", err)
                    return
                }
                
                
                
            })
            
        }
        
        view.addSubview(twitterButton)
        twitterButton.frame = CGRect(x: 16, y: 116 + 66 + 66 + 66, width: view.frame.width - 32, height: 50)
        
    }
    
    fileprivate func setupGoogleButtons() {
        
        // add google sign in button
        let googleButton = GIDSignInButton()
        googleButton.frame = CGRect(x: 16, y: 116 + 66, width: view.frame.width - 32, height: 50)
        view.addSubview(googleButton)
        
        let customButton = UIButton(type: .system)
        customButton.frame = CGRect(x: 16, y: 116 + 66 + 66, width: view.frame.width - 32, height: 50)
        customButton.backgroundColor = .orange
        customButton.setTitle("Login with google", for: .normal)
        customButton.addTarget(self, action: #selector(handleCustomGoogleSign), for: .touchUpInside)
        view.addSubview(customButton)
        customButton.setTitleColor(.white, for: .normal)
        customButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        
        GIDSignIn.sharedInstance().uiDelegate = self
        
    }
    
    func handleCustomGoogleSign() {
        
        GIDSignIn.sharedInstance().signIn()
        
    }
    
    fileprivate func setupFacebookButtons() {
        
        let loginBuutton = FBSDKLoginButton()
        
        view.addSubview(loginBuutton)
        
        loginBuutton.frame = CGRect(x: 16, y: 50, width: view.frame.width - 32, height: 50)
        
        loginBuutton.delegate = self
        loginBuutton.readPermissions = ["email", "public_profile"]
        
        
        // add our custom fb login button
        let customFBButton = UIButton(type: .system)
        customFBButton.backgroundColor = .blue
        
        customFBButton.frame = CGRect(x: 16, y: 116, width: view.frame.width - 32, height: 50)
        customFBButton.setTitle("Log in with FaceBook", for: .normal)
        view.addSubview(customFBButton)
        customFBButton.setTitleColor(.white, for: .normal)
        
        customFBButton.addTarget(self, action: #selector(handleCustomFBLogin), for: .touchUpInside)

        
    }
    
    func handleCustomFBLogin() {
        
        FBSDKLoginManager().logIn(withReadPermissions: ["email", "public_profile"], from: self) { (result, err) in
            if err != nil {
                print("FB login failed", err!)
                return
            }
            
//            print(result?.token.tokenString)
            
            self.showEmailAddress()
            
        }
        
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("Did log out of facebook")
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if error != nil {
            print(error)
            return
        }
        
        print("Successfully logged in with facebook...")
        showEmailAddress()
        
    }
    
    func showEmailAddress() {
        
        let accessToken = FBSDKAccessToken.current()
        
        guard let accessTokenString = accessToken?.tokenString else { return }
        
        let credentials = FIRFacebookAuthProvider.credential(withAccessToken: accessTokenString)
        
        FIRAuth.auth()?.signIn(with: credentials, completion: { (user, error) in
            
            if error != nil {
                print("Something went wrong with out FB user: ", error ?? "")
                return
            }
            
            print("Successfully logged in with our usr:", user ?? "")
            
        })
        
        FBSDKGraphRequest(graphPath: "/me", parameters: ["fields": "id, name, email"]).start { (connection, result, err) in
            
            if err != nil {
                print("Failed to start graph request:", err ?? "")
                return
            }
            
            print(result ?? "")
            
        }

    }
    
    
}

