import SwiftUI
import SwiftData
import Charts


struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ChatMessage.createdAt) private var messages: [ChatMessage]
    
    @AppStorage("completedWellbeingTasks")
    private var completedTasksData = ""
    
    @StateObject private var ai = CosmoAI()
    @StateObject private var voice = CosmoVoice()
    @State private var draft = ""
    @State private var isThinking = false
    @State private var selectedTab = 0
    
    private let background = Color(red: 0.025, green: 0.055, blue: 0.12)
    private let cyan = Color(red: 0.20, green: 0.82, blue: 1.0)
    
    var completedTaskIDs: Set<Int> {
        Set(completedTasksData.split(separator: ",").compactMap {
            Int($0)
        })
    }
    
    var completedCount: Int {
        completedTaskIDs.intersection(
            wellbeingTasks.map(\.id)
        ).count
    }
    
    func toggleTask(_ task: WellbeingTask) {
        var completed = completedTaskIDs
        
        if completed.contains(task.id) {
            completed.remove(task.id)
        } else {
            completed.insert(task.id)
        }
        
        completedTasksData = completed.sorted()
            .map(String.init)
            .joined(separator: ",")
    }
    
    
    var body: some View {
        ZStack {
            background.ignoresSafeArea()
            
            TabView(selection: $selectedTab) {
                chatScreen
                    .tabItem { Label("COSMO", systemImage: "bubble.left.and.bubble.right") }
                    .tag(0)
                
                insightsScreen
                    .tabItem { Label("Insights", systemImage: "chart.xyaxis.line") }
                    .tag(1)
                
                tasksScreen
                    .tabItem { Label("To Do", systemImage: "checklist") }
                    .tag(2)
            }
            .tint(cyan)
        }
        .preferredColorScheme(.dark)
        .task {
            ai.start()
            if messages.isEmpty {
                saveMessage(
                    "Hello, crew member! I'm COSMO. 💬 Ready for a quick check-in? How are you feeling today?",
                    fromCosmo: true
                )
            }
        }
    }
    
    // MARK: CHAT SCREEN
    private var chatScreen: some View {
        VStack(spacing: 0) {
            header
            
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 16) {
                        COSMOAvatar(isThinking: isThinking)
                            .frame(height: 190)
                            .padding(.top, 12)
                        
                        Text(isThinking ? "COSMO IS THINKING" : "YOUR CREW COMPANION")
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .tracking(2.2)
                            .foregroundStyle(cyan.opacity(0.8))
                        
                        ForEach(messages) { message in
                            MessageBubble(message: message)
                                .id(message.id)
                        }
                        
                        if isThinking {
                            HStack {
                                ProgressView().tint(cyan)
                                Text("COSMO is thinking…")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Spacer()
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 18)
                }
                .onChange(of: messages.count) {
                    if let last = messages.last {
                        withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                    }
                }
            }
            
            composer
        }
    }
    
    private var header: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle().fill(cyan.opacity(0.14))
                Image(systemName: "sparkles")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(cyan)
            }
            .frame(width: 42, height: 42)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("MISSION WELLBEING")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .tracking(1.1)
                Text("COSMO • Daily check-in")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Circle()
                .fill(ai.isAvailable ? Color.green : Color.orange)
                .frame(width: 7, height: 7)
            Text(ai.isAvailable ? "ON-DEVICE AI" : "BASIC MODE")
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(.secondary)
            Spacer().frame(width: 8)
            ClearChatButton()
                .labelStyle(.iconOnly)
                .tint(cyan)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 12)
        .background(.white.opacity(0.035))
    }
    
    private var composer: some View {
        HStack(alignment: .bottom, spacing: 10) {
            TextField("Message COSMO…", text: $draft, axis: .vertical)
                .lineLimit(1...4)
                .padding(.horizontal, 15)
                .padding(.vertical, 12)
                .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 22))
                .tint(cyan)
                .disabled(isThinking)
            
            Button(action: send) {
                Image(systemName: "arrow.up")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(background)
                    .frame(width: 44, height: 44)
                    .background(cyan, in: Circle())
            }
            .disabled(draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isThinking)
            .opacity(draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.45 : 1)
        }
        .padding(.horizontal, 14)
        .padding(.top, 12)
        .padding(.bottom, 8)
        .background(background)
    }
    
    // MARK: INSIGHTS SCREEN
    private var insightsScreen: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("YOUR WELLBEING")
                            .font(.system(size: 11, weight: .bold))
                            .tracking(2)
                            .foregroundStyle(cyan)
                        Text("A little reflection goes a long way.")
                            .font(.title3.weight(.semibold))
                    }
                    
                    let scored = messages.filter { !$0.isFromCosmo && $0.sentimentScore != nil }
                    let average = scored.isEmpty ? nil :
                    scored.compactMap(\.sentimentScore).reduce(0, +) / Double(scored.count)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Recorded responses")
                            .foregroundStyle(.secondary)
                            .font(.subheadline)
                        Text("\(scored.count)")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                        Text("Sentiment is a language signal, not a mental-health diagnosis.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 18))
                    
                    if let average {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Average sentiment")
                                .font(.headline)
                            Text(average.formatted(.number.precision(.fractionLength(2))))
                                .font(.system(size: 30, weight: .bold, design: .rounded))
                                .foregroundStyle(average >= 0 ? .mint : .orange)
                            Text("Range: −1 (negative) to +1 (positive)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 18))
                    }
                    
                    
                    if !scored.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Recent sentiment")
                                .font(.headline)
                            
                            let recent = Array(scored.suffix(20))
                            let runningMean: [(date: Date, mean: Double)] = {
                                var results: [(Date, Double)] = []
                                var sum: Double = 0
                                var count: Double = 0
                                for m in recent {
                                    if let s = m.sentimentScore {
                                        sum += s
                                        count += 1
                                        results.append((m.createdAt, sum / count))
                                    }
                                }
                                return results
                            }()
                            
                            Chart {
                                // Original series: line + points
                                ForEach(Array(scored.suffix(20).enumerated()), id: \.offset) { index, message in
                                    if let score = message.sentimentScore {
                                        LineMark(
                                            x: .value("Message", index),
                                            y: .value("Sentiment", score)
                                        )
                                        .foregroundStyle(cyan)
                                        
                                        PointMark(
                                            x: .value("Message", index),
                                            y: .value("Sentiment", score)
                                        )
                                        .foregroundStyle(cyan)
                                    }
                                }
                                
                                // Running mean series
                                ForEach(Array(runningMean.enumerated()), id: \.offset) { index, item in
                                    LineMark(
                                        x: .value("Message", index),
                                        y: .value("Running Mean", item.mean),
                                        series: .value("Series", "Running Mean")
                                    )
                                    .foregroundStyle(.mint.opacity(0.6))
                                    .interpolationMethod(.linear)
                                    .lineStyle(StrokeStyle(lineWidth: 2, dash: [6, 4]))
                                }
                            }
                            .chartXAxis {
                                AxisMarks(values: .automatic(desiredCount: 5)) { value in
                                    AxisValueLabel {
                                        if let index = value.as(Int.self),
                                           index >= 0,
                                           index < recent.count {
                                            Text(recent[index].createdAt, format: .dateTime.hour().minute())
                                        }
                                    }
                                }
                            }
                            .chartYScale(domain: -1...1)
                            .frame(height: 190)
                        }
                        .padding()
                        .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 18))
                    }
                    
                    Text("These figures describe the sentiment expressed in text. They should not be used alone to assess an astronaut's mental health or fitness for duty.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .padding()
            }
            .background(background)
            .navigationTitle("Insights")
            .navigationBarTitleDisplayMode(.inline)
        }
        .tint(cyan)
    }
    
    // MARK: TASKS SCREEN
    private var tasksScreen: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    
                    // Introduction
                    VStack(alignment: .leading, spacing: 6) {
                        Text("YOUR MISSION WELLBEING")
                            .font(.system(size: 11, weight: .bold))
                            .tracking(2)
                            .foregroundStyle(cyan)
                        
                        Text("Small actions, positive impact.")
                            .font(.title3.weight(.semibold))
                        
                        Text("A few simple activities to help you feel connected, relaxed and positive.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    
                    // Progress card
                    VStack(alignment: .leading, spacing: 14) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("DAILY PROGRESS")
                                    .font(.system(size: 11, weight: .bold))
                                    .tracking(1.5)
                                    .foregroundStyle(cyan)
                                
                                Text("\(completedCount) of \(wellbeingTasks.count) completed")
                                    .font(.title2.weight(.bold))
                            }
                            
                            Spacer()
                            
                            Text("\(Int(Double(completedCount) / Double(wellbeingTasks.count) * 100))%")
                                .font(.system(size: 25, weight: .bold, design: .rounded))
                                .foregroundStyle(.mint)
                        }
                        
                        ProgressView(
                            value: Double(completedCount),
                            total: Double(wellbeingTasks.count)
                        )
                        .tint(cyan)
                        .scaleEffect(x: 1, y: 1.8, anchor: .center)
                        
                        if completedCount == wellbeingTasks.count {
                            Label(
                                "Fantastic work! All activities completed.",
                                systemImage: "checkmark.seal.fill"
                            )
                            .font(.caption.weight(.medium))
                            .foregroundStyle(.mint)
                        } else {
                            Text("Every small step counts. Take things at your own pace.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding()
                    .background(
                        .white.opacity(0.06),
                        in: RoundedRectangle(cornerRadius: 18)
                    )
                    
                    // Task list heading
                    HStack {
                        Text("SUGGESTED ACTIVITIES")
                            .font(.system(size: 11, weight: .bold))
                            .tracking(1.5)
                            .foregroundStyle(cyan)
                        
                        Spacer()
                        
                        Text("TODAY")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.secondary)
                    }
                    
                    // Individual tasks
                    VStack(spacing: 12) {
                        ForEach(wellbeingTasks) { task in
                            taskRow(task)
                        }
                    }
                    
                    Text("These activities are suggestions, not obligations. Choose what feels right for you.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .padding(.top, 4)
                }
                .padding()
            }
            .background(background)
            .navigationTitle("Wellbeing Tasks")
            .navigationBarTitleDisplayMode(.inline)
        }
        .tint(cyan)
    }
    
    
    private func send() {
        let text = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, !isThinking else { return }
        
        draft = ""
        saveMessage(text, fromCosmo: false)
        isThinking = true
        
        Task {
            do {
                let answer = try await ai.reply(to: text)
                saveMessage(answer, fromCosmo: true)
                voice.speak(answer)
            } catch {
                saveMessage(
                    "Sorry, I had a little systems wobble. Your check-in has still been saved. Would you try that again?",
                    fromCosmo: true
                )
            }
            isThinking = false
        }
    }
    
    private func saveMessage(_ text: String, fromCosmo: Bool) {
        let score = fromCosmo ? nil : SentimentAnalyser.score(text)
        modelContext.insert(
            ChatMessage(text: text, isFromCosmo: fromCosmo, sentimentScore: score)
        )
        do {
            try modelContext.save()
        } catch {
            print("Could not save message: \(error.localizedDescription)")
        }
    }
    
    
    private func taskRow(_ task: WellbeingTask) -> some View {
        let isCompleted = completedTaskIDs.contains(task.id)
        
        return Button {
            withAnimation(.spring(response: 0.3)) {
                toggleTask(task)
            }
        } label: {
            HStack(spacing: 14) {
                
                // Activity icon
                Image(systemName: task.icon)
                    .font(.system(size: 21))
                    .foregroundStyle(cyan)
                    .frame(width: 44, height: 44)
                    .background(
                        cyan.opacity(0.12),
                        in: RoundedRectangle(cornerRadius: 12)
                    )
                
                // Task information
                VStack(alignment: .leading, spacing: 5) {
                    Text(task.title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(
                            isCompleted ? .secondary : .primary
                        )
                        .strikethrough(isCompleted)
                    
                    Text(task.description)
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.leading)
                    
                    Text(task.category.uppercased())
                        .font(.system(size: 9, weight: .bold))
                        .tracking(1)
                        .foregroundStyle(cyan.opacity(0.8))
                        .padding(.top, 3)
                }
                
                Spacer(minLength: 4)
                
                // Completion checkbox
                Image(systemName: isCompleted
                      ? "checkmark.circle.fill"
                      : "circle")
                .font(.system(size: 25))
                .foregroundStyle(
                    isCompleted ? .mint : .secondary
                )
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                isCompleted
                ? Color.mint.opacity(0.06)
                : Color.white.opacity(0.06),
                in: RoundedRectangle(cornerRadius: 16)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(
                        isCompleted
                        ? Color.mint.opacity(0.25)
                        : Color.white.opacity(0.04),
                        lineWidth: 1
                    )
            }
            .contentShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(task.title)
        .accessibilityValue(isCompleted ? "Completed" : "Not completed")
        .accessibilityHint("Double tap to change completion status")
    }
}
