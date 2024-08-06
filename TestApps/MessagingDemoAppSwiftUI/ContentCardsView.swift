/*
Copyright 2023 Adobe. All rights reserved.
This file is licensed to you under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License. You may obtain a copy
of the License at http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under
the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR REPRESENTATIONS
OF ANY KIND, either express or implied. See the License for the specific language
governing permissions and limitations under the License.
*/

import AEPMessaging
import SwiftUI

//struct ContentCardsView: View {
//    @State var propositionsDict: [Surface: [Proposition]]? = nil
//    @State private var propositionsHaveBeenFetched = false
//    @State private var pageTitle: String = "Content cards"
//    
//    // staging feeds
////    private let surface = Surface(path: "feeds/schema_feeditem_with_id_hack")
//    // private let surface = Surface(path: "feeds/schema_feeditem_sale")
//    
//    
//    // mobileapp://com.steveb.iamStagingTester/cards/ms
//    private let surface = Surface(path: "cards/ms")
//    
//    // mobileapp://com.steveb.iamStagingTester/cards/613test
////    private let surface = Surface(path: "cards/613test")
//    
//    //
//    struct ExecuteCode : View {
//        init( _ codeToExec: () -> () ) {
//            codeToExec()
//        }
//        
//        var body: some View {
//            EmptyView()
//        }
//    }
//    //
//    
//    var body: some View {
//        NavigationView {
//            VStack {
//                Text(pageTitle)
//                    .font(.title)
//                    .padding(.top, 30)
//                List {
//                    ForEach(propositionsDict?[surface]?.compactMap {
//                        $0.items.first } ?? [], id: \.itemId ) { propositionItem in                            
//                            if let contentCardSchema = propositionItem.contentCardSchemaData,
//                               let contentCard = contentCardSchema.getContentCard() {
//                                
//                                ExecuteCode {
//                                    contentCard.track(withEdgeEventType: .display)
//                                }
//                                NavigationLink(destination: ContentCardDetailView(contentCard: contentCard)) {
//                                    ContentCardListView(contentCard: contentCard)
//                                }
//                                
//                            }
//                        }
//                }
//                .listStyle(.plain)
//                .navigationBarTitle(Text("Back"), displayMode: .inline)
//                .onAppear {
//                    if !propositionsHaveBeenFetched {
//                        Messaging.updatePropositionsForSurfaces([surface])
//                        propositionsHaveBeenFetched = true
//                    }
//                    
//                    Messaging.getPropositionsForSurfaces([surface]) { propositionsDict, error in
//                        guard error == nil else {
//                            return
//                        }
//                        self.propositionsDict = propositionsDict
//                    }
//                }
//            }
//            .navigationBarHidden(true)
//        }
//    }
//}


struct ContentCardsView : View {
    @State var savedCards : [ContentCardUI] = []
    var body: some View {
        
        List {
             ForEach(savedCards) { eachCard in
                 eachCard.view
                     .frame(width: 310,height: 140)
            }
        }
        .listRowSpacing(20)
        .listRowSeparator(.hidden)
        .onAppear(perform: {
            
            SmallImageTemplate.customize = { template in
                // Title text configuration
                template.title.font = .system(size: 15)
                template.title.textColor = .blue


                // Body text configuration
                template.body?.font = .system(size: 13)
                template.body?.textColor = .gray
                
                
                // Action Button configuration
                template.button?.text.font = .system(size: 14)
                
                //template.rootHStack.addView(Text("Hello"))
                
                // Button Stack Configuration
                template.buttonHStack.view.frame(maxWidth : .infinity)
                template.buttonHStack.view.frame(alignment : .trailing)
                
                // image configuration
                //template.image?.layout.padding = EdgeInsets(top: 20, leading: 10, bottom: 20, trailing: 20)
                
                // RootView configuration
                template.rootHStack.view.frame(height : 120)
                template.rootHStack.view.cornerRadius(10)
                template.rootHStack.view.border(.gray, width: 2)
                
                // TextStack configuration
                template.textVStack.spacing = 8
                template.textVStack.view.padding([.leading, .trailing], 10)
            }

            MessagingUI.getCardsForSurfaces(Surface(path: "card"), { cards in
                savedCards = cards
                savedCards.forEach { $0.listener = self }
            })
        })
    }
}

// Conform to the delegate protocol
extension ContentCardsView: ContentCardUIEventListener {
    
    func didDisplay(_ card: ContentCardUI) {
        print("Peaks:Customer knows Display happened")
    }
    
    func didDismiss(_ card: ContentCardUI) {
        print("Peaks:Customer knows Dismiss happened")
    }
    
    func didInteract(_ card: ContentCardUI, withInteraction: String?) {
        print("Customer knows Interaction happened")
    }
    
}

struct ContentCardsView_Previews: PreviewProvider {
    static var previews: some View {
        ContentCardsView()
    }
}

struct PravinModifier : ViewModifier {
    func body(content: Content) -> some View {
         content
            .padding()
            .background(Color.blue)
     }
}


