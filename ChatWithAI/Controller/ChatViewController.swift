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
        title = "Talking Time ð¬"
        
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
    //æä¸å³éæé
    @IBAction func sendMessage(_ sender: UIButton) {
        //å°è¼¸å¥çè¨æ¯å é²contenté£åè£¡
        content.append(Content(name: .user, text: userMessageTextField.text ?? ""))
        //æä¸å³éæéå¾ï¼æåAPIè³æ
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
                self?.tableView.reloadData() //æ´æ°è³æ
                //è®å¥å­åºç¾å¨æåºå±¤çå°è©±ä¸­
                let contentCount = (self?.content.count ?? 1) - 1
                let indexPath = IndexPath(row: contentCount, section: 0)
                self?.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
            }
            
        }
        userMessageTextField.text = "" //æä¸å³éæéå¾ï¼textFieldè¼¸å¥ååæ¸ç©ºæå­
        self.tableView.reloadData() //æä¸å³éæéï¼å°å³å¥çæå­æ´æ°tableè³æä¸¦é¡¯ç¤ºå¨ç«é¢ä¸
        //å¥å­åºç¾å¨æåºå±¤çå°è©±ä¸­
        let indexPath = IndexPath(row: content.count-1, section: 0)
        self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
    //éµç¤è§å¯å¨
   private func setupKeyboard(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
       NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
       
    }
    @objc func keyboardWillShow(notification:NSNotification){
        print("éµç¤å½åºéç¥\(notification)")
        if let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] ?? 0) as? NSValue  {
            printAll("Do keyboardWillShow")
            
            //åå¾éµç¤é«åº¦ï¼CGFloat)
            let keyboardSize = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardSize.height
        
            //éµç¤ä¸æ¹Yçä½ç½®
            let keyboardTopY =  self.view.frame.size.height - keyboardHeight
            print("éµç¤é«åº¦ï¼\(keyboardHeight), éµç¤ä¸æ¹Yä½ç½®ï¼\(keyboardTopY)")
            
            //stackViewä¸æ¹Yçä½ç½®
            let stackViewBottomY = stackView.frame.origin.y + stackView.frame.size.height
            print("stackViewï¼¹çä½ç½®\(stackView.frame.origin.y),stackViewåºé¨Yå¼\(stackViewBottomY)")
            //å©é¤ç©ºéï¼å¨stackViewåºé¨èviewåºé¨çè·é¢ï¼
            let bottomSpace = self.view.frame.size.height - stackViewBottomY
            print("å©é¤ç©ºéï¼\(bottomSpace)")
            //åè¨­è¦è¼¸å¥çå°æ¹è¢«éµç¤é®ä½(éµç¤ä½ç½®é«æ¼è¼¸å¥æ¡)
                if keyboardTopY < stackViewBottomY{
                   
                    stackViewBottomConstraint.constant = keyboardHeight - bottomSpace/2
                    
                    print("ç§»å\(String(describing: stackViewBottomConstraint))")
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
        textField.resignFirstResponder() //returnééµç¤
    }
    
}
