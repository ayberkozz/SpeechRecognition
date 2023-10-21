//
//  ViewController.swift
//  SpeechRecognition
//
//  Created by Ayberk Öz on 21.10.2023.
//

import UIKit
import Speech

class SpeechRecogScreen: UIViewController {
    
    private let audioEngine = AVAudioEngine()
    private var speechRecognizer: SFSpeechRecognizer? = SFSpeechRecognizer(locale: Locale.init(identifier: "tr"))
    private let request = SFSpeechAudioBufferRecognitionRequest()
    private var recognitionTask : SFSpeechRecognitionTask?
    
    private let VStack = UIStackView()
    private let speechLabel = UILabel()
    private let speechButton = UIButton()
    private let speechStopButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        style()
        layout()
    }
    
}

//MARK: - Funcs
extension SpeechRecogScreen {
    
    @objc private func SpeechButtonTapped() {
        recordAndRecognizeSpeech()
    }
    
    @objc private func SpeechStopButtonTapped() {
        stopRecording()
    }
    
    func ShowAlert(alertModel: SpeechErrorAlertModel) {
        let alert = UIAlertController(title: alertModel.titleText, message: alertModel.description, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func ButtonColorAdjustment(sender:UIButton,DefaultColor: UIColor,isEnable:Bool){
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
    
    private func style() {
        view.backgroundColor = .white
        
        speechLabel.translatesAutoresizingMaskIntoConstraints = false
        speechLabel.text = "Your speech will show here when you start recording!"
        speechLabel.textColor = .black
        speechLabel.textAlignment = .center
        speechLabel.numberOfLines = 0
        
        VStack.translatesAutoresizingMaskIntoConstraints = false
        VStack.axis = .vertical
        VStack.distribution = .fillEqually
        VStack.spacing = 10
        
        speechButton.translatesAutoresizingMaskIntoConstraints = false
        speechButton.setTitle("Tap to Recording Your Speech", for: .normal)
        ButtonColorAdjustment(sender: speechButton, DefaultColor: .blue, isEnable: true)
        speechButton.addTarget(self, action: #selector(SpeechButtonTapped), for: .touchUpInside)
        speechButton.layer.cornerRadius = 10
        
        speechStopButton.translatesAutoresizingMaskIntoConstraints = false
        speechStopButton.setTitle("Tap to Stop Recording Your Speech", for: .normal)
        ButtonColorAdjustment(sender: speechStopButton, DefaultColor: .red, isEnable: false)
        speechStopButton.addTarget(self, action: #selector(SpeechStopButtonTapped), for: .touchUpInside)
        speechStopButton.layer.cornerRadius = 10
    }
    
    private func layout() {
        
        view.addSubview(speechLabel)
        
        view.addSubview(VStack)
        
        VStack.addArrangedSubview(speechButton)
        VStack.addArrangedSubview(speechStopButton)

        NSLayoutConstraint.activate([
            
            speechLabel.topAnchor.constraint(equalToSystemSpacingBelow: view.safeAreaLayoutGuide.topAnchor, multiplier: 2),
            speechLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            speechLabel.widthAnchor.constraint(equalToConstant: view.frame.width / 1.1),
 
            VStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            VStack.widthAnchor.constraint(equalToConstant: view.frame.width / 1.1),
            VStack.bottomAnchor.constraint(equalToSystemSpacingBelow: view.safeAreaLayoutGuide.bottomAnchor, multiplier: -2),
            VStack.heightAnchor.constraint(equalToConstant: view.frame.height / 5),
            
            speechButton.widthAnchor.constraint(equalToConstant: view.frame.width / 1.1),
            
            speechStopButton.widthAnchor.constraint(equalToConstant: view.frame.width / 1.1),
        ])
        
    }
    
}

//MARK: - Speech Recognizer Delegate
extension SpeechRecogScreen: SFSpeechRecognizerDelegate {
    
    private func recordAndRecognizeSpeech() {
        
        ButtonColorAdjustment(sender: speechButton, DefaultColor: .blue, isEnable: false)
        ButtonColorAdjustment(sender: speechStopButton, DefaultColor: .red, isEnable: true)
        speechLabel.text = "..."
        
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, _ in
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
            ShowAlert(alertModel: SpeechErrorAlert.LocaleIssue)
            return
        }
        
        guard myRecognizer.isAvailable else {
            ShowAlert(alertModel: SpeechErrorAlert.RecognizerIssue)
            return
        }
        
        
        recognitionTask = speechRecognizer?.recognitionTask(with: request, resultHandler: { [weak self] result, _ in
            if let result = result {
                let bestString = result.bestTranscription.formattedString
                DispatchQueue.main.async {
                    self?.speechLabel.text = bestString
                }
            } else {
                self?.ShowAlert(alertModel: SpeechErrorAlert.HandleIssue)
            }
        })
        
    }
    
    private func stopRecording() {
        self.audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        
        self.speechRecognizer = nil
        self.recognitionTask = nil
        
        ButtonColorAdjustment(sender: speechButton, DefaultColor: .blue, isEnable: true)
        ButtonColorAdjustment(sender: speechStopButton, DefaultColor: .red, isEnable: false)
        self.speechLabel.text = "Your speech will show here when you start recording!"
    }
    
}

