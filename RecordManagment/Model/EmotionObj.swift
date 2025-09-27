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
    
    // 서버 Emotion String 값을 enum 값에 맞게 변환
    static func matchingEmotion(_ emotion: String) -> EmotionObj {
        switch emotion {
            case "Normal":
                return .normal
            case "Happy":
                return .happy
            case "Peaceful":
                return .peaceful
            case "Funny":
                return .funny
            case "Love":
                return .love
            case "Tired":
                return .tired
            case "Panic":
                return .panic
            case "Sad":
                return .sad
            case "Angry":
                return .angry
            default:
                return .normal
        }
    }
}
