//
//  LoginViewController.swift
//  ChatWithAI
//
//  Created by jr on 2023/3/10.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    
    private let scrollView:UIScrollView = {
        let scrollView = UIScrollView()
//        scrollView.clipsToBounds = true //剪裁超出父视图范围的子视图部分。在 UIScrollView 中，它的默认值是 YES
        return scrollView
    }()
    
    private let iconImageView:UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "chatBubbleIcon")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let emailField:UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none //自動轉成開頭大寫
        field.autocorrectionType = .no //測你所輸入的文字，列出相依性高的單字們(https://ithelp.ithome.com.tw/articles/10220888)
        field.keyboardType = .emailAddress //適用輸入 Email 的鍵盤
        field.returnKeyType = .continue //鍵盤上的 return改成continune
        field.layer.cornerRadius = 15
        field.layer.borderWidth = 2
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Email Address"
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))//讓輸入的文字不會與邊框太貼近，text field 的左邊加上想呈現的內容->形成左邊padding空間變大10
        field.leftViewMode = .always //永遠顯示
        field.backgroundColor = .white //輸入背景變白色
       return field
    }()
    
    private let passwordField:UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .done //鍵盤上的 return改成done
        field.layer.cornerRadius = 15
        field.layer.borderWidth = 2
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Password..."
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))//讓輸入的文字不會與邊框太貼近，text field 的左邊加上想呈現的內容->形成左邊padding空間變大10
        field.leftViewMode = .always //永遠顯示
        field.backgroundColor = .white //輸入背景變白色
        field.isSecureTextEntry = true
       return field
    }()
    
    private let loginButton: UIButton = {
       let button = UIButton()
        button.setTitle("Log In", for: .normal)
        button.backgroundColor = .link
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
//        button.layer.masksToBounds = true //CALayer的属性
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        return button
    }()
    
    private let registerButton:UIButton = {
        let button = UIButton()
        button.setTitle("Register", for: .normal)
        button.setTitleColor(.link, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        title = "Log In"
        
//        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Register", style: .done, target: self, action: #selector(didTapRegister))
        //按下login按鈕下方的註冊也可以連到與右上角按鈕同一個註冊畫面
        registerButton.addTarget(RegisterViewController(), action: #selector(didTapRegister), for: .touchUpInside)
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        
        emailField.delegate = self
        passwordField.delegate = self
        
        // Add subview
        view.addSubview(scrollView)
        scrollView.addSubview(iconImageView)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(loginButton)
        scrollView.addSubview(registerButton)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        let imageSize = view.width/3 //設置extensions檔案
        iconImageView.frame = CGRect(x: (scrollView.width-imageSize)/2,
                                     y: 20,
                                     width: imageSize,
                                     height: imageSize)
        emailField.frame = CGRect(x: 40,
                                  y: iconImageView.bottom + 40,
                                  width: scrollView.width-80,
                                  height: 50)
        passwordField.frame = CGRect(x: 40,
                                  y: emailField.bottom + 20,
                                  width: scrollView.width-80,
                                  height: 50)
        loginButton.frame = CGRect(x: 40,
                                  y: passwordField.bottom + 30,
                                  width: scrollView.width-80,
                                  height: 50)
        registerButton.frame.origin = CGPoint(x: view.center.x - 50, y: loginButton.bottom + 30)
        registerButton.frame.size = CGSize(width: 100, height: 30)
        
    }

    //按下login按鈕時確認輸入的資料是否完整
    @objc private func loginButtonTapped()
    {
        //按下login按鈕後，不會出現鍵盤
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        //判斷輸入是否符合規定
        guard let email = emailField.text, let password = passwordField.text, !email.isEmpty, !password.isEmpty, password.count >= 6 else {
            alertUserLoginError(message: "Please enter all information to log in")
            return
        }
        //確認是否已有帳號
        DatabaseManager.shared.userExists(with: email)
        { [weak self] exists in
            print("exists:\(exists)")
            //帳號已存在
            guard !exists else{
                print("請註冊新帳號")
                self?.alertUserLoginError(message: "Please make a new account.")
                return
            }
            // Firebase log in
            Firebase.Auth.auth().signIn(withEmail: email, password: password)
            { [weak self] authResult, error in
                
                guard let strongSelf = self else{
                    return
                }
                
                guard let result = authResult, error == nil else{
                    print("Failed:\(String(describing: error?.localizedDescription)) and failed to log in with email: \(email)")
                    return
                }
                let user = result.user
                print("Success, logged in User(成功登入): \(String(describing: user.email))")
           
                //Check whether the user is logged in or not.
                if let user = Auth.auth().currentUser
                {
                    print("logged in(已登入):\(user.uid),\(String(describing: user.email)),\(String(describing: user.photoURL))")
                }
                //Receive the login status changes接收登入狀態改變的通知
                FirebaseAuth.Auth.auth().addStateDidChangeListener
                { auth, user in
                    if let user = user
                    {
                        print("\(String(describing: user)) login(要登入)")
  
                        //Dismiss the view 登入成功後退掉畫面
                        strongSelf.navigationController?.dismiss(animated: true)
                    }else{
                        print("not login")
                    }
                }
                
            }
        
        }
    }
        
    
    func alertUserLoginError(message:String){
        let alert = UIAlertController(title: "Oops!", message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
        present(alert, animated: true)
        
    }
    @objc private func didTapRegister(){
        let registerVC = RegisterViewController()
        registerVC.title = "Register Account"
        navigationController?.pushViewController(registerVC, animated: true)
    }

}

extension LoginViewController:UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //使用者按下鍵盤上continue按鈕，可以繼續輸入密碼
        if textField == emailField{
            passwordField.becomeFirstResponder() //focus on password
        }
        //輸入密碼後按下鍵盤上的done等於按下登入按鈕
        else if textField == passwordField{
            loginButtonTapped()
        }
        return true
    }
}
