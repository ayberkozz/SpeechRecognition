//
//  SpeechScreenViewModel.swift
//  SpeechRecognition
//
//  Created by Ayberk Öz on 22.10.2023.
//

import Foundation
import Speech
import UIKit

class SpeechScreenViewModel {
    
    weak var output : SpeechScreenVMOutput?
    
    private let audioEngine = AVAudioEngine()
    private var speechRecognizer: SFSpeechRecognizer? = SFSpeechRecognizer(locale: Locale.init(identifier: "tr"))
    private let request = SFSpeechAudioBufferRecognitionRequest()
    private var recognitionTask : SFSpeechRecognitionTask?
    
//    let speechButton : UIButton
//    let speechDefaultColor: UIColor
    
    
    private func ButtonColorAdjustment(sender:UIButton,DefaultColor: UIColor, isEnable:Bool){
        switch isEnable {
        case true:
            DispatchQueue.main.async {
                sender.isEnabled = true
                sender.backgroundColor = DefaultColor
            }
        case false:
            DispatchQueue.main.async {
                sender.isEnabled = false
                sender.backgroundColor = UIColor.gray
            }
        }
    }
    
    func recordAndRecognizeSpeech(speechButton: UIButton,speechDefaultColor: UIColor,speechIsEnable: Bool,speechStopButton: UIButton,StopDefaultColor: UIColor,StopIsEnable: Bool) {
        
        ButtonColorAdjustment(sender: speechButton, DefaultColor: speechDefaultColor, isEnable: speechIsEnable)
        ButtonColorAdjustment(sender: speechStopButton, DefaultColor: StopDefaultColor, isEnable: StopIsEnable)
        output?.speechLabel(speechText: "...")
        
        request.shouldReportPartialResults = true
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        } catch {
            print(error)
        }
        do {
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print(error)
        }
        
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            self?.request.append(buffer)
        }
        
        audioEngine.prepare()
        do {
            try audioEngine.start()
        }
        catch {
            print(error)
        }
        
        guard let myRecognizer = SFSpeechRecognizer() else {
            output?.alert(alert: SpeechErrorAlert.LocaleIssue)
            return
        }
        
        guard myRecognizer.isAvailable else {
            output?.alert(alert: SpeechErrorAlert.RecognizerIssue)
            return
        }
        
        
        recognitionTask = speechRecognizer?.recognitionTask(with: request, resultHandler: { [weak self] result, err in
            
            guard err == nil else {
                self?.output?.alert(alert: SpeechErrorAlert.HandleIssue)
                self?.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self?.recognitionTask = nil
                
                self?.ButtonColorAdjustment(sender: speechButton, DefaultColor: speechDefaultColor, isEnable: !speechIsEnable)
                self?.ButtonColorAdjustment(sender: speechStopButton, DefaultColor: StopDefaultColor, isEnable: !StopIsEnable)
                self?.output?.speechLabel(speechText: "Your speech will show here when you start recording!")
                
                return
            }
            
            if let result = result {
                let bestString = result.bestTranscription.formattedString
                DispatchQueue.main.async {
                    self?.output?.speechLabel(speechText: bestString)
                }
            } else {
                DispatchQueue.main.async {
                    self?.output?.alert(alert: SpeechErrorAlert.HandleIssue)
                }
            }
            
        })
    }
    
    func stopRecording(speechButton: UIButton,speechDefaultColor: UIColor,speechIsEnable: Bool,speechStopButton: UIButton,StopDefaultColor: UIColor,StopIsEnable: Bool) {
        recognitionTask?.finish()
        recognitionTask = nil
        
        request.endAudio()
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        
        DispatchQueue.main.async {
            self.ButtonColorAdjustment(sender: speechButton, DefaultColor: speechDefaultColor, isEnable: speechIsEnable)
            self.ButtonColorAdjustment(sender: speechStopButton, DefaultColor: StopDefaultColor, isEnable: StopIsEnable)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.output?.speechLabel(speechText: "Your speech will show here when you start recording!")
        }
    }
    
}
