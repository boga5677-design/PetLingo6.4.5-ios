import SwiftUI

@main struct PetLingoApp: App {
    @StateObject private var store=AppStore()
    var body: some Scene { WindowGroup { RootView().environmentObject(store).preferredColorScheme(store.settings.themeMode=="深色" ? .dark : store.settings.themeMode=="淺色" ? .light:nil).tint(PLColor.primary) } }
}

enum Route: Hashable { case vocabulary,phrase,quizSetup,quiz,listeningSetup,listeningPractice,speaking,reading,readingDetail(Int),favorites,wrong,notes,analytics,history,daily,achievements,settings,result }
struct RootView: View {
    @EnvironmentObject var store:AppStore; @StateObject var speech=SpeechService(); @State private var path:[Route]=[]; @State private var tab=0
    var body: some View { NavigationStack(path:$path){ TabView(selection:$tab){
        HomeView(open:{path.append($0)}).tag(0).tabItem{Label("首頁",systemImage:"house.fill")}
        LearningHubView(open:{path.append($0)}).tag(1).tabItem{Label("學習",systemImage:"book.fill")}
        QuizSetupView(start:{c,m in if store.startQuiz(count:c,mode:m){path.append(.quiz)}}).tag(2).tabItem{Label("測驗",systemImage:"checkmark.circle.fill")}
        ListeningSetupView(openPractice:{path.append(.listeningPractice)},startQuiz:{c in if store.startQuiz(count:c,mode:.listening){path.append(.quiz)}}).tag(3).tabItem{Label("聽力",systemImage:"headphones")}
        SpeakingView().environmentObject(speech).tag(4).tabItem{Label("口說",systemImage:"mic.fill")}
    }.navigationDestination(for:Route.self){r in destination(r)} }.environmentObject(speech) }
    @ViewBuilder private func destination(_ r:Route)->some View { switch r {
    case .vocabulary: VocabularyView(); case .phrase: PhraseView(); case .quizSetup: QuizSetupView(start:{c,m in if store.startQuiz(count:c,mode:m){path.append(.quiz)}}); case .quiz: QuizView(done:{path.append(.result)}); case .listeningSetup: ListeningSetupView(openPractice:{path.append(.listeningPractice)},startQuiz:{c in if store.startQuiz(count:c,mode:.listening){path.append(.quiz)}}); case .listeningPractice: ListeningPracticeView(); case .speaking: SpeakingView(); case .reading: ReadingListView(open:{path.append(.readingDetail($0))}); case .readingDetail(let id): if let p=store.readings.first(where:{$0.id==id}){ReadingDetailView(passage:p)}; case .favorites: FavoritesView(); case .wrong: WrongAnswersView(); case .notes: NotesView(); case .analytics: AnalyticsView(); case .history: HistoryView(); case .daily: DailyMissionView(); case .achievements: AchievementsView(); case .settings: SettingsView(); case .result: ResultView(retry:{ if store.startQuiz(count:store.questions.count,mode:store.activeMode){path.removeLast(); path.append(.quiz)} }) }
    }
}
