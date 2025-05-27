/*
Copyright 2025 Adobe. All rights reserved.
This file is licensed to you under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License. You may obtain a copy
of the License at http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under
the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR REPRESENTATIONS
OF ANY KIND, either express or implied. See the License for the specific language
governing permissions and limitations under the License.
*/

import ActivityKit
import AEPMessagingLiveActivity

@available(iOS 16.1, *)
struct GameScoreLiveActivityAttributes: LiveActivityAttributes {
    
    // static attribute
    var liveActivityData: LiveActivityData
    var mOptString: String?
    var mString : String
    var mInt : Int
    var mDouble : Double
    var mBool : Bool
    var mArray : [String]
    var mObject : [Venue]
    var normalDict : [String : String]
    var normalArray : [String]
    var complexDict : [String: Venue]
    var complexArray : [Venue]
    var superComplexArray : [[String: [String: Venue]]]

    
    // Dynamic Attributes
    struct ContentState: Codable, Hashable {
        var homeTeamScore: Int
        var awayTeamScore: Int
        var statusText: String
    }
}

struct Venue : Codable {
    var name: String
    var asdf: String?
}

//@available(iOS 16.1, *)
//extension GameScoreLiveActivityAttributes : LiveActivityAssuranceDebuggable {
//    
//    func getAttributes() -> Self {
//        // Here you return an instance of GameScoreLiveActivityAttributes
//        // You can initialize it with some dummy data for debugging
//        return GameScoreLiveActivityAttributes(liveActivityData: LiveActivityData(liveActivityID: "debugID"))
//    }
//
//    func getContentState() -> ContentState {
//        // Here you return an instance of ContentState with dummy data
//        return ContentState(homeTeamScore: 10, awayTeamScore: 20, statusText: "Game Over")
//    }
//}


@available(iOS 16.1, *)
extension GameScoreLiveActivityAttributes: LiveActivityAssuranceDebuggable {
    static func getDebugInfo() -> (
        attributes: GameScoreLiveActivityAttributes,
        state: GameScoreLiveActivityAttributes.ContentState
    ) {
        (GameScoreLiveActivityAttributes(
            liveActivityData: LiveActivityData(liveActivityID: "debugID"),
            mOptString: "optionalDebugString",
            mString: "debugString",
            mInt: 123,
            mDouble: 123.456,
            mBool: true,
            mArray: ["debugVal1", "debugVal2"],
            mObject: [Venue(name: "Debug Stadium", asdf: "debugAsdfValue")],
            normalDict: ["normalKey": "normalVal"],
            normalArray: ["s"],
            complexDict: ["debugKey": Venue(name: "Debug Stadium", asdf: "debugAsdfValue")],
            complexArray: [Venue(name: "Complex Venue", asdf: "complexAsdf")],
            superComplexArray: [["outerKey": ["innerKey": Venue(name: "Super Complex Venue", asdf: "superAsdf")] ]]
        ), ContentState(
            homeTeamScore: 10,
            awayTeamScore: 20,
            statusText: "Game Over"
        ))
    }
}
