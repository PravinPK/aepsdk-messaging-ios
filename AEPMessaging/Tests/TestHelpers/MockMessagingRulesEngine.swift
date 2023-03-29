/*
 Copyright 2021 Adobe. All rights reserved.
 This file is licensed to you under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License. You may obtain a copy
 of the License at http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software distributed under
 the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR REPRESENTATIONS
 OF ANY KIND, either express or implied. See the License for the specific language
 governing permissions and limitations under the License.
 */

@testable import AEPCore
@testable import AEPMessaging
@testable import AEPServices
import Foundation

class MockMessagingRulesEngine: MessagingRulesEngine {
    let mockCache: MockCache
    let mockRuntime: TestableExtensionRuntime
    let mockRulesEngine: MockLaunchRulesEngine

    init(name _: String, runtime: ExtensionRuntime) {
        mockCache = MockCache(name: "mockCache")
        mockRuntime = TestableExtensionRuntime()
        mockRulesEngine = MockLaunchRulesEngine(name: "mockRulesEngine", extensionRuntime: runtime)
        super.init(extensionRuntime: mockRuntime, rulesEngine: mockRulesEngine, cache: mockCache)
        //        super.init(name: name, extensionRuntime: runtime)
    }

    override init(extensionRuntime: ExtensionRuntime, rulesEngine: LaunchRulesEngine, cache: Cache) {
        mockCache = MockCache(name: "mockCache")
        mockRuntime = TestableExtensionRuntime()
        mockRulesEngine = MockLaunchRulesEngine(name: "mockRulesEngine", extensionRuntime: extensionRuntime)
        super.init(extensionRuntime: extensionRuntime, rulesEngine: rulesEngine, cache: cache)
    }

    var processCalled = false
    var paramProcessEvent: Event?
    override func process(event: Event) {
        processCalled = true
        paramProcessEvent = event
    }
    
    var loadRulesCalled = false
    var paramLoadRulesRules: [LaunchRule]?
    var paramLoadRulesClearExisting: Bool?
    override func loadRules(_ rules: [LaunchRule], clearExisting: Bool) {
        loadRulesCalled = true
        paramLoadRulesRules = rules
        paramLoadRulesClearExisting = clearExisting
    }
}
