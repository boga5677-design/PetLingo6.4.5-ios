import Foundation
import AVFoundation
import Speech

@MainActor final class SpeechService: NSObject, ObservableObject, AVSpeechSynthesizerDelegate {
    private let synthesizer = AVSpeechSynthesizer()
    private let recognizerUS = SFSpeechRecognizer(locale: Locale(identifier:"en-US"))
    private let recognizerUK = SFSpeechRecognizer(locale: Locale(identifier:"en-GB"))
    private let engine = AVAudioEngine()
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?
    @Published var recognizedText=""
    @Published var isListening=false
    @Published var speechFinished=false
    override init(){ super.init(); synthesizer.delegate=self }
    func speak(_ text:String, accent:String="美式", rate:Float=1.0, completionAfter:Double=0) {
        stopSpeaking(); speechFinished=false
        let u=AVSpeechUtterance(string:text); u.voice=AVSpeechSynthesisVoice(language: accent=="英式" ? "en-GB":"en-US"); u.rate=max(0.35,min(0.58,0.48*rate)); synthesizer.speak(u)
    }
    func stopSpeaking(){ synthesizer.stopSpeaking(at:.immediate) }
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) { speechFinished=true }
    func requestPermissions() async -> Bool {
        let speech = await withCheckedContinuation { c in SFSpeechRecognizer.requestAuthorization{ c.resume(returning:$0 == .authorized) } }
        let mic:Bool
        if #available(iOS 17.0, *) { mic = await AVAudioApplication.requestRecordPermission() } else { mic = await withCheckedContinuation { c in AVAudioSession.sharedInstance().requestRecordPermission{c.resume(returning:$0)} } }
        return speech && mic
    }
    func startRecognition(accent:String="美式") async {
        guard await requestPermissions() else { return }
        stopRecognition(); recognizedText=""
        let session=AVAudioSession.sharedInstance(); try? session.setCategory(.record, mode:.measurement, options:.duckOthers); try? session.setActive(true, options:.notifyOthersOnDeactivation)
        request=SFSpeechAudioBufferRecognitionRequest(); request?.shouldReportPartialResults=true
        let node=engine.inputNode, format=node.outputFormat(forBus:0)
        node.removeTap(onBus:0); node.installTap(onBus:0, bufferSize:1024, format:format){ [weak self] buffer,_ in self?.request?.append(buffer) }
        engine.prepare(); try? engine.start(); isListening=true
        let rec = accent=="英式" ? recognizerUK : recognizerUS
        task=rec?.recognitionTask(with:request!){ [weak self] result,error in
            Task { @MainActor in
                if let result { self?.recognizedText=result.bestTranscription.formattedString }
                if error != nil || result?.isFinal == true { self?.stopRecognition() }
            }
        }
    }
    func stopRecognition(){ if engine.isRunning { engine.stop(); engine.inputNode.removeTap(onBus:0) }; request?.endAudio(); task?.cancel(); request=nil; task=nil; isListening=false; try? AVAudioSession.sharedInstance().setActive(false, options:.notifyOthersOnDeactivation) }
    static func score(target:String, recognized:String) -> Int {
        func tokens(_ s:String)->[String]{ s.lowercased().replacingOccurrences(of:"[^a-z0-9' ]",with:"",options:.regularExpression).split(separator:" ").map(String.init) }
        let a=tokens(target), b=tokens(recognized); if a.isEmpty{return 0}; let setA=Set(a), setB=Set(b); let overlap=Double(setA.intersection(setB).count)/Double(max(setA.count,setB.count)); let exact = a == b ? 1.0 : 0; return Int((overlap*0.82+exact*0.18)*100.0)
    }
}

enum SoundFX {
    static func correct(){ AudioServicesPlaySystemSound(1057) }
    static func wrong(){ AudioServicesPlaySystemSound(1053) }
}
