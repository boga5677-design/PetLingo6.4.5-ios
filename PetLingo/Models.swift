import Foundation

enum QuestionType: String, Codable, CaseIterable { case vocabulary="單字", phrase="片語", grammar="文法", cloze="克漏字", reading="閱讀", listening="聽力" }
enum QuizMode: String, Codable, CaseIterable, Identifiable {
    case englishToChinese="英文選中文", chineseToEnglish="中文選英文", favorites="收藏單字測驗", phrase="片語測驗", cloze="克漏字", reading="閱讀測驗", listening="聽力測驗", toeicMock="多益模擬題"
    var id: String { rawValue }
}
struct Word: Identifiable, Codable, Hashable { let id:Int; let english:String; let chinese:String; var partOfSpeech:String=""; var note:String=""; var level:String=""; var academic:String=""; var ceecLevel:String="" }
struct Phrase: Identifiable, Codable, Hashable { let id:Int; let english:String; let chinese:String; let example:String }
struct QuizQuestion: Identifiable, Codable, Hashable { let id:Int; let prompt:String; let options:[String]; let correctIndex:Int; let explanation:String; let type:QuestionType }
struct AnswerRecord: Identifiable, Codable, Hashable { var id=UUID(); let questionId:Int; let prompt:String; let selectedAnswer:String; let correctAnswer:String; let isCorrect:Bool; let elapsedMillis:Int; let type:QuestionType; let changedAnswer:Bool; var explanation:String=""; var timestamp=Date() }
struct QuizSession: Identifiable, Codable, Hashable { var id=UUID(); let startedAt:Date; let finishedAt:Date; let answers:[AnswerRecord]; var modeLabel:String="英文選中文"; var correctCount:Int{answers.filter{$0.isCorrect}.count}; var questionCount:Int{answers.count}; var score:Int{questionCount==0 ? 0 : correctCount*100/questionCount}; var totalMillis:Int{answers.reduce(0){$0+$1.elapsedMillis}} }
struct ReadingQuestion: Codable, Hashable { let prompt:String; let options:[String]; let correctIndex:Int; let explanation:String }
struct ReadingPassage: Identifiable, Codable, Hashable { let id:Int; let title:String; let category:String; let content:String; let questions:[ReadingQuestion] }
struct SpeakingRecord: Identifiable, Codable, Hashable { var id=UUID(); let targetText:String; let recognizedText:String; let score:Int; let accent:String; var createdAt=Date() }
struct WrongAnswer: Identifiable, Codable, Hashable { var id:String{key}; let key:String; let prompt:String; let selectedAnswer:String; let correctAnswer:String; let explanation:String; let typeLabel:String; let elapsedMillis:Int; var wrongCount:Int=1; var lastWrongAt=Date() }
struct StudyNote: Identifiable, Codable, Hashable { var id:String{key}; let key:String; let category:String; let kind:String; let title:String; let content:String; var detail:String=""; var createdAt=Date() }
struct AppSettings: Codable, Hashable { var accent="美式"; var speechRate:Float=1.0; var defaultQuestionCount=20; var defaultLevel="全部"; var soundEffects=true; var autoReadQuestion=false; var showExplanation=true; var addWrongAnswerAutomatically=true; var dailyGoal=20; var themeMode="淺色"; var largeText=false; var dailyReminder=false }
