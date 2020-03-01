//
//  Channel.swift
//  chinachulist
//
//  Created by Satoru ABE on 2020/03/01.
//  Copyright © 2020 Satoru ABE. All rights reserved.
//

import SwiftUI

struct ChannelRow: View {
    var channel: Channel
    
    var body: some View {
        NavigationLink(destination: ChannelDetailView(channel: channel)) {
            VStack(alignment: .leading) {
                Text(channel.name)
                if (channel.currentProgram != nil) {
                    Text(channel.currentProgram!.title)
                        .font(.system(size: 13))
                        .foregroundColor(Color.gray)
                }
            }.contextMenu {
                Button(action: { openStreamingInVLC(channelId: self.channel.id)}) {
                    Text("Stream in VLC")
                    Image(systemName: "play.rectangle")
                }
            }
        }
    }
}

struct ChannelDetailView: View {
    static let programDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.timeStyle = .short
        f.dateStyle = .none
        return f
    }()
    
    var channel: Channel
    
    var body: some View {
        List {
            ForEach(channel.programsByDate, id: \.date) { programsByDate in
                Section(header: Text(programsByDate.date)) {
                    ForEach(programsByDate.programs, id: \.id) { program in
                        NavigationLink(destination: ProgramDetailView(channel: self.channel, program: program)) {
                            HStack {
                                VStack (alignment: .leading) {
                                    Text(program.title)
                                    Text(Self.programDateFormatter.string(from: program.start))
                                        .font(.system(size: 13))
                                        .foregroundColor(Color.gray)
                                }
                                Spacer()
                                if (program.isInLiveNow) {
                                    Image(systemName: "bolt.horizontal.circle.fill")
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationBarItems(trailing:
            Button(
                action: { openStreamingInVLC(channelId: self.channel.id) },
                label: { Image(systemName: "play.rectangle") }
            )
        )
        .navigationBarTitle(channel.name)
    }
}
