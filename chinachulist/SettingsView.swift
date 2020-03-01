//
//  SettingsView.swift
//  chinachulist
//
//  Created by Satoru ABE on 2020/03/01.
//  Copyright © 2020 Satoru ABE. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
    @Binding var showModal: Bool
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Logs")) {
                    NavigationLink(destination: ChinachuLogView(logType: .logTypeWui)) {
                        VStack {
                            Text("wui")
                        }
                    }
                    NavigationLink(destination: ChinachuLogView(logType: .logTypeOperator)) {
                        VStack {
                            Text("operator")
                        }
                    }
                    NavigationLink(destination: ChinachuLogView(logType: .logTypeScheduler)) {
                        VStack {
                            Text("scheduler")
                        }
                    }
                }
            }
            .navigationBarItems(trailing:
                Button("Close") {
                    self.showModal.toggle()
                }
            )
            .navigationBarTitle("Settings")
        }
    }
}

struct ChinachuLogView: View {
    @ObservedObject var logFetcher = LogFetcher()
    var logType: ChinachuLogType
    
    var body: some View {
        ScrollView {
            Text(logFetcher.log)
                .font(.custom("Menlo", size: 12.0))
                .padding()
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
        }.onAppear {
            self.logFetcher.get(logType: self.logType)
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(showModal: .constant(true))
    }
}
