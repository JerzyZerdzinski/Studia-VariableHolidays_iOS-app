//
//  ContentView.swift
//  VariableHolidays
//
//  Created by Jerzy Żerdziński on 20/05/2025.
//

import SwiftUI
 
struct ContentView: View {
 
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM yyyy - HH:mm"
        return formatter
    }()
 
    @State var dateStart = Date()
    @State var dateEnd = Date()
 
    var body: some View {
        VStack {
            Text("Date calculator").font(.title)
            Spacer()
            DatePicker("Enter first date", selection: $dateStart, in: ...dateEnd, displayedComponents: .date)
                .datePickerStyle(.automatic)
            DatePicker("Enter second date", selection: $dateEnd, in: dateStart..., displayedComponents: .date)
                .datePickerStyle(.automatic)
            Spacer()
            Text("Days between: \(dateStart.daysBetween(date: dateEnd))")
            Text("Workdays: \(dateStart.countWorkdays(to: dateEnd))")
            Spacer()
        }
        .padding()
    }
}
 
#Preview {
    ContentView()
}
