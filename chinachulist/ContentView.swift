//
//  ContentView.swift
//  chinachulist
//
//  Created by Satoru ABE on 2020/03/01.
//  Copyright © 2020 Satoru ABE. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var fetcher = ScheduleFetcher()
    @State private var showModal = false
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                List {
                    Section(header: Text("In Live")) {
                        ForEach(fetcher.channels.filter({ $0.currentProgram != nil }), id: \.id) { channel in
                            ChannelRow(channel: channel)
                        }
                    }
                    Section(header: Text("Not In Live")) {
                        ForEach(fetcher.channels.filter({ $0.currentProgram == nil }), id: \.id) { channel in
                            ChannelRow(channel: channel)
                        }
                    }
                }
            }
            .navigationBarItems(trailing:
                Button(
                    action: { self.showModal.toggle() },
                    label: { Image(systemName: "gear") }
                ).sheet(isPresented: $showModal) {
                    ModalView(showModal: self.$showModal)
                }
            )
            .navigationBarTitle("chinachu")
        }
    }

}

struct ModalView: View {
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

struct ModalView_Previews: PreviewProvider {
    static var previews: some View {
        ModalView(showModal: .constant(true))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
