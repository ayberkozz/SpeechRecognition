//
//  ViewController.swift
//  SpeechRecognition
//
//  Created by Ayberk Öz on 21.10.2023.
//

import UIKit
import Speech

class SpeechRecogScreen: UIViewController {
    
    private let VStack = UIStackView()
    private let speechLabel = UILabel()
    private let speechButton = UIButton()
    private let speechStopButton = UIButton()
    
    private let viewModel : SpeechScreenViewModel
    
    init(viewModel: SpeechScreenViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.viewModel.output = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        style()
        layout()
    }
    
}

//MARK: - Funcs
extension SpeechRecogScreen {
    
    @objc private func SpeechButtonTapped() {
        viewModel.recordAndRecognizeSpeech(speechButton: speechButton, speechDefaultColor: .blue, speechIsEnable: false, speechStopButton: speechStopButton, StopDefaultColor: .red, StopIsEnable: true)
    }
    
    @objc private func SpeechStopButtonTapped() {
        viewModel.stopRecording(speechButton: speechButton, speechDefaultColor: .blue, speechIsEnable: true, speechStopButton: speechStopButton, StopDefaultColor: .red, StopIsEnable: false)
    }
    
    func ShowAlert(alertModel: SpeechErrorAlertModel) {
        let alert = UIAlertController(title: alertModel.titleText, message: alertModel.description, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func ButtonColorAdjustment(sender:UIButton,DefaultColor: UIColor, isEnable:Bool){
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
            VStack.bottomAnchor.constraint(equalToSystemSpacingBelow: view.safeAreaLayoutGuide.bottomAnchor, multiplier: -2),
            VStack.heightAnchor.constraint(equalToConstant: view.frame.height / 5),
            
            speechButton.widthAnchor.constraint(equalToConstant: view.frame.width / 1.1),
            
            speechStopButton.widthAnchor.constraint(equalToConstant: view.frame.width / 1.1),
        ])
        
    }
    
}

//MARK: - Output
extension SpeechRecogScreen: SpeechScreenVMOutput {
    func speechLabel(speechText: String) {
        DispatchQueue.main.async {
            self.speechLabel.text = speechText
        }
    }
    
    func alert(alert: SpeechErrorAlertModel) {
        let alert = UIAlertController(title: alert.titleText, message: alert.description, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

