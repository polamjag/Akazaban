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
    @State private var chinachuHost: String = getChinachuHost()
    @State private var chinachuPort: String = String(getChinachuPort())
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Chinachu Host and Port")) {
                    TextField("rasbperrypi.local", text: $chinachuHost, onCommit: {
                        setChinachuHost(host: self.chinachuHost)
                    })
                    TextField("10772", text: $chinachuPort, onCommit: {
                        setChinachuPort(port: Int(self.chinachuPort))
                    })
                }
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
        }.navigationBarTitle("\(logType.rawValue).log")
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(showModal: .constant(true))
    }
}
