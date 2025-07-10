//
//  ContributionGraphView.swift
//  Workout_App_IOS
//
//  Created by Brody Whalen on 7/2/25.
//
import SwiftUI
import SwiftData
import Charts


struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = .zero
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) { value = nextValue() }
}


struct GraphScrollView: View {
    @State private var monthsToDisplay: [Date] = []
    @State private var scrollPosition: Date?
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 0) {
                ForEach(monthsToDisplay, id: \.self) { monthDate in
                    MonthContributionChartView(monthDate: monthDate)
                        .containerRelativeFrame(.horizontal)
                }
            }
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.viewAligned)
        .scrollPosition(id: $scrollPosition)
        .onAppear(perform: setupMonths)
    }
    
    private func setupMonths() {
        let today = Date()
        let calendar = Calendar.current
        guard let centralMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: today)) else { return }
        
        monthsToDisplay = (-5...0).compactMap { i in calendar.date(byAdding: .month, value: i, to: centralMonth) }
        scrollPosition = monthsToDisplay.last
    }
}


// MARK: - MonthContributionChartView (UPDATED FOR MULTI-WORKOUT)
struct MonthContributionChartView: View {
    @EnvironmentObject private var interactionManager: ChartInteractionManager
    @Query private var allSessionsInMonth: [WorkoutSession] // Fetches all sessions for the month
    let currentDate = Date()
    let monthDate: Date
    
    // The data structure for the chart is now a representation of each day
    struct DayData: Identifiable {
        var id: Date { date }
        let date: Date
        let sessions: [WorkoutSession]
        var totalExerciseCount: Int {
            sessions.reduce(0) { $0 + $1.exercises.count }
        }
    }
    
    private var days: [DayData] {
        let calendar = Calendar.current
        guard let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: monthDate)),
              let monthRange = calendar.range(of: .day, in: .month, for: monthDate) else { return [] }
        
        // Group the fetched sessions by their start day
        let sessionsByDay = Dictionary(grouping: allSessionsInMonth) { calendar.startOfDay(for: $0.timestart) }
        
        // Create a DayData object for every day of the month
        return monthRange.compactMap { dayIndex -> DayData? in
            guard let date = calendar.date(byAdding: .day, value: dayIndex - 1, to: monthStart) else { return nil }
            let daySessions = sessionsByDay[date] ?? [] // Get all sessions for this day, or an empty array
            return DayData(date: date, sessions: daySessions)
        }
    }
    
    init(monthDate: Date) {
        self.monthDate = monthDate
        let calendar = Calendar.current
        guard let interval = calendar.dateInterval(of: .month, for: monthDate) else {
            _allSessionsInMonth = Query(filter: #Predicate { _ in false })
            return
        }
        let filter = #Predicate<WorkoutSession> {
            $0.timestart >= interval.start && $0.timestart < interval.end
        }
        _allSessionsInMonth = Query(filter: filter, sort: \.timestart)
    }
    
    // MARK: Properties
    private var WeekdaySymbols: [String] { ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"] }
    private var colors: [Color] { (0...20).map { $0 == 0 ? Color(.systemGray5) : Color(.systemGreen).opacity(Double($0) / 20.0) } } // Increased range
    private var colorDomain: ClosedRange<Int> {
        let counts = days.map { $0.totalExerciseCount }
        let maxCount = counts.max() ?? 0
        return 0...max(1, maxCount)
    }
    private var aspectRatio: Double {
        let calendar = Calendar.current
        let weeksInMonth = Set(days.map { calendar.component(.weekOfYear, from: $0.date) }).count
        return weeksInMonth > 0 ? 7.0 / Double(weeksInMonth) : 7.0 / 5.0
    }
    private func weekday(for date: Date) -> Int { Calendar.current.component(.weekday, from: date) }
    
    // MARK: Body
    var body: some View {
        VStack {
            Text(monthDate, format: .dateTime.month(.wide).year())
                .font(.title2.bold()).padding(.top)
            
            if days.isEmpty {
                ContentUnavailableView("No Data", systemImage: "chart.bar.xaxis")
            } else {
                chartView
                    .chartOverlay { proxy in
                        GeometryReader { _ in
                            Rectangle().fill(.clear).contentShape(Rectangle())
                                .simultaneousGesture(
                                    DragGesture(minimumDistance: 0).onEnded { value in
                                        let tapThreshold: CGFloat = 15.0
                                        if abs(value.translation.width) < tapThreshold && abs(value.translation.height) < tapThreshold {
                                            handleTap(at: value.startLocation, proxy: proxy)
                                        }
                                    }
                                )
                        }
                    }
                    .padding(.horizontal)
            }
            Spacer()
        }
        .background(Color(.systemBackground))
    }
    
    // MARK: Chart View & Logic
    private var chartView: some View {
        Chart(days) { day in
            RectangleMark(
                xStart: .value("Weekday Start", weekday(for: day.date)),
                xEnd: .value("Weekday End", weekday(for: day.date) + 1),
                yStart: .value("Week Start", day.date, unit: .weekOfYear),
                yEnd: .value("Week End", day.date, unit: .weekOfYear)
            )
            .clipShape(RoundedRectangle(cornerRadius: 4).inset(by: 2))
            .foregroundStyle(by: .value("Total Exercises", day.totalExerciseCount))
            .annotation(position: .overlay) {
                if day.date.isInSameDay(as: currentDate) {RoundedRectangle(cornerRadius: 4).inset(by: 2).fill(Color.red)}
                if let selectedDate = interactionManager.selectedDate,
                   Calendar.current.isDate(selectedDate, inSameDayAs: day.date) {
                    RoundedRectangle(cornerRadius: 4).inset(by: 1).stroke(Color.primary, lineWidth: 2.5)
                }
            }
        }
        .chartLegend(.hidden)
        .chartXAxis { AxisMarks(values: [1,2,3,4,5,6,7]) { value in
            if let v = value.as(Int.self) { AxisValueLabel { Text(WeekdaySymbols[v-1]) } }
        } }
        .chartXScale(domain: 1...8)
        .chartYAxis { AxisMarks(position: .leading) { _ in } }
        .chartPlotStyle { $0.aspectRatio(aspectRatio, contentMode: .fit) }
        .chartForegroundStyleScale(domain: colorDomain, range: colors)
    }
    
    private func handleTap(at location: CGPoint, proxy: ChartProxy) {
        if let (weekdayTapped, dateTapped) = proxy.value(at: location, as: (Int, Date).self) {
            let calendar = Calendar.current
            if let tappedDay = days.first(where: {
                let sameWeekday = self.weekday(for: $0.date) == weekdayTapped
                let sameWeek = calendar.isDate($0.date, equalTo: dateTapped, toGranularity: .weekOfYear)
                return sameWeekday && sameWeek
            }), !tappedDay.sessions.isEmpty {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    interactionManager.select(date: tappedDay.date, sessions: tappedDay.sessions)
                }
            }
        }
    }
}

extension Date {
    func isInSameDay(as otherDate: Date) -> Bool {
        return Calendar.current.isDate(self, inSameDayAs: otherDate)
    }
    
    func isInSameMonth(as otherDate: Date) -> Bool {
        return Calendar.current.isDate(self, equalTo: otherDate, toGranularity: .month)
    }
    
    // Add more convenience methods as needed, e.g., for year, week, etc.
}
