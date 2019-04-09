//
//  ViewController.swift
//  ortbalsn-challenge-audio
//
//  Created by Nathan Ortbals on 4/9/19.
//  Copyright © 2019 nathanortbals. All rights reserved.
//

import UIKit
import AVKit

class ViewController: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    var audioSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!
    
    @IBOutlet weak var recordButton: UIBarButtonItem!
    @IBOutlet weak var playButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true)
            audioSession.requestRecordPermission() {
                [unowned self] allowed in
                if allowed {
                    self.recordButton.isEnabled = true
                } else {
                    self.recordButton.isEnabled = false
                }
            }
        }
        catch {
            self.recordButton.isEnabled = false
        }
        
        loadAudioFile()
    }

    @IBAction func recordButtonPressed(_ sender: Any) {
        if audioRecorder == nil {
            startRecording()
        }
        else {
            stopRecording()
        }
    }
    
    @IBAction func playButtonPressed(_ sender: Any) {
        if audioPlayer != nil && !audioPlayer.isPlaying {
            startPlaying()
        }
        else {
            stopPlaying()
        }
    }
    
    func getAudioFilePath() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0].appendingPathComponent("recording.caf")
    }
    
    func startRecording() {
        let audioFilename = getAudioFilePath()
        
        let settings =
            [AVEncoderAudioQualityKey: AVAudioQuality.min.rawValue,
             AVEncoderBitRateKey: 16,
             AVNumberOfChannelsKey: 2,
             AVSampleRateKey: 44100.0] as [String : Any]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()
            
            recordButton.image = UIImage(named: "stop")
            playButton.isEnabled = false
        }
        catch {
            presentAlert(message: "audioSession error: \(error.localizedDescription)")
            stopRecording()
        }
    }
    
    func stopRecording() {
        if audioRecorder != nil {
            audioRecorder.stop()
        }
        
        do {
            try audioSession.setActive(true)
        }
        catch {
            
        }
        
        audioRecorder = nil
        recordButton.image = UIImage(named: "record")
        loadAudioFile()
    }
    
    func loadAudioFile() {
        let audioFilename = getAudioFilePath()
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: audioFilename)
            audioPlayer.delegate = self
            playButton.isEnabled = true
        }
        catch {
            playButton.isEnabled = false
            stopPlaying()
        }
    }
    
    func startPlaying() {
        if(audioPlayer != nil) {
            audioPlayer.play()
            playButton.image = UIImage(named: "stop")
            recordButton.isEnabled = false
        }
    }
    
    func stopPlaying() {
        if(audioPlayer != nil) {
            audioPlayer.stop()
        }
        
        playButton.image = UIImage(named: "play")
        recordButton.isEnabled = true
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        playButton.image = UIImage(named: "play")
        recordButton.isEnabled = true
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        guard let error = error  else {
            return
        }
        presentAlert(message: "Audio record encoding error: \(error.localizedDescription)")
    }
    
    func presentAlert(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
}

