//
//  UserPage.swift
//  Workout_App_IOS
//
//  Created by Brody Whalen on 5/12/25.
//

import SwiftUI
import SwiftData
import Charts

struct UserPage: View {
    @Environment(\.modelContext) private var modelContext
    
    // This array will hold the first day of each month we want to display.
    @State private var monthsToDisplay: [Date] = []
    @State private var scrollPosition: Date?
    
    var body: some View {
        NavigationStack {
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 0) {
                    ForEach(monthsToDisplay, id: \.self) { monthDate in
                        // Create the specific month chart view for each date.
                        MonthContributionChartView(monthDate: monthDate)
                        // This modifier makes each month view take up the full screen width.
                            .containerRelativeFrame(.horizontal)
                    }
                }
                // This modifier is essential for the snapping behavior, marking the views to snap to.
                .scrollTargetLayout()
            }
            // This iOS 17+ modifier enables the paging/snapping behavior.
            .scrollTargetBehavior(.viewAligned)
            .scrollPosition(id: $scrollPosition)
            .navigationTitle("Workout Calendar")
            .onAppear {
                setupMonths()
            }
        }
    }
    
    /// Generates a range of months to display around the current date.
    private func setupMonths() {
        monthsToDisplay.removeAll()
        let today = Date()
        let calendar = Calendar.current
        
        guard let centralMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: today)) else { return }
        
        // We'll show the last 12 months and the next 6.
        for i in -6...0 {
            if let month = calendar.date(byAdding: .month, value: i, to: centralMonth) {
                monthsToDisplay.append(month)
            }
        }
        scrollPosition = monthsToDisplay.last
    }
    
    
    
    // MARK: - Refactored Contribution Chart View (For a Single Month)
    // This new struct contains all the logic for rendering your GitHub-style contribution chart for one month.
    
    struct MonthContributionChartView: View {
        // The specific month this chart instance represents.
        let monthDate: Date
        
        // The query is now dynamic, fetching data ONLY for the specified month.
        @Query private var workoutSessions: [WorkoutSession]
        
        // MARK: Initializer with Dynamic Query
        init(monthDate: Date) {
            self.monthDate = monthDate
            
            let calendar = Calendar.current
            guard let monthInterval = calendar.dateInterval(of: .month, for: monthDate) else {
                _workoutSessions = Query(filter: #Predicate { _ in false })
                return
            }
            
            let startDate = monthInterval.start
            let endDate = monthInterval.end
            
            // This predicate filters sessions to be within the month's date range.
            let filter = #Predicate<WorkoutSession> {
                $0.timestart >= startDate && $0.timestart < endDate
            }
            
            _workoutSessions = Query(filter: filter, sort: \.timestart)
        }
        
        // MARK: Chart-Specific Properties (moved from original UserPage)
        private var WeekdaySymbols: [String] {
            ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        }
        
        private var colors: [Color] {
            (0...10).map { index in
                if index == 0 { return Color(.systemGray5) }
                return Color(.systemGreen).opacity(Double(index) / 10)
            }
        }
        private var colorDomain: ClosedRange<Int> {
            let counts = denseWorkoutSessions.map { $0.exercises.count }
            let minCount = counts.min() ?? 0
            let maxCount = counts.max() ?? 0
            return (minCount == maxCount) ? 0...1 : minCount...maxCount
        }
        
        /// This computed property now generates a dense array for the *specific month* of this view.
        private var denseWorkoutSessions: [WorkoutSession] {
            let calendar = Calendar.current
            
            // Use `self.monthDate` instead of `Date()`
            guard let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: self.monthDate)),
                  let monthRange = calendar.range(of: .day, in: .month, for: self.monthDate) else {
                return []
            }
            
            let sessionsByDay = Dictionary(grouping: workoutSessions) {
                calendar.startOfDay(for: $0.timestart)
            }.compactMapValues { $0.first }
            
            var dense: [WorkoutSession] = []
            for offset in 0..<monthRange.count {
                guard let date = calendar.date(byAdding: .day, value: offset, to: monthStart) else { continue }
                
                if let realSession = sessionsByDay[calendar.startOfDay(for: date)] {
                    dense.append(realSession)
                } else {
                    // Create placeholder for days with no workouts.
                    let placeholder = WorkoutSession(timestart: date, timeend: nil, exercises: [])
                    dense.append(placeholder)
                }
            }
            return dense
        }
        
        private func weekday(for date: Date) -> Int {
            Calendar.current.component(.weekday, from: date) // Sunday = 1, Saturday = 7
        }
        
        private var aspectRatio: Double {
            let calendar = Calendar.current
            let weeksInMonth = Set(denseWorkoutSessions.map {
                calendar.component(.weekOfYear, from: $0.timestart)
            }).count
            // Avoid division by zero if there are no sessions
            guard weeksInMonth > 0 else { return 7.0 / 5.0 }
            return 7.0 / Double(weeksInMonth)
        }
        
        // MARK: Body
        var body: some View {
            VStack {
                // 1. Title with month name and year
                Text(monthDate, format: .dateTime.month(.wide).year())
                    .font(.title2.bold())
                    .padding(.top)
                
                // 2. Your original Chart logic, now in its own view
                if denseWorkoutSessions.isEmpty {
                    ContentUnavailableView("Loading Chart...", systemImage: "chart.bar.xaxis")
                } else {
                    Chart(denseWorkoutSessions) { session in
                        RectangleMark(
                            xStart: .value("Start weekday", weekday(for: session.timestart)),
                            xEnd: .value("End weekday", weekday(for: session.timestart) + 1),
                            yStart: .value("Start Week", session.timestart, unit: .weekOfYear),
                            yEnd: .value("End Week", session.timestart, unit: .weekOfYear)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 4).inset(by: 2))
                        .foregroundStyle(by: .value("Count", session.exercises.count))
                    }
                    .chartLegend(.hidden)
                    .chartXAxis {
                        AxisMarks(values: [1,2,3,4,5,6,7]) { value in
                            if let value = value.as(Int.self) {
                                AxisValueLabel { Text(WeekdaySymbols[value-1]) }
                            }
                        }
                    }
                    .chartXScale(domain: 1...8)
                    .chartYAxis { AxisMarks(position: .leading) { _ in } } // Hides Y-axis labels/ticks
                    .chartPlotStyle { content in
                        content.aspectRatio(aspectRatio, contentMode: .fit)
                    }
//                    .chartForegroundStyleScale(range: Gradient(colors: colors))
                    .chartForegroundStyleScale(domain: colorDomain, range: Gradient(colors: colors))
                    .padding(.horizontal)
                }
                Spacer() // Pushes content to the top
            }
            .background(Color(.systemBackground))
        }
    }
    //struct UserPage: View {
    //    @Environment(\.modelContext) private var modelContext
    //    @Query var workoutSessions: [WorkoutSession]
    //
    //    private var WeekdaySymbols: [String] {
    //        ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    //    }
    //    // computed var that is dense with empty sessions on missed days.
    //    private var denseWorkoutSessions: [WorkoutSession] {
    //        let calendar = Calendar.current
    //        let now = Date()
    //
    //        // Start of current month
    //        guard let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: now)),
    //              let monthRange = calendar.range(of: .day, in: .month, for: now) else {
    //            return []
    //        }
    //
    //        // Real sessions grouped by day
    //        let sessionsByDay: [Date: WorkoutSession] = Dictionary(
    //            grouping: workoutSessions,
    //            by: { calendar.startOfDay(for: $0.timestart) }
    //        ).compactMapValues { $0.first }
    //
    //        // Generate one day per day in the current month
    //        let daysInMonth = monthRange.count
    //        var dense: [WorkoutSession] = []
    //
    //        for offset in 0..<daysInMonth {
    //            guard let date = calendar.date(byAdding: .day, value: offset, to: monthStart) else { continue }
    //
    //            if let realSession = sessionsByDay[calendar.startOfDay(for: date)] {
    //                dense.append(realSession)
    //            } else {
    //                let placeholder = WorkoutSession(
    //                    timestart: date,
    //                    timeend: nil,
    //                    exercises: []
    //                )
    //                dense.append(placeholder)
    //            }
    //        }
    //
    //        return dense
    //    }
    //
    //    private func weekday(for date: Date) -> Int {
    //        let weekday = Calendar.current.component(.weekday, from: date)
    ////        let adjustedWeekday = (weekday == 1) ? 7 : (weekday - 1)
    ////        return adjustedWeekday
    //        return weekday
    //    }
    //
    //    private var aspectRatio: Double {
    //        let calendar = Calendar.current
    //        let weeks = Set(denseWorkoutSessions.map {
    //            calendar.component(.weekOfYear, from: $0.timestart)
    //        }).count
    ////        return Double(weeks) / 7.0 THIS IS FOR OPPOSITE AXIS
    //        return 7.0/Double(weeks)
    //    }
    //
    //
    //    private var colors: [Color] {
    //        (0...10).map { index in
    //            if index == 0 {
    //                return Color(.systemGray5)
    //            }
    //            return Color(.systemGreen).opacity(Double(index) / 10)
    //        }
    //    }
    //
    //    var body: some View {
    //        GeometryReader { geometry in
    //            let width = geometry.size.width
    //            let height = width / aspectRatio
    //
    //            VStack {
    //                Chart(denseWorkoutSessions){ session in
    //                    RectangleMark(
    //                        xStart: .value("Start weekday", weekday(for: session.timestart)),
    //                        xEnd: .value("End weekday", weekday(for: session.timestart) + 1),
    //
    //                        yStart: .value("Start Week", session.timestart, unit: .weekOfYear),
    //                        yEnd: .value("End Week", session.timestart, unit: .weekOfYear)
    //
    //                    )
    //                    .clipShape(RoundedRectangle(cornerRadius: 4).inset(by: 2))
    //                    .foregroundStyle(by: .value("Count", session.exercises.count))
    //                }
    //                .chartLegend(.hidden)
    //                .chartXAxis {
    //                    AxisMarks(/*position: .leading*/ values: [1,2,3,4,5,6,7]) { value in
    //                        if let value = value.as(Int.self) {
    //                            AxisValueLabel {
    //                                // Symbols from Calendar.current starting with Monday
    //                                Text(WeekdaySymbols[value-1])
    //                            }
    //                            .foregroundStyle(Color(.label))
    //                        }
    //                    }
    //                }
    //                .chartXScale(domain: 1...8)
    //                .chartYAxis {
    //                    AxisMarks(position: .leading)
    //                }
    //                .chartPlotStyle { content in
    //                    content
    //                        .aspectRatio(aspectRatio, contentMode: .fit)
    //                }
    //                .chartForegroundStyleScale(range: Gradient(colors: colors))
    //                .frame(width: width, height: height)
    //                //                .frame(height: 600)
    //
    //                ForEach(workoutSessions) { workoutSessions in
    //                    Text("\(workoutSessions.timestart)")
    //                }
    //            }
    //
    //            //            }
    //
    //        }
    //        .frame(maxWidth: .infinity)
    //    }
    //}
    //
    
    
}
