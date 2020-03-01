//
//  ChinachuAPI.swift
//  chinachulist
//
//  Created by Satoru ABE on 2020/03/01.
//  Copyright © 2020 Satoru ABE. All rights reserved.
//

import Foundation
import UIKit

struct Channel: Decodable, Identifiable {
    public var id: String
    public var name: String
    public var programs: [Program]
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case programs = "programs"
    }
    
    var currentProgram: Program? {
        return programs.first(where: { $0.isOnLiveNow })
    }
    
    var programsInStartOrder: [Program] {
        return programs.sorted(by: { $0.start < $1.start })
    }
    
    var programsByDate: [(date: String, programs: [Program])] {
        let f = DateFormatter()
        f.dateFormat = "YYYY-MM-dd"
        let dic = Dictionary(grouping: programsInStartOrder, by: { f.string(from: $0.start) })
        return dic.keys.sorted().map({
            return ($0, dic[$0]!)
        })
    }
}

enum ProgramCategory: String, Decodable {
    case anime = "anime"
    case information = "information"
    case news = "news"
    case sports = "sports"
    case variety = "variety"
    case drama = "drama"
    case music = "music"
    case cinema = "cinema"
    case etc = "etc"
    case hobby = "hobby"
    case welfare = "welfare"
    case theater = "theater"
    case documentary = "documentary"
}

struct Program: Decodable, Identifiable {
    public var id: String
    
    public var title: String
    public var fullTitle: String
    public var subTitle: String?
    
    public var start: Date
    public var end: Date
    public var seconds: Int
    
    public var detail: String
    public var flags: [String]
    public var episode: Int?
    public var category: ProgramCategory
        
    enum CodingKeys: String, CodingKey {
        case id = "id"
        
        case title = "title"
        case fullTitle = "fullTitle"
        case subTitle = "subTitle"
        
        case start = "start"
        case end = "end"
        case seconds = "seconds"
        
        case detail = "detail"
        case flags = "flags"
        case episode = "episode"
        case category = "category"
    }
    
    var isOnLiveNow: Bool {
        let now = Date()
        return start <= now && now < end;
    }
}

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

enum ChinachuLogType: String {
    case logTypeWui = "wui"
    case logTypeOperator = "operator"
    case logTypeScheduler = "scheduler"
}

public class LogFetcher: ObservableObject {
    @Published var log: String = ""
    @Published var logType: ChinachuLogType = .logTypeWui

    func get(logType: ChinachuLogType) {
        let url = URL(string: "http://akari:bakuhatsu@raspberrypi.local:10773/api/log/\(logType.rawValue).txt")!
        
        URLSession.shared.dataTask(with: url) {(data, response, error) in
            do {
                if let d = data {
                    DispatchQueue.main.async {
                        self.log = String(decoding: d, as: UTF8.self)
                    }
                } else {
                    print("No Data")
                }
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
