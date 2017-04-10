//
//  PlaySoundsViewController.swift
//  Pick Your Pitch
//
//  Created by Udacity on 1/5/15.
//  Copyright (c) 2014 Udacity. All rights reserved.
//

import UIKit
import AVFoundation

// MARK: - PlaySoundsViewController: UIViewController

class PlaySoundsViewController: UIViewController {

    // MARK: Properties
    
    let SliderValueKey = "Slider Value Key"
    var audioPlayer:AVAudioPlayer!
    var receivedAudio:RecordedAudio!
    var audioEngine:AVAudioEngine!
    var audioFile:AVAudioFile!
    
    // MARK: Outlets
    
    @IBOutlet weak var sliderView: UISlider!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: receivedAudio.filePathUrl as URL)
        } catch _ {
            audioPlayer = nil
        }
        audioPlayer.enableRate = true

        audioEngine = AVAudioEngine()
        do {
            audioFile = try AVAudioFile(forReading: receivedAudio.filePathUrl as URL)
        } catch _ {
            audioFile = nil
        }
        
        setUserInterfaceToPlayMode(false)
        checkExistingPitch()
    }
    
    // Set the slider persistence value when we are about to leave this screen
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        setSliderValue()
    }
    
    // MARK: Set Interface
    
    func setUserInterfaceToPlayMode(_ isPlayMode: Bool) {
        startButton.isHidden = isPlayMode
        stopButton.isHidden = !isPlayMode
        sliderView.isEnabled = !isPlayMode
    }

    // MARK: Actions
    
    @IBAction func playAudio(_ sender: UIButton) {
        
        // Get the pitch from the slider
        let pitch = sliderView.value
        
        // Play the sound
        playAudioWithVariablePitch(pitch)
        
        // Set the UI
        setUserInterfaceToPlayMode(true)
        
    }
    
    @IBAction func stopAudio(_ sender: UIButton) {
        audioPlayer.stop()
        audioEngine.stop()
        audioEngine.reset()
    }
    
    @IBAction func sliderDidMove(_ sender: UISlider) {
        print("Slider vaue: \(sliderView.value)")
    }
    
    // MARK: Play Audio
    
    func playAudioWithVariablePitch(_ pitch: Float){
        audioPlayer.stop()
        audioEngine.stop()
        audioEngine.reset()
        
        let audioPlayerNode = AVAudioPlayerNode()
        audioEngine.attach(audioPlayerNode)
        
        let changePitchEffect = AVAudioUnitTimePitch()
        changePitchEffect.pitch = pitch
        audioEngine.attach(changePitchEffect)
        
        audioEngine.connect(audioPlayerNode, to: changePitchEffect, format: nil)
        audioEngine.connect(changePitchEffect, to: audioEngine.outputNode, format: nil)
        
        audioPlayerNode.scheduleFile(audioFile, at: nil) {
            // When the audio completes, set the user interface on the main thread
            DispatchQueue.main.async {self.setUserInterfaceToPlayMode(false) }
        }
        
        do {
            try audioEngine.start()
        } catch _ {
        }
        
        audioPlayerNode.play()
    }
    
    // MARK: - Persistence
    
    /**
     Checks for an existing persistence float value representing the slider.
    */
    private func checkExistingPitch() {
        if UserDefaults.standard.object(forKey: SliderValueKey) == nil {
            setSliderValue()
        } else {
            loadSliderValue()
        }
    }
    
    /**
     Sets the UserDefaults slider value
     */
    private func setSliderValue() {
        let sliderPositionValue = sliderView.value
        UserDefaults.standard.set(sliderPositionValue, forKey: SliderValueKey)
        print("set value")
    }
    
    /**
     Loads slider value from UserDefaults and sets the slider to that value
     */
    private func loadSliderValue() {
        let sliderPositionValue = UserDefaults.standard.float(forKey: SliderValueKey)
        sliderView.value = sliderPositionValue
        print("value loaded")
    }
}
