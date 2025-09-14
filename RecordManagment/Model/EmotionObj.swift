//
//  EmotionObj.swift
//  RecordManagment
//
//  Created by 김용해 on 9/13/25.
//

import Foundation

enum EmotionObj: String, CaseIterable {
    case normal
    case happy
    case peaceful
    case funny
    case love
    case tired
    case panic
    case sad
    case angry
    
    var id: String {
        let fWord = self.rawValue.first!.uppercased()
        let restWord = self.rawValue.dropFirst()
        
        return fWord + restWord
    }
}
