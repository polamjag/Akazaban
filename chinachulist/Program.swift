//
//  Program.swift
//  chinachulist
//
//  Created by Satoru ABE on 2020/03/01.
//  Copyright © 2020 Satoru ABE. All rights reserved.
//

import SwiftUI

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
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                Text("\(Self.programDateFormatter.string(from: program.start)) - \(Self.programDateFormatter.string(from: program.end))")
                    .font(.caption)
                Text(program.detail)
                    .font(.body)

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
                }
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
            .padding()
        }
        .navigationBarTitle(program.title)
    }
}

struct ProgramDetailView_Preview: PreviewProvider {
    static var previews: some View {
        ProgramDetailView(
            channel: Channel(
                id: "aa", name: "Preview Channel", programs: []
            ),
            program: Program(
                id: "bb", title: "Some Program", start: Date() - 180, end: Date() + 180, seconds: 180, detail: "lorem ipsum ~~"
            )
        )
//        ProgramDetailView(
//            channel: Channel(
//                id: "aa", name: "Preview Channel", programs: []
//            ),
//            program: Program(
//                id: "bb", title: "Some Program", start: Date(), end: Date(), seconds: 180, detail: """
//                    Lorem ipsum dolor sit amet, consectetur adipiscing elit. Cras dui nisi, finibus ac sagittis sit amet, iaculis sit amet mauris. Integer sodales nulla consequat, feugiat urna ut, aliquam odio. In finibus leo urna, vitae convallis risus maximus tempus. Nulla facilisi. Nulla aliquam eros lacus, ac pellentesque dolor porta nec. Maecenas varius nisl non purus gravida porta eu ac eros. Proin lacinia hendrerit turpis, et molestie nunc lacinia vel. Ut ut massa purus. Phasellus ultrices neque et metus hendrerit, nec viverra neque mollis.
//
//                    Vestibulum mattis aliquet odio, ut vulputate arcu mattis eu. Aliquam nec orci lorem. Suspendisse sit amet nibh at ipsum ultrices vestibulum. Sed eget commodo tellus. Interdum et malesuada fames ac ante ipsum primis in faucibus. Aenean vitae vehicula est. Ut cursus ante in maximus semper. Donec fringilla tellus eget ullamcorper vulputate. Praesent nec lacus ante. Proin id neque quis mauris commodo maximus. Suspendisse nec sapien lobortis orci dignissim rhoncus eu vitae mi. Curabitur vestibulum justo eget aliquet sodales. Duis dictum elit et risus tempor, sit amet euismod ipsum posuere.
//                """
//            )
//        )
    }
}
