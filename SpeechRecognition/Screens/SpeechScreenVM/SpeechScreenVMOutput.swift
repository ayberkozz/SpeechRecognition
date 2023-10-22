//
//  SpeechScreenVMOutput.swift
//  SpeechRecognition
//
//  Created by Ayberk Öz on 22.10.2023.
//

import Foundation

protocol SpeechScreenVMOutput : AnyObject {
    func speechLabel(speechText: String)
    func alert(alert: SpeechErrorAlertModel)
}
