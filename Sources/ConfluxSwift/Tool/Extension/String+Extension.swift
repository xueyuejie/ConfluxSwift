//
//  String+Extension.swift
//  
//
//  Created by xgblin on 2023/3/13.
//

import Foundation

extension String {
    func cfxStripHexPrefix() -> String {
        if self.hasPrefix("0x") {
            let indexStart = self.index(self.startIndex, offsetBy: 2)
            return String(self[indexStart...])
        }
        return self
    }
    
    func addPrefix(_ prefix: String) -> String {
        if self.hasPrefix(prefix) {
            return self
        }
        return "\(prefix)\(self)"
    }
}
