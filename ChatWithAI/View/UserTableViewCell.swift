//
//  UserTableViewCell.swift
//  ChatWithAI
//
//  Created by jr on 2023/2/27.
//

import UIKit

class UserTableViewCell: UITableViewCell {

    @IBOutlet weak var userImageView: UIImageView!
    
    @IBOutlet weak var userLabel: UILabel!
    
    @IBOutlet weak var userTextView: UITextView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func updateUserUI(){
        userImageView.layer.cornerRadius = 15
        userTextView.layer.cornerRadius = 15
    }
    
}
