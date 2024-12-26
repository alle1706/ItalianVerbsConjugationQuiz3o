import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            NavigationView {
                List {
                    Section(header: Text("Indicativo")) {
                        NavigationLink(destination: QuizSetupView(tense: "Presente")) {
                            Text("Presente")
                        }
                        NavigationLink(destination: QuizSetupView(tense: "Imperfetto")) {
                            Text("Imperfetto")
                        }
                        NavigationLink(destination: QuizSetupView(tense: "Futuro")) {
                            Text("Futuro")
                        }
                    }
                    Section(header: Text("Condizionale")) {
                        NavigationLink(destination: QuizSetupView(tense: "Condizionale Presente")) {
                            Text("Presente")
                        }
                        NavigationLink(destination: QuizSetupView(tense: "Condizionale Passato")) {
                            Text("Passato")
                        }
                    }
                    Section(header: Text("Congiuntivo")) {
                        NavigationLink(destination: QuizSetupView(tense: "Congiuntivo Presente")) {
                            Text("Presente")
                        }
                        NavigationLink(destination: QuizSetupView(tense: "Congiuntivo Passato")) {
                            Text("Passato")
                        }
                        NavigationLink(destination: QuizSetupView(tense: "Congiuntivo Imperfetto")) {
                            Text("Imperfetto")
                        }
                    }
                }
                .navigationTitle("Quiz")
            }
            .tabItem {
                Label("Quiz", systemImage: "pencil")
            }

            ProgressView()
                .tabItem {
                    Label("Progress", systemImage: "chart.bar")
                }
        }
    }
}


struct QuizSetupView: View {
    var tense: String

    let tenseExplanations: [String: String] = [
        "Presente": """
        Used to describe actions that are happening now or regularly occur. 
        For example: Io parlo (I speak), Tu parli (You speak).
        Conjugation:
        For verbs ending in -ARE, -ERE, -IRE:
        1. Remove the infinitive ending (-ARE, -ERE, -IRE).
        2. Add the appropriate endings:
           -ARE: -o, -i, -a, -iamo, -ate, -ano
           -ERE: -o, -i, -e, -iamo, -ete, -ono
           -IRE: -o, -i, -e, -iamo, -ite, -ono
        """,

        "Imperfetto": """
        Used to describe ongoing or continuous actions in the past, habitual actions, or states of being. 
        For example: Io parlavo (I was speaking), Tu parlavi (You were speaking).
        Conjugation:
        1. Remove the -RE.
        2. Add the appropriate endings for all verb types:
           -vo, -vi, -va, -vamo, -vate, -vano
        """,

        "Futuro": """
        Used to describe actions that will occur in the future. 
        For example: Io parlerò (I will speak), Tu parlerai (You will speak).
        Conjugation:
        1. For regular verbs:
           -ARE, -ERE turn into -ER (e.g., parlare becomes parler-).
           -IRE turns into -IR.
        2. Add the appropriate endings:
           -ò, -ai, -à, -emo, -ete, -anno
        """,

        "Condizionale Presente": """
        Used to describe actions that would happen under certain conditions or to express polite requests. 
        For example: Io parlerei (I would speak), Tu parleresti (You would speak).
        Conjugation:
        1. For regular verbs:
           - Take the futuro semplice form and add the endings or: 
               -ARE, -ERE turn into -ER (e.g., parlare becomes parler-).
               -IRE turns into -IR.
        2. Add the appropriate endings:
           -ei, -esti, -ebbe, -emmo, -este, -ebbero
        """
    ]



    var body: some View {
        VStack {
            Text("Quiz Setup for \(tense)")
                .font(.title)
                .padding()

            Spacer()

            if let explanation = tenseExplanations[tense] {
                Text(explanation)
                    .font(.body)
                    .padding()
                    .multilineTextAlignment(.center)
            } else {
                Text("No explanation available for this tense.")
                    .font(.body)
                    .padding()
                    .multilineTextAlignment(.center)
            }

            Spacer()

            NavigationLink(destination: QuizView(tense: tense)) {
                Text("Start Quiz")
                    .font(.title2)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }

            Spacer()
        }
    }
}


struct QuizView: View {
    var tense: String

    @State private var answers = Array(repeating: "", count: 6)
    @State private var randomVerb: Verb?
    @State private var isQuizChecked = false
    @State private var usedVerbs = Set<String>()
    @State private var showNextButton = false
    @State private var allVerbsForTense: [Verb] = [] // Local array for shuffling and reusing verbs
    @State private var finishedDataset = false // Track if the dataset is completed

    @FocusState private var focusedField: Int? // Tracks the current focused TextField

    
    var correctConjugations: [String] {
        randomVerb?.tenses[tense] ?? []
    }

    var body: some View {
        VStack {
            if finishedDataset {
                VStack {
                    Text("Congrats! You've completed the dataset for \(tense).")
                        .font(.title2)
                        .multilineTextAlignment(.center)
                        .padding()
                    
                    Button("Restart Quiz") {
                        resetDataset()
                        loadRandomVerb()
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
            } else {
                HStack {
                    Button("Skip") {
                        skipToNextVerb()
                    }
                    .foregroundColor(.red)
                    .padding()

                    Spacer()

                    if let verb = randomVerb {
                        Text("\(verb.verb.capitalized) - \(tense)")
                            .font(.title)
                            .padding()
                    } else {
                        Text("Loading...")
                            .font(.title)
                            .padding()
                    }
                }

                ForEach(0..<6, id: \.self) { index in
                    HStack {
                        Text(["Io", "Tu", "Lui/Lei", "Noi", "Voi", "Loro"][index])
                            .frame(width: 60)

                        if isQuizChecked {
                            let correctAnswer = correctConjugations[index]
                            if answers[index].trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == correctAnswer.lowercased() {
                                Text(answers[index])
                                    .foregroundColor(.green)
                                    .fontWeight(.bold)
                            } else {
                                HStack {
                                    Text(answers[index])
                                        .strikethrough()
                                        .foregroundColor(.red)
                                    Text(correctAnswer)
                                        .foregroundColor(.green)
                                        .fontWeight(.bold)
                                }
                            }
                        } else {
                            TextField("...", text: $answers[index])
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .autocapitalization(.none)
                                .autocorrectionDisabled(true)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                                .background(Color.white.cornerRadius(10))
                                .focused($focusedField, equals: index) // Bind focus state
                                .onSubmit {
                                    if index < answers.count - 1 {
                                        focusedField = index + 1 // Move to next field
                                    } else {
                                        focusedField = nil // Dismiss keyboard on last field
                                    }
                                }
                        }
                    }
                }

                if !showNextButton {
                    Button("Check") {
                        isQuizChecked = true
                        showNextButton = true

                        if answers.indices.allSatisfy({
                            answers[$0].trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == correctConjugations[$0].lowercased()
                        }) {
                            if let verb = randomVerb {
                                VerbProgressManager.incrementProgress(for: verb.verb, in: tense)
                            }
                        }
                    }
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }

                if showNextButton {
                    Button("Next") {
                        loadRandomVerb()
                        resetQuiz()
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
            }
        }
        .onAppear {
            if allVerbsForTense.isEmpty {
                prepareTenseVerbs()
                loadRandomVerb()
            }
        }
    }

    func prepareTenseVerbs() {
        if let loadedVerbs = loadVerbs() {
            allVerbsForTense = loadedVerbs
                .filter { $0.tenses.keys.contains(tense) && !VerbProgressManager.isVerbMastered($0.verb, in: tense) }
                .shuffled() // Shuffle only for the quiz
        }
    }

    func loadRandomVerb() {
        guard !allVerbsForTense.isEmpty else {
            finishedDataset = true
            return
        }

        let unusedVerbs = allVerbsForTense.filter { !usedVerbs.contains($0.verb) }
        
        if let newVerb = unusedVerbs.randomElement() {
            randomVerb = newVerb
            usedVerbs.insert(newVerb.verb)
        } else {
            // All verbs are used; reset for reuse
            finishedDataset = true
        }
    }

    func resetDataset() {
        usedVerbs.removeAll()
        finishedDataset = false
    }

    func resetQuiz() {
        answers = Array(repeating: "", count: 6)
        isQuizChecked = false
        showNextButton = false
    }

    func skipToNextVerb() {
        loadRandomVerb()
        resetQuiz()
    }
}



struct ProgressView: View {
    @State private var selectedTense: String = "Presente"
    
    let tenses = ["Presente", "Imperfetto", "Futuro", "Condizionale Presente"]
    @State private var verbs: [Verb] = []
    
    var body: some View {
        NavigationView {
            VStack {
                Picker("Select Tense", selection: $selectedTense) {
                    ForEach(tenses, id: \.self) { tense in
                        Text(tense)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                if verbs.isEmpty {
                    Text("Loading verbs...")
                        .font(.headline)
                        .padding()
                } else {
                    List {
                        ForEach(verbs, id: \.verb) { verb in
                            if verb.tenses[selectedTense] != nil {
                                HStack {
                                    Text(verb.verb.capitalized)
                                    Spacer()
                                    Text("\(VerbProgressManager.getProgress(for: verb.verb, in: selectedTense))/5")
                                        .foregroundColor(
                                            VerbProgressManager.isVerbMastered(verb.verb, in: selectedTense)
                                            ? .green : .primary
                                        )
                                }
                                .swipeActions {
                                    Button("Reset") {
                                        VerbProgressManager.resetProgress(for: verb.verb, in: selectedTense)
                                    }
                                    .tint(.red)
                                }
                            }
                        }
                    }
                }

            }
            .navigationTitle("Progress")
            .onAppear {
                loadVerbsData()
            }
        }
    }
    
    private func loadVerbsData() {
        if let loadedVerbs = loadVerbs() {
            self.verbs = loadedVerbs
        } else {
            print("Failed to load verbs from JSON file.")
        }
    }
    

}



#Preview {
    ContentView()
}


