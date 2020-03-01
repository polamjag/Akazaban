//
//  Program.swift
//  chinachulist
//
//  Created by Satoru ABE on 2020/03/01.
//  Copyright © 2020 Satoru ABE. All rights reserved.
//

import SwiftUI

struct Program: Decodable, Identifiable {
    public var id: String
    public var title: String
    public var start: Date
    public var end: Date
    public var seconds: Int
    public var detail: String
        
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case title = "title"
        case start = "start"
        case end = "end"
        case seconds = "seconds"
        case detail = "detail"
    }
    
    var isInLiveNow: Bool {
        let now = Date()
        return start <= now && now < end;
    }
}

struct ProgramDetailView: View {
    static let programDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.timeStyle = .short
        f.dateStyle = .short
        return f
    }()

    var channel: Channel
    var program: Program

    var body: some View {
        VStack(alignment: .leading) {
            ScrollView() {
                Text("\(Self.programDateFormatter.string(from: program.start)) - \(Self.programDateFormatter.string(from: program.end))")
                        .font(.system(size: 13))
                        .foregroundColor(Color.gray)
                        .padding()
                Text(program.detail)
                    .padding()
                if (program.isInLiveNow) {
                    Button(
                        action: { openStreamingInVLC(channelId: self.channel.id) },
                        label: {
                            HStack {
                                Image(systemName: "play.rectangle")
                                Text("View Live")
                            }
                        }
                    )
                    .padding()
                }
            }
        }
        .navigationBarTitle(program.title)
    }
}
