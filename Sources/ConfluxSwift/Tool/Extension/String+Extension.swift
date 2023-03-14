//
//  String+Extension.swift
//  
//
//  Created by 薛跃杰 on 2023/3/13.
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
}
