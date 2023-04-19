//
//  RegisterViewController.swift
//  ChatWithAI
//
//  Created by jr on 2023/3/10.
//

import UIKit
import PhotosUI //PhPickerViewController
import FirebaseAuth
import FirebaseStorage

class RegisterViewController: UIViewController {
    
    private var scrollView:UIScrollView = {
        let scrollView = UIScrollView()
        //        scrollView.clipsToBounds = true //剪裁超出父视图范围的子视图部分。在 UIScrollView 中，它的默认值是 YES
        return scrollView
    }()
    
    private let iconImageView:UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person.circle")
        imageView.tintColor = .gray
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true //imageView.clipsToBounds = true效果相同(裁切)
        imageView.layer.borderWidth = 3
        imageView.layer.borderColor = UIColor.link.cgColor
        return imageView
    }()
    
    private let firstName:UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 15
        field.layer.borderWidth = 2
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "First Name"
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        return field
    }()
    
    private let lastName:UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 15
        field.layer.borderWidth = 2
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Last Name"
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        return field
    }()
    
    private let emailField:UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no //測你所輸入的文字，列出相依性高的單字們(https://ithelp.ithome.com.tw/articles/10220888)
        field.keyboardType = .emailAddress //適用輸入 Email 的鍵盤
        field.returnKeyType = .continue //鍵盤上的 return改成continune
        field.layer.cornerRadius = 15
        field.layer.borderWidth = 2
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Email Address"
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))//text field 的左邊加上想呈現的內容->形成左邊padding空間變大10
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
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))//text field 的左邊加上想呈現的內容->形成左邊padding空間變大10
        field.leftViewMode = .always //永遠顯示
        field.backgroundColor = .white //輸入背景變白色
        field.isSecureTextEntry = true
        return field
    }()
    
    private let registerButton: UIButton = {
       let button = UIButton()
        button.setTitle("Register", for: .normal)
        button.backgroundColor = .systemMint
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
//        button.layer.masksToBounds = true //CALayer的属性
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Register Account"
        registerButton.addTarget(self, action: #selector(registerButtonTapped), for: .touchUpInside)
        firstName.delegate = self
        lastName.delegate = self
        emailField.delegate = self
        passwordField.delegate = self
        
        // Add subview
        view.addSubview(scrollView)
        scrollView.addSubview(iconImageView)
        scrollView.addSubview(firstName)
        scrollView.addSubview(lastName)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(registerButton)
        //可點選imageView
        iconImageView.isUserInteractionEnabled = true
        scrollView.isUserInteractionEnabled = true
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapChangeProfilePic))
        iconImageView.addGestureRecognizer(gesture)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        dismissKeyboardFromBackground()
    }
    
    @objc func keyboardWillShow(notification:NSNotification){
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue{
            let keyboardSize = keyboardFrame.cgRectValue
            let keyboardHight = keyboardSize.height
            
            let keyboardTopY = self.view.frame.height - keyboardHight
            
            let registerButtonBottomY = self.registerButton.frame.size.height + self.registerButton.frame.origin.y
            if registerButtonBottomY > keyboardTopY{
                print("registerButtonBottomY:\(registerButtonBottomY), keyboardTopY:\(keyboardTopY)")
                scrollView.frame.origin.y = -keyboardTopY/2 + 10
            }
            
        }
    }
    @objc func keyboardWillHide(){
        scrollView.frame.origin.y = 0
    }
    
    //點背景退鍵盤
    func dismissKeyboardFromBackground(){
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        //tapGesture.cancelsTouchesInView = false //如果有didSelectRowAt會造成衝突，有didSelectRowAt在把cancelsTouchesInView變成false即可
        scrollView.addGestureRecognizer(tapGesture)
    }

    @objc func dismissKeyboard(){
        self.scrollView.endEditing(true)
    }
    
    //點選imageView跳出選單(sheet)
    @objc private func didTapChangeProfilePic(){
        print("Change pic called")
        presentPhotoActionSheet()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        let imageSize = view.width/3
        iconImageView.frame = CGRect(x: (scrollView.width-imageSize)/2,
                                     y: 20,
                                     width: imageSize + 20,
                                     height: imageSize + 20)
        iconImageView.layer.cornerRadius = iconImageView.width/2 //圓形頭像
        firstName.frame = CGRect(x: 40,
                                  y: iconImageView.bottom + 40,
                                  width: scrollView.width-80,
                                  height: 50)
        lastName.frame = CGRect(x: 40,
                                  y: firstName.bottom + 20,
                                  width: scrollView.width-80,
                                  height: 50)
        emailField.frame = CGRect(x: 40,
                                  y: lastName.bottom + 20,
                                  width: scrollView.width-80,
                                  height: 50)
        passwordField.frame = CGRect(x: 40,
                                     y: emailField.bottom + 20,
                                     width: scrollView.width-80,
                                     height: 50)
        
        registerButton.frame = CGRect(x: 40,
                                     y: passwordField.bottom + 20,
                                     width: scrollView.width-80,
                                     height: 50)
    }
    
    //按下register按鈕時確認輸入的資料是否完整
    @objc private func registerButtonTapped(){
        firstName.resignFirstResponder()
        lastName.resignFirstResponder()
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
        guard let firstName = firstName.text, let lastName = lastName.text, let email = emailField.text, let password = passwordField.text, !firstName.isEmpty, !lastName.isEmpty, !email.isEmpty, !password.isEmpty, password.count >= 6 else {
            alertUserLoginError()
            return
        }
        // Firebase log in
        DatabaseManager.shared.userExists(with: email,completion:
        { [weak self] exists in
            print("註冊存在否:\(exists)")
            guard let strongSelf = self else {
                return
            }
            //user already exists
            guard !exists  else{
                //alert帳號已存在
                strongSelf.alertUserLoginError(message:"This email address already exists.")
                return
            }
                FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                    
                guard authResult != nil, error == nil else {
                    print("Error creating user:\(String(describing: error?.localizedDescription))")
                    return
                }
                  //上傳註冊資料、照片到realtime database
                    DatabaseManager.shared.uploadPhoto(image: self?.iconImageView.image) { result in
                        switch result{
                        case .success(let url):
                            let imageUrlString = url.absoluteString
                            print("圖片路徑:\(url)")
                            //entry the database
                            DatabaseManager.shared.insertUser(with: ChatAppUser(firstName: firstName, lastName: lastName, emailAddress: email,profilePictureUrl: imageUrlString))

                        case .failure(let error):
                            print(error)
                        }
                    }

                    self?.navigationController?.dismiss(animated: false)
                    
                }

        })
    }
    private func alertUserLoginError(message:String = "Please enter all information to create a new account"){
        let alert = UIAlertController(title: "Oops!", message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
        present(alert, animated: true)
        
    }
    
    //MARK: - Upload Photo
    
    
}

extension RegisterViewController:UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField{
        case firstName:
            lastName.becomeFirstResponder()
        case lastName:
            emailField.becomeFirstResponder()
        case emailField:
            passwordField.becomeFirstResponder()
        case passwordField:
            registerButtonTapped()
        default:
            return true
        }
        return true
    }
}
//拍照、選照片
extension RegisterViewController:UIImagePickerControllerDelegate, UINavigationControllerDelegate,PHPickerViewControllerDelegate{
    
    
    //跳出選單
    func presentPhotoActionSheet(){
        let actionSheet  = UIAlertController(title: "Profile Picture", message: "How would you like to select a picture?", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        actionSheet.addAction(UIAlertAction(title: "Take Photo", style: .default,handler: { [weak self] _ in
            self?.presentCamer()
        }))
        actionSheet.addAction(UIAlertAction(title: "Choose Photo", style: .default,handler: { [weak self] _ in
            self?.presentPhotoPicker()
        }))
        present(actionSheet, animated: true)
    }
    
    func presentCamer(){
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    func presentPhotoPicker(){
        var configuration = PHPickerConfiguration()
        configuration.filter = .images //PHPickerConfiguration 的 filter 預設為 nil，代表可以選擇照片跟影片。
        configuration.selectionLimit = 1 //預設只能選一張照片(此行可寫可不寫)
        let picker = PHPickerViewController(configuration: configuration) //預設只能選一張照片
        
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print(info)
        guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {return} //編輯過後的照片
        self.iconImageView.image = selectedImage
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    //相簿選一張照片
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult])
    {
        picker.dismiss(animated: true)
        
        let itemProviders = results.map { $0.itemProvider } //選擇照片的結果在帶在型別 [PHPickerResult] 的參數 results 裡，從 PHPickerResult 的 itemProvider 可載入選擇的照片，得到型別 [NSItemProvider] 的 array。
        //使用者選擇的照片數量。先檢查 itemProviders.first 是否有值。loadObject(ofClass:completionHandler:) 載入照片
        if let itemProvider = itemProviders.first, itemProvider.canLoadObject(ofClass: UIImage.self)
        {
            let previousImage = self.iconImageView.image
            itemProvider.loadObject(ofClass: UIImage.self)
            {
                [weak self] image, error
                in
                DispatchQueue.main.async
                {
                    guard let self = self, let image = image as? UIImage, self.iconImageView.image == previousImage else {return}
                    self.iconImageView.image = image
                }
            }
        }
    }
}
