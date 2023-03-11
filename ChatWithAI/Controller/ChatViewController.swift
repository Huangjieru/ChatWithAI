//
//  ChatViewController.swift
//  ChatWithAI
//
//  Created by jr on 2023/2/27.
//

import UIKit

class ChatViewController: UIViewController {

    @IBOutlet weak var userMessageTextField: UITextField!
    @IBOutlet weak var stackView: UIStackView!
    
    @IBOutlet weak var stackViewBottomConstraint: NSLayoutConstraint!
    var content = [Content]()
    var openAPIResponse:OpenAPIResponse?
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Talking Time 💬"
        
        tableView.delegate = self
        tableView.dataSource = self
        userMessageTextField.delegate = self
        
        let chatgptTableViewCellXib = UINib(nibName: "ChatgptTableViewCell", bundle: nil)
        tableView.register(chatgptTableViewCellXib, forCellReuseIdentifier: "chatgptCell")
        let userTableViewCellXib = UINib(nibName: "UserTableViewCell", bundle: nil)
        tableView.register(userTableViewCellXib, forCellReuseIdentifier: "userCell")
        
        setupKeyboard()
        
        view.backgroundColor = .systemGray5
        
    }

    public func printAll(_ message: String, file: String = #file, line: Int = #line ) {
        let now:Date = Date()
        let dateFormat:DateFormatter = DateFormatter()
        dateFormat.dateFormat = "HH:mm:ss"
        let dateString:String = dateFormat.string(from: now)
        let file = (file as NSString).lastPathComponent
        print("[\(file)] [\(line)] [\(dateString)]:\(message)")
    }
    //按下傳送按鈕
    @IBAction func sendMessage(_ sender: UIButton) {
        //將輸入的訊息加進content陣列裡
        content.append(Content(name: .user, text: userMessageTextField.text ?? ""))
        //按下傳送按鈕後，抓取API資料
        APICaller.shared.fetchChatGPTAPI(prompt: userMessageTextField.text ?? "")
        { [weak self]
            openAPIResponse
            in
            DispatchQueue.main.async
            {
                self?.openAPIResponse = openAPIResponse
                let choicesText = openAPIResponse.choices[0].text
                print(choicesText)
                self?.content.append(Content(name: .chapgpt, text: choicesText))
                self?.tableView.reloadData() //更新資料
                //讓句子出現在最底層的對話中
                let contentCount = (self?.content.count ?? 1) - 1
                let indexPath = IndexPath(row: contentCount, section: 0)
                self?.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
            }
            
        }
        userMessageTextField.text = "" //按下傳送按鈕後，textField輸入前先清空文字
        self.tableView.reloadData() //按下傳送按鈕，將傳入的文字更新table資料並顯示在畫面上
        //句子出現在最底層的對話中
        let indexPath = IndexPath(row: content.count-1, section: 0)
        self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
    //鍵盤觀察器
   private func setupKeyboard(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
       NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
       
    }
    @objc func keyboardWillShow(notification:NSNotification){
        print("鍵盤彈出通知\(notification)")
        if let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] ?? 0) as? NSValue  {
            printAll("Do keyboardWillShow")
            
            //取得鍵盤高度（CGFloat)
            let keyboardSize = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardSize.height
        
            //鍵盤上方Y的位置
            let keyboardTopY =  self.view.frame.size.height - keyboardHeight
            print("鍵盤高度：\(keyboardHeight), 鍵盤上方Y位置：\(keyboardTopY)")
            
            //stackView下方Y的位置
            let stackViewBottomY = stackView.frame.origin.y + stackView.frame.size.height
            print("stackViewＹ的位置\(stackView.frame.origin.y),stackView底部Y值\(stackViewBottomY)")
            //剩餘空間（在stackView底部與view底部的距離）
            let bottomSpace = self.view.frame.size.height - stackViewBottomY
            print("剩餘空間：\(bottomSpace)")
            //假設要輸入的地方被鍵盤遮住(鍵盤位置高於輸入框)
                if keyboardTopY < stackViewBottomY{
                   
                    stackViewBottomConstraint.constant = keyboardHeight - bottomSpace/2
                    
                    print("移動\(String(describing: stackViewBottomConstraint))")
                }
        }
    
    }
    @objc func keyboardWillHide(){
        stackViewBottomConstraint.constant = 0
    }
}

//MARK: - TableView
extension ChatViewController:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return content.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let showContent = content[indexPath.row]
            if showContent.name == .chapgpt
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
    }
    
}
