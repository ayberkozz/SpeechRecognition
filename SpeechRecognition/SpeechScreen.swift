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
    private let speechRecognizer: SFSpeechRecognizer? = SFSpeechRecognizer()
    private let request = SFSpeechAudioBufferRecognitionRequest()
    private var recognitionTask : SFSpeechRecognitionTask?
    
    private let speechLabel = UILabel()
    private let speechButton = UIButton()
    
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
    
    private func style() {
        view.backgroundColor = .white
        
        speechLabel.translatesAutoresizingMaskIntoConstraints = false
        speechLabel.text = "Your speech will show here when you start recording!"
        speechLabel.textColor = .black
        speechLabel.textAlignment = .center
        
        speechButton.translatesAutoresizingMaskIntoConstraints = false
        speechButton.setTitle("Tap to Recording Your Speech", for: .normal)
        speechButton.backgroundColor = .blue
        speechButton.addTarget(self, action: #selector(SpeechButtonTapped), for: .touchUpInside)
    }
    
    private func layout() {
        
        view.addSubview(speechLabel)
        view.addSubview(speechButton)

        NSLayoutConstraint.activate([
            speechLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            speechLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            speechLabel.widthAnchor.constraint(equalToConstant: view.frame.width / 1.1),
            
            speechButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            speechButton.widthAnchor.constraint(equalToConstant: view.frame.width / 1.1),
            speechButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
        
    }
    
}

extension SpeechRecogScreen: SFSpeechRecognizerDelegate {
    
    private func recordAndRecognizeSpeech() {
        
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.request.append(buffer)
        }
        
        audioEngine.prepare()
        do {
            try audioEngine.start()
        }
        catch {
            print(error)
        }
        
        guard let myRecognizer = SFSpeechRecognizer() else {
            //not supported locale
            return
        }
        
        if !myRecognizer.isAvailable {
            // a recognizer is not available right now
            return
        }
        
        
        recognitionTask = speechRecognizer?.recognitionTask(with: request, resultHandler: { result, err in
            if let result = result {
                let bestString = result.bestTranscription.formattedString
                DispatchQueue.main.async {
                    self.speechLabel.text = bestString
                }
                
            } else if let err = err {
                print(err)
            }
        })
    }
    
}

