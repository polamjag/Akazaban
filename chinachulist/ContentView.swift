//
//  ContentView.swift
//  chinachulist
//
//  Created by Satoru ABE on 2020/03/01.
//  Copyright © 2020 Satoru ABE. All rights reserved.
//

import SwiftUI

public class ScheduleFetcher: ObservableObject {
    @Published var channels = [Channel]()
    
    init() {
        load()
    }
    
    func load() {
        let url = URL(string: "http://akari:bakuhatsu@raspberrypi.local:10773/api/schedule.json")!
        
        URLSession.shared.dataTask(with: url) {(data, response, error) in
            do {
                if let d = data {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .millisecondsSince1970
                    let decodedLists = try decoder.decode([Channel].self, from: d)
                    DispatchQueue.main.async {
                        self.channels = decodedLists
                    }
                } else {
                    print("No Data")
                }
            } catch {
                print ("Error")
            }
            
        }.resume()

    }
}

func openStreamingInVLC(channelId: String) {
    var components = URLComponents()
    components.scheme = "vlc-x-callback"
    components.host = "x-callback-url"
    components.path = "/stream"
    components.queryItems = [
        URLQueryItem(name: "url", value: "http://akari:bakuhatsu@raspberrypi.local:10772/api/channel/\(channelId)/watch.m2ts?ext=m2ts&amp;c%3Av=copy&amp;c%3Aa=copy&amp;prefix=http%3A%2F%2Fraspberrypi.local%3A10772%2Fapi%2Fchannel%2F\(channelId)%2F")
    ]
    UIApplication.shared.open(components.url!)
}

struct ContentView: View {
    @ObservedObject var fetcher = ScheduleFetcher()
    
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
            .navigationBarTitle("chinachu")
        }
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
