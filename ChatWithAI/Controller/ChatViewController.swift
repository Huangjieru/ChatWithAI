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
    var userEmail = Auth.auth().currentUser?.email?.replacingOccurrences(of: ".", with: "-").replacingOccurrences(of: "@", with: "-")
    var isLogin = false
    
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
        
        //讀出數據資料（會顯示在firebase的即時資料庫裡）
        //        DatabaseManager.shared.test()
        validateAuth()
        
        //登出button在navigation的右方
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Logout", style: .done, target: self, action: #selector(logout))
        
        if isLogin == true{
            //從firebase realtime資料庫讀取使用者的first name
                DatabaseManager.shared.fetchUserInfo(with: self.userEmail ?? "")
                { snapshotDic in
                    if let userInfo = snapshotDic.value(forKey: "first_name") {
                        
                        self.firstName = userInfo as? String
                            print("主頁取得資料：\(String(describing: self.firstName))")
                        }
                }
            
            loadConversations(with: userEmail ?? "")
        }else{
            print("未登入，抓不到使用者名字")
        }
        print("主頁名字：\(String(describing: self.firstName)),主頁信箱：\(String(describing: userEmail))")
        
    }
    func loadConversations(with user:String)
    {
        self.content = []
        var safeEmail = user.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        
        let ref = Database.database().reference()
        
        ref.child("User").child(safeEmail).child("conversations").observeSingleEvent(of:.value)
        { snapshot in
            if let allSnapshot = snapshot.children.allObjects as? [DataSnapshot]
            {
                for message in allSnapshot{
                    print("message是：\(message),包含:\(message.key.contains("userMessage"))")
                    if message.key.contains("userMessage"){
                        self.content.append(Content(name: "\(self.firstName)", text: message.value as! String))
                        
//                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                            //讓句子出現在最底層的對話中
                            let contentCount = (self.content.count ) - 1
                            let indexPath = IndexPath(row: contentCount, section: 0)
                            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
//                        }
                        
                        print("user的key:\(message.key),user訊息值:\(String(describing: message.value))")
                    }
                    else if message.key.contains("chatgptMessage")
                    {
                        self.content.append(Content(name: "chatgpt", text: message.value as! String))
                        
//                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                            //讓句子出現在最底層的對話中
                            let contentCount = (self.content.count ) - 1
                            let indexPath = IndexPath(row: contentCount, section: 0)
                            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
//                        }
                        
                        print("chatGPT的key:\(message.key),chatgpt訊息值:\(String(describing: message.value))")
                    }
                        
                }
     
            }
            
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        /*
         let isLoggIn = UserDefaults.standard.bool(forKey: "logged_In")
         if !isLoggIn{
         let loggInVC = LoginViewController()
         let loggInNav = UINavigationController(rootViewController: loggInVC)
         loggInNav.modalPresentationStyle = .fullScreen
         present(loggInNav, animated: false)
         }*/
//        validateAuth()
        
        
    }
    
    //判斷是否登入
    private func validateAuth(){
        if FirebaseAuth.Auth.auth().currentUser == nil
        {
            let vc = LoginViewController()
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: false)
        }
        else
        {
            isLogin = true
            
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
    var choicesText:String?
    @IBAction func sendMessage(_ sender: UIButton) {
        
            //將輸入的訊息加進content陣列裡
        content.append(Content(name: "\(firstName ?? "")", text: userMessageTextField.text ?? ""))
        
//        DatabaseManager.shared.insertUserContent(with: userEmail ?? "", message: userMessageTextField.text  ?? "")
            //抓chatgpt API
            
            APICaller.shared.fetchChatGPTAPI(prompt: userMessageTextField.text ?? "")
            { [weak self]
                openAPIResponse
                in
                DispatchQueue.main.async
                {
                    self?.openAPIResponse = openAPIResponse
                    self?.choicesText = openAPIResponse.choices[0].text
//                    print("ChatgptContent:\(self?.choicesText)")
                    //存入database
//                    DatabaseManager.shared.insertChatgptContent(with: self?.userEmail ?? "", message: choicesText)
                    self?.content.append(Content(name: "chatgpt", text: self?.choicesText ?? "" ))
                    
                    self?.tableView.reloadData() //更新資料
                    //讓句子出現在最底層的對話中
                    let contentCount = (self?.content.count ?? 1) - 1
                    let indexPath = IndexPath(row: contentCount, section: 0)
                    self?.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
                    
                }
                
            }
        
        DatabaseManager.shared.insertUserContent(with: Message(account: "\(userEmail ?? "")", userMessage: userMessageTextField.text  ?? "", chatgptMessage: choicesText ?? ""))
        print("是否有值ChatgptContent:\(choicesText)")
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

        
        if showContent.name == "chatgpt"
            {
                let chatgptCell = tableView.dequeueReusableCell(withIdentifier: "chatgptCell") as! ChatgptTableViewCell
//                print(showContent.name.rawValue)
                chatgptCell.chatgptTextView.text = showContent.text
                chatgptCell.chatgptLabel.text = showContent.name
                chatgptCell.chatgptImageView.image = UIImage(named: "chatgpt")
                chatgptCell.updateChatGPTUI()
                
                return chatgptCell
            }
        else{
                let userCell = tableView.dequeueReusableCell(withIdentifier: "userCell") as! UserTableViewCell
//                print(showContent.name.rawValue)
                userCell.userLabel.text = showContent.name
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
