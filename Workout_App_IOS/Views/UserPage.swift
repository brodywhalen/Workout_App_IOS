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
    @Query var workoutSessions: [WorkoutSession]
    
    private var WeekdaySymbols: [String] {
        ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    }
    // computed var that is dense with empty sessions on missed days.
    private var denseWorkoutSessions: [WorkoutSession] {
        let calendar = Calendar.current
        let now = Date()
        
        // Start of current month
        guard let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: now)),
              let monthRange = calendar.range(of: .day, in: .month, for: now) else {
            return []
        }
        
        // Real sessions grouped by day
        let sessionsByDay: [Date: WorkoutSession] = Dictionary(
            grouping: workoutSessions,
            by: { calendar.startOfDay(for: $0.timestart) }
        ).compactMapValues { $0.first }
        
        // Generate one day per day in the current month
        let daysInMonth = monthRange.count
        var dense: [WorkoutSession] = []
        
        for offset in 0..<daysInMonth {
            guard let date = calendar.date(byAdding: .day, value: offset, to: monthStart) else { continue }
            
            if let realSession = sessionsByDay[calendar.startOfDay(for: date)] {
                dense.append(realSession)
            } else {
                let placeholder = WorkoutSession(
                    timestart: date,
                    timeend: nil,
                    exercises: []
                )
                dense.append(placeholder)
            }
        }
        
        return dense
    }
    
    private func weekday(for date: Date) -> Int {
        let weekday = Calendar.current.component(.weekday, from: date)
//        let adjustedWeekday = (weekday == 1) ? 7 : (weekday - 1)
//        return adjustedWeekday
        return weekday
    }
    
    private var aspectRatio: Double {
        let calendar = Calendar.current
        let weeks = Set(denseWorkoutSessions.map {
            calendar.component(.weekOfYear, from: $0.timestart)
        }).count
//        return Double(weeks) / 7.0 THIS IS FOR OPPOSITE AXIS
        return 7.0/Double(weeks)
    }
    
    
    private var colors: [Color] {
        (0...10).map { index in
            if index == 0 {
                return Color(.systemGray5)
            }
            return Color(.systemGreen).opacity(Double(index) / 10)
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = width / aspectRatio
            
            VStack {
                Chart(denseWorkoutSessions){ session in
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
                    AxisMarks(/*position: .leading*/ values: [1,2,3,4,5,6,7]) { value in
                        if let value = value.as(Int.self) {
                            AxisValueLabel {
                                // Symbols from Calendar.current starting with Monday
                                Text(WeekdaySymbols[value-1])
                            }
                            .foregroundStyle(Color(.label))
                        }
                    }
                }
                .chartXScale(domain: 1...8)
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
                .chartPlotStyle { content in
                    content
                        .aspectRatio(aspectRatio, contentMode: .fit)
                }
                .chartForegroundStyleScale(range: Gradient(colors: colors))
                .frame(width: width, height: height)
                //                .frame(height: 600)
                
                ForEach(workoutSessions) { workoutSessions in
                    Text("\(workoutSessions.timestart)")
                }
            }
            
            //            }
            
        }
        .frame(maxWidth: .infinity)
    }
}



