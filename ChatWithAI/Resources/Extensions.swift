//
//  Extensions.swift
//  ChatWithAI
//
//  Created by jr on 2023/3/13.
//

import Foundation
import UIKit

extension UIView{
    
    public var width:CGFloat{
        return self.frame.size.width
    }
    public var height:CGFloat{
        return self.frame.size.height
    }
    public var top:CGFloat{
        return self.frame.origin.y
    }
    public var bottom:CGFloat{
        return self.frame.origin.y + self.frame.size.height
    }
    public var left:CGFloat{
        return self.frame.origin.x
    }
    public var right:CGFloat{
        return self.frame.origin.x + self.frame.size.width
    }
}
