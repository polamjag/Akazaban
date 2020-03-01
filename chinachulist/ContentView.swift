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
                    SettingsView(showModal: self.$showModal)
                }
            )
            .navigationBarTitle("chinachu")
        }
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
