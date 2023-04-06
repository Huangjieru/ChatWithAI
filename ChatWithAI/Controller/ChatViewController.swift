//
//  ChatViewController.swift
//  ChatWithAI
//
//  Created by jr on 2023/2/27.
//

import UIKit
import FirebaseAuth
import Firebase

class ChatViewController: UIViewController {
    
    @IBOutlet weak var userMessageTextField: UITextField!
    @IBOutlet weak var stackView: UIStackView!
    
    @IBOutlet weak var stackViewBottomConstraint: NSLayoutConstraint!
    var content = [Content]()
    var openAPIResponse:OpenAPIResponse?
    
    var firstName:String?
//    var isLogin = false
   
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemGray5
        
        tableView.delegate = self
        tableView.dataSource = self
        userMessageTextField.delegate = self
        //XIB cell加入畫面裡
        let chatgptTableViewCellXib = UINib(nibName: "ChatgptTableViewCell", bundle: nil)
        tableView.register(chatgptTableViewCellXib, forCellReuseIdentifier: "chatgptCell")
        let userTableViewCellXib = UINib(nibName: "UserTableViewCell", bundle: nil)
        tableView.register(userTableViewCellXib, forCellReuseIdentifier: "userCell")
        //鍵盤遮住輸入格，調整位置
        setupKeyboard()
        //判斷是否已有登入
//        validateAuth()
        
        //登出button在navigation的右方
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Logout", style: .done, target: self, action: #selector(logout))

    }
    
    func loadConversations()
    {
        let ref = Database.database().reference()
        
        let currentUserEmail = Auth.auth().currentUser?.email
        var safeEmail = currentUserEmail?.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail?.replacingOccurrences(of: "@", with: "-")
        
//        DatabaseManager.shared.fetchUserInfo(with: safeEmail ?? "no user email")
//        { snapshotDic in
//            if let userInfo = snapshotDic.value(forKey: "first_name") {
//
//                self.firstName = userInfo as? String
//                    print("主頁取得資料：\(String(describing: self.firstName))")
//                }
//        }
        
        ref.child("User").child(safeEmail ?? "no account").child("conversations").observeSingleEvent(of:.value)
        { snapshot in
            self.content.removeAll()
            
            if let allSnapshot = snapshot.children.allObjects as? [DataSnapshot]
            {
                for message in allSnapshot
                {
                    let message = message.value as? [String:Any]
                    let userMessage = message?["userMessage"]
                    let chatgptMessage = message?["chatgptMessage"]
//                    print("chatgptMessage:\(chatgptMessage)")

                    self.content.append(Content(name: .user, text: userMessage as! String))
                    self.content.append(Content(name: .chatgpt, text: chatgptMessage as! String))

                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        //讓句子出現在最底層的對話中
                        let contentCount = (self.content.count ) - 1
                        let indexPath = IndexPath(row: contentCount, section: 0)
                        self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
                    }
                                            
                }
     
            }
            
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        /*
         let isLoggIn = UserDefaults.standard.bool(forKey: "logged_In")
         if !isLoggIn{
         let loggInVC = LoginViewController()
         let loggInNav = UINavigationController(rootViewController: loggInVC)
         loggInNav.modalPresentationStyle = .fullScreen
         present(loggInNav, animated: false)
         }*/
        validateAuth()
    }
    
    //判斷是否登入
    private func validateAuth(){
        self.content.removeAll()
        if FirebaseAuth.Auth.auth().currentUser == nil
        {
            let vc = LoginViewController()
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: false)
        }
        else
        {
//            isLogin = true
            print("isLogin")
            self.loadConversations()
            
        }
    }
    /*
     //MARK: - Debug
     public func printAll(_ message: String, file: String = #file, line: Int = #line ) {
     let now:Date = Date()
     let dateFormat:DateFormatter = DateFormatter()
     dateFormat.dateFormat = "HH:mm:ss"
     let dateString:String = dateFormat.string(from: now)
     let file = (file as NSString).lastPathComponent
     print("[\(file)] [\(line)] [\(dateString)]:\(message)")
     }*/
    
    //MARK: - Send Message
    //按下傳送按鈕

    @IBAction func sendMessage(_ sender: UIButton) {
        let userMessage = userMessageTextField.text ?? "no message"
            //將輸入的訊息加進content陣列裡
//        content.append(Content(name: "\(firstName ?? "")", text: userMessage))
        content.append(Content(name: .user, text: userMessage))
        
            //抓chatgpt API
            APICaller.shared.fetchChatGPTAPI(prompt: userMessage)
            { [weak self]
                openAPIResponse
                in
                DispatchQueue.main.async
                {
                    self?.openAPIResponse = openAPIResponse
                    let choicesText = openAPIResponse.choices[0].text
//                    print("ChatgptContent:\(self?.choicesText)")

                    self?.content.append(Content(name: .chatgpt, text: choicesText ))
                    //存入database
                    let currentUserEmail = Auth.auth().currentUser?.email
                     var safeEmail = currentUserEmail?.replacingOccurrences(of: ".", with: "-")
                     safeEmail = safeEmail?.replacingOccurrences(of: "@", with: "-")
                    DatabaseManager.shared.insertContent(with: Message(account: safeEmail ?? "no user account", userMessage: userMessage, chatgptMessage: choicesText ))

                    self?.tableView.reloadData() //更新資料
                    //讓句子出現在最底層的對話中
                    let contentCount = (self?.content.count ?? 1) - 1
                    let indexPath = IndexPath(row: contentCount, section: 0)
                    self?.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
                    
                }
                
            }

            userMessageTextField.text = "" //按下傳送按鈕後，textField輸入前先清空文字
            self.tableView.reloadData() //按下傳送按鈕，將傳入的文字更新table資料並顯示在畫面上
            view.endEditing(true) //按下傳送按鈕後退鍵盤
            //句子出現在最底層的對話中
            let indexPath = IndexPath(row: content.count-1, section: 0)
            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }

    @objc private func logout(){
        do{
            try FirebaseAuth.Auth.auth().signOut()
            content.removeAll()
            let vc = LoginViewController()
            let navi = UINavigationController(rootViewController: vc)
            navi.modalPresentationStyle = .fullScreen
            present(navi, animated: false)
        }
        catch{
            print("登出失敗\(error)")
        }
    }
        
        //鍵盤觀察器
        private func setupKeyboard(){
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
            
        }
        @objc func keyboardWillShow(notification:NSNotification){
            //        print("鍵盤彈出通知\(notification)")
            if let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] ?? 0) as? NSValue  {
                //            printAll("Do keyboardWillShow")
                
                //取得鍵盤高度（CGFloat)
                let keyboardSize = keyboardFrame.cgRectValue
                let keyboardHeight = keyboardSize.height
                
                //鍵盤上方Y的位置
                let keyboardTopY =  self.view.frame.size.height - keyboardHeight
                //            print("鍵盤高度：\(keyboardHeight), 鍵盤上方Y位置：\(keyboardTopY)")
                
                //stackView下方Y的位置
                let stackViewBottomY = stackView.frame.origin.y + stackView.frame.size.height
                //            print("stackViewＹ的位置\(stackView.frame.origin.y),stackView底部Y值\(stackViewBottomY)")
                //剩餘空間（在stackView底部與view底部的距離）
                let bottomSpace = self.view.frame.size.height - stackViewBottomY
                //            print("剩餘空間：\(bottomSpace)")
                //假設要輸入的地方被鍵盤遮住(鍵盤位置高於輸入框)
                if keyboardTopY < stackViewBottomY{
                    
                    stackViewBottomConstraint.constant = keyboardHeight - bottomSpace/2
                    
                    //                    print("移動\(String(describing: stackViewBottomConstraint))")
                }
            }
            
        }
        @objc func keyboardWillHide(){
            stackViewBottomConstraint.constant = 0
        }
        
        //按textView可以退鍵盤
        override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            tableView.endEditing(true)
        }
    }

//MARK: - TableView
extension ChatViewController:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return content.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let showContent = content[indexPath.row]
   
        if showContent.name == .chatgpt
            {
                let chatgptCell = tableView.dequeueReusableCell(withIdentifier: "chatgptCell") as! ChatgptTableViewCell
//                print(showContent.name.rawValue)
                chatgptCell.chatgptTextView.text = showContent.text
            chatgptCell.chatgptLabel.text = showContent.name.rawValue
                chatgptCell.chatgptImageView.image = UIImage(named: "chatgpt")
                chatgptCell.updateChatGPTUI()
                
                return chatgptCell
            }
        else{
                let userCell = tableView.dequeueReusableCell(withIdentifier: "userCell") as! UserTableViewCell
//                print(showContent.name.rawValue)
            userCell.userLabel.text = showContent.name.rawValue
                userCell.userTextView?.text = showContent.text
                userCell.userImageView.image = UIImage(systemName: "person.crop.circle")
                userCell.updateUserUI()
                return userCell
            }
    }

}
//MARK: - TextField
extension ChatViewController:UITextFieldDelegate{
   
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() //return退鍵盤
        return true
    }
    
}
