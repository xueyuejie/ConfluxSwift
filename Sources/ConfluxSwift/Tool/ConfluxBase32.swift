//
//  ConfluxBase32.swift
//  
//
//  Created by 薛跃杰 on 2023/3/10.
//

import Foundation
import Base32Swift

public struct ConfluxBase32 {
    static let CONFLUX_CHARSET = ["a","b","c","d","e","f","g","h","j","k","m","n","p","r","s","t","u","v","w","x","y","z","0","1","2","3","4","5","6","7","8","9"]
    static let STANDARD_CHARSET = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","2","3","4","5","6","7"]
    
    public static func encode(_ data: Data) -> String {
        return fromStandard(standardBase32Str: base32Encode(data.bytes))
    }
    
    public static func decode(_ base32Str: String) -> Data? {
        if isValid(base32Str: base32Str) {
            return nil
        }
        let rawbase32Str = toStandard(base32Str: base32Str)
        guard let bytes = base32Decode(rawbase32Str) else {
            return nil
        }
        return Data(bytes)
    }
    
    public static func decodeWords(base32Words: String) -> Data? {
        if !isValid(base32Str: base32Words) {
            return nil
        }
        var result = Data(count: base32Words.count)
        for i in 0..<base32Words.count {
            let index = base32Words.index(base32Words.startIndex, offsetBy: i)
            let num = CONFLUX_CHARSET.firstIndex(of: "\(base32Words[index])")!
            result[i] = UInt8(num)
        }
        return result
    }
    
    public static func isValid(base32Str: String) -> Bool {
        if base32Str.isEmpty {return false}
        for c in base32Str {
            if !CONFLUX_CHARSET.contains("\(c)") {
                return false
            }
        }
        return true
    }
    
    private static func toStandard(base32Str: String) -> String {
        var result = ""
        for c in base32Str {
            let index = STANDARD_CHARSET.firstIndex(of: "\(c)")!
            result = "\(result)\(CONFLUX_CHARSET[index])"
        }
        return result
    }
    
    private static func fromStandard(standardBase32Str: String) -> String {
        var result = ""
        for c in standardBase32Str {
            if c == "=" {
                break
            }
            let index = STANDARD_CHARSET.firstIndex(of: "\(c)")!
            result = "\(result)\(CONFLUX_CHARSET[index])"
        }
        return result
    }
}
