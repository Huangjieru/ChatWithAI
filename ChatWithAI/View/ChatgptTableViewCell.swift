//
//  ChatgptTableViewCell.swift
//  ChatWithAI
//
//  Created by jr on 2023/2/27.
//

import UIKit

class ChatgptTableViewCell: UITableViewCell {

    @IBOutlet weak var chatgptImageView: UIImageView!
    
    @IBOutlet weak var chatgptLabel: UILabel!
    
    @IBOutlet weak var chatgptTextView: UITextView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateChatGPTUI(){
        chatgptImageView.layer.cornerRadius = 15
        chatgptTextView.layer.cornerRadius = 15
    }
    
}
