//
//  SpeechErrors.swift
//  SpeechRecognition
//
//  Created by Ayberk Öz on 21.10.2023.
//

import Foundation
import UIKit

struct SpeechErrorAlertModel {
    let titleText : String
    let description : String
}

struct SpeechErrorAlert {
    static let RecognizerIssue = SpeechErrorAlertModel(titleText: "Oops!", description: "Recognizer weren't ready")
    static let LocaleIssue = SpeechErrorAlertModel(titleText: "Oops!", description: "Speech Recognition App is not available in your region")
    static let HandleIssue = SpeechErrorAlertModel(titleText: "Oops!", description: "We can't handle your speech")
}


