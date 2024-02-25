//
//  ContentView.swift
//  BetterRest
//
//  Created by Vinicius Ledis on 29/01/2024.
//

import CoreML
import SwiftUI

struct ContentView: View {
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? .now
    }
    
    var body: some View {
        NavigationStack{
            Spacer(minLength: 20)
            Form {
                Section {
                    VStack {
                        Text("Que horas você quer acordar?")
                            .font(.headline)
                            .padding(.leading)
                            
                        
                        DatePicker("Selecione um horario", selection: $wakeUp, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                    }
                }
                
               Section {
                   VStack {
                       Text("Tempo desejado de sono?")
                           .font(.headline)
                       
                       Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                   }
                }
                
                Section {
                    VStack {
                        Text("""
                            Xicaras de café
                            consumida diariamente?
                            """)
                            .font(.headline)
                            .multilineTextAlignment(.center)
                        
                        Picker("Quantidade de xicaras", selection: $coffeeAmount) {
                            ForEach(0...10, id: \.self) {
                                Text("\($0)")
                            }
                        }
                        
//                        Stepper(coffeeAmount == 1 ? "1 xícara" : "\(coffeeAmount) xícaras", value: $coffeeAmount, in: 0...10)
                    }
                }
                
            }
            .navigationTitle("BetterRest")
            .toolbar {
                Button("Calcular") {
                    calculateBedtime()
                    showingAlert = true
                }
            }
            .alert(alertTitle, isPresented: $showingAlert) {
                Button("OK"){ }
            } message: {
                Text(alertMessage)
            }
        }
    }
    func calculateBedtime() {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            
            let sleepTime = wakeUp - prediction.actualSleep
            
            alertTitle = "A hora ideal para você ir dormir é..."
            alertMessage = sleepTime.formatted(date: .omitted, time: .shortened)
        } catch {
            alertTitle = "Erro!"
            alertMessage = "Desculpa, tivemos um erro em calcular a hora ideal para voce dormir."
        }
    }
}


#Preview {
    ContentView()
}
