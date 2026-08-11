import Foundation
import SwiftUI

@MainActor final class AppStore: ObservableObject {
    @Published var words:[Word]=AppData.loadWords(); let phrases=AppData.phrases; let readings=AppData.readings
    @Published var favorites:Set<Int>=[] { didSet{save(favorites,key:"favorites")} }
    @Published var sessions:[QuizSession]=[] { didSet{save(sessions,key:"sessions")} }
    @Published var wrongAnswers:[WrongAnswer]=[] { didSet{save(wrongAnswers,key:"wrongAnswers")} }
    @Published var speakingRecords:[SpeakingRecord]=[] { didSet{save(speakingRecords,key:"speakingRecords")} }
    @Published var notes:[StudyNote]=[] { didSet{save(notes,key:"notes")} }
    @Published var settings=AppSettings(){ didSet{save(settings,key:"settings")} }
    @Published var questions:[QuizQuestion]=[]; @Published var currentIndex=0; @Published var answers:[AnswerRecord]=[]; @Published var completedSession:QuizSession?; @Published var activeMode:QuizMode = .englishToChinese
    private var quizStarted=Date(); private var questionStarted=Date(); private var firstChoice:Int?
    init(){ favorites=load(Set<Int>.self,key:"favorites") ?? []; sessions=load([QuizSession].self,key:"sessions") ?? []; wrongAnswers=load([WrongAnswer].self,key:"wrongAnswers") ?? []; speakingRecords=load([SpeakingRecord].self,key:"speakingRecords") ?? []; notes=load([StudyNote].self,key:"notes") ?? []; settings=load(AppSettings.self,key:"settings") ?? AppSettings() }
    private func save<T:Encodable>(_ x:T,key:String){ if let d=try? JSONEncoder().encode(x){UserDefaults.standard.set(d,forKey:key)} }
    private func load<T:Decodable>(_ t:T.Type,key:String)->T?{ guard let d=UserDefaults.standard.data(forKey:key) else{return nil}; return try? JSONDecoder().decode(t,from:d) }
    var todayAnswered:Int { let cal=Calendar.current; return sessions.filter{cal.isDateInToday($0.finishedAt)}.reduce(0){$0+$1.questionCount} }
    var lastSession:QuizSession? { sessions.sorted{$0.finishedAt>$1.finishedAt}.first }
    func toggleFavorite(_ id:Int){ if favorites.contains(id){favorites.remove(id)}else{favorites.insert(id)} }
    func toggleNote(_ note:StudyNote){ if let i=notes.firstIndex(where:{$0.key==note.key}){notes.remove(at:i)}else{notes.append(note)} }
    func startQuiz(count:Int, mode:QuizMode)->Bool { let pool = mode == .favorites ? words.filter{favorites.contains($0.id)}:words; guard pool.count>=4 else{return false}; activeMode=mode; questions=makeQuiz(pool:pool,count:count,mode:mode); guard !questions.isEmpty else{return false}; currentIndex=0; answers=[]; completedSession=nil; quizStarted=Date(); questionStarted=Date(); firstChoice=nil; return true }
    func select(_ i:Int){ if firstChoice==nil {firstChoice=i} }
    func submit(_ i:Int)->AnswerRecord? { guard currentIndex<questions.count, i<questions[currentIndex].options.count else{return nil}; let q=questions[currentIndex], elapsed=Int(Date().timeIntervalSince(questionStarted)*1000); let r=AnswerRecord(questionId:q.id,prompt:q.prompt,selectedAnswer:q.options[i],correctAnswer:q.options[q.correctIndex],isCorrect:i==q.correctIndex,elapsedMillis:elapsed,type:q.type,changedAnswer:firstChoice != nil && firstChoice != i,explanation:q.explanation); answers.append(r); if !r.isCorrect && settings.addWrongAnswerAutomatically { addWrong(r) }; return r }
    func next()->Bool { if currentIndex<questions.count-1 { currentIndex+=1; questionStarted=Date(); firstChoice=nil; return true }; finish(); return false }
    func finish(){ guard !answers.isEmpty else{return}; let s=QuizSession(startedAt:quizStarted,finishedAt:Date(),answers:answers,modeLabel:activeMode.rawValue); sessions.insert(s,at:0); completedSession=s }
    func addWrong(_ r:AnswerRecord){ let key="quiz-\(r.questionId)"; if let i=wrongAnswers.firstIndex(where:{$0.key==key}){ var w=wrongAnswers[i]; w.wrongCount+=1; w.lastWrongAt=Date(); wrongAnswers[i]=w } else { wrongAnswers.append(WrongAnswer(key:key,prompt:r.prompt,selectedAnswer:r.selectedAnswer,correctAnswer:r.correctAnswer,explanation:r.explanation,typeLabel:r.type.rawValue,elapsedMillis:r.elapsedMillis)) } }
    func addSpeaking(target:String, recognized:String, score:Int, accent:String){ speakingRecords.insert(SpeakingRecord(targetText:target,recognizedText:recognized,score:score,accent:accent),at:0) }
    func resetHistory(){ sessions=[]; wrongAnswers=[]; speakingRecords=[] }
    func resetSettings(){ settings=AppSettings() }
    private func make(_ id:Int,_ prompt:String,_ correct:String,_ distract:[String],_ explanation:String,_ type:QuestionType)->QuizQuestion { let opts=(Array(distract.prefix(3)) + [correct]).shuffled(); return QuizQuestion(id:id,prompt:prompt,options:opts,correctIndex:opts.firstIndex(of:correct)!,explanation:explanation,type:type) }
    private func makeQuiz(pool:[Word],count:Int,mode:QuizMode)->[QuizQuestion] {
        switch mode {
        case .phrase: return phrases.shuffled().prefix(count).enumerated().map{ i,p in make(3000+i,p.english,p.chinese,phrases.filter{$0.id != p.id}.shuffled().prefix(3).map{$0.chinese},"\(p.english)：\(p.chinese)\n\(p.example)",.phrase) }
        case .cloze: return clozeQuestions(count)
        case .reading: return readingQuestions(count)
        case .toeicMock: return Array((clozeQuestions(20)+readingQuestions(16)+makeQuiz(pool:pool,count:20,mode:.englishToChinese)+makeQuiz(pool:pool,count:20,mode:.phrase)).shuffled().prefix(count))
        default: return pool.shuffled().prefix(count).enumerated().map{ i,w in let others=pool.filter{$0.id != w.id}.shuffled().prefix(3); if mode == .chineseToEnglish { return make(i,w.chinese,w.english,others.map{$0.english},"\(w.english)：\(w.chinese)",.vocabulary) }; return make(i,w.english,w.chinese,others.map{$0.chinese},"\(w.english)：\(w.chinese)", mode == .listening ? .listening:.vocabulary) }
        }
    }
    private func clozeQuestions(_ count:Int)->[QuizQuestion]{ let b:[(String,String,[String],String)]=[("Please submit the completed form ______ Friday afternoon.","by",["during","since","among"],"by 表示不晚於指定時間。"),("The flight was canceled ______ severe weather.","due to",["instead of","apart from","along with"],"due to 表示由於。"),("All visitors are required ______ photo identification.","to present",["presenting","present","presented"],"be required to 後接原形動詞。"),("The equipment should be inspected ______ a regular basis.","on",["at","for","with"],"on a regular basis。"),("Ms. Lin is responsible ______ organizing the conference.","for",["to","with","at"],"be responsible for。")]; return (0..<min(count,80)).map{ i in let x=b[i%b.count]; return make(4100+i,x.0,x.1,x.2,x.3,.cloze)}.shuffled() }
    private func readingQuestions(_ count:Int)->[QuizQuestion]{ let b=readings.flatMap{p in p.questions.enumerated().map{i,q in QuizQuestion(id:5000+p.id*10+i,prompt:"\(p.title)\n\n\(p.content)\n\n\(q.prompt)",options:q.options,correctIndex:q.correctIndex,explanation:q.explanation,type:.reading)}}; return (0..<min(count,80)).map{i in var q=b[i%b.count]; q=QuizQuestion(id:6000+i,prompt:q.prompt,options:q.options,correctIndex:q.correctIndex,explanation:q.explanation,type:q.type); return q}.shuffled() }
}
