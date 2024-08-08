import Foundation

@available(iOS 13.0, *)
@objc public class AEPSwiftUI : NSObject {
    
    // Example card data
    static let cardDataList: [[String: Any]] = [
        [
            "publishedDate": 1701538942,
            "expiryDate": 1712190456,
            "meta": [
                "adb_template": [
                    "type": "small_image"
                ]
            ],
            "contentType": "application/json",
            "content": [
                "actionUrl": "https://luma.com/sale",
                "title": [
                    "content": "Try AI Assistant"
                ],
                "body": [
                    "content": "Quickly fill out forms, sign them, then share.Quickly fill out forms, sign them, then share.Quickly fill out forms, sign them, then share.Quickly fill out forms, sign them, then share.Quickly fill out forms, sign them, then share.Quickly fill out forms, sign them, then share.Quickly fill out forms, sign them, then share.Quickly fill out forms, sign them, then share.Quickly fill out forms, sign them, then share.Quickly fill out forms, sign them, then share."
                ],
                "image": [
                    "bundle": "acrobatAI"
                ],
                "buttons": [
                    "interactId": "purchaseID",
                    "text": [
                        "content": "Purchase Now"
                    ],
                    "actionUrl": "https://adobe.com/offer"
                ]
            ]
        ],
        [
            "publishedDate": 1701538942,
            "expiryDate": 1712190456,
            "meta": [
                "adb_template": [
                    "type": "small_image"
                ]
            ],
            "contentType": "application/json",
            "content": [
                "actionUrl": "https://luma.com/sale",
                "title": [
                    "content": "Try AI Assistant"
                ],
                "body": [
                    "content": "Quickly fill out forms, sign them, then share."
                ],
                "image": [
                    "bundle": "acrobatAI"
                ],
                "buttons": [
                    "interactId": "purchaseID",
                    "text": [
                        "content": "Purchase Now"
                    ],
                    "actionUrl": "https://adobe.com/offer"
                ]
            ]
        ],
        [
            "publishedDate": 1701538942,
            "expiryDate": 1712190456,
            "meta": [
                "adb_template": [
                    "type": "small_image"
                ]
            ],
            "contentType": "application/json",
            "content": [
                "actionUrl": "https://luma.com/sale",
                "title": [
                    "content": "Try AI Assistant"
                ],
                "body": [
                    "content": "Quickly fill out forms, sign them, then share."
                ],
                "image": [
                    "bundle": "acrobatAI"
                ],
                "buttons": [
                    "interactId": "purchaseID",
                    "text": [
                        "content": "Purchase Now"
                    ],
                    "actionUrl": "https://adobe.com/offer"
                ]
            ]
        ],
        [
            "publishedDate": 1701538942,
            "expiryDate": 1712190456,
            "meta": [
                "adb_template": [
                    "type": "small_image"
                ]
            ],
            "contentType": "application/json",
            "content": [
                "actionUrl": "https://luma.com/sale",
                "title": [
                    "content": "Try AI Assistant"
                ],
                "body": [
                    "content": "Quickly fill out forms, sign them, then share."
                ],
                "image": [
                    "bundle": "acrobatAI"
                ],
                "buttons": [
                    "interactId": "purchaseID",
                    "text": [
                        "content": "Purchase Now"
                    ],
                    "actionUrl": "https://adobe.com/offer"
                ]
            ]
        ],
        [
            "publishedDate": 1701538942,
            "expiryDate": 1712190456,
            "meta": [
                "adb_template": [
                    "type": "small_image"
                ]
            ],
            "contentType": "application/json",
            "content": [
                "actionUrl": "https://luma.com/sale",
                "title": [
                    "content": "Try AI Assistant"
                ],
                "body": [
                    "content": "Quickly fill out forms, sign them, then share."
                ],
                "image": [
                    "bundle": "acrobatAI"
                ],
                "buttons": [
                    "interactId": "purchaseID",
                    "text": [
                        "content": "Purchase Now"
                    ],
                    "actionUrl": "https://adobe.com/offer"
                ]
            ]
        ],
        [
            "publishedDate": 1701538942,
            "expiryDate": 1712190456,
            "meta": [
                "adb_template": [
                    "type": "small_image"
                ]
            ],
            "contentType": "application/json",
            "content": [
                "actionUrl": "https://luma.com/sale",
                "title": [
                    "content": "Try AI Assistant"
                ],
                "body": [
                    "content": "Quickly fill out forms, sign them, then share."
                ],
                "image": [
                    "bundle": "acrobatAI"
                ],
                "buttons": [
                    "interactId": "purchaseID",
                    "text": [
                        "content": "Purchase Now"
                    ],
                    "actionUrl": "https://adobe.com/offer"
                ]
            ]
        ],
        [
            "publishedDate": 1701538942,
            "expiryDate": 1712190456,
            "meta": [
                "adb_template": [
                    "type": "small_image"
                ]
            ],
            "contentType": "application/json",
            "content": [
                "actionUrl": "https://luma.com/sale",
                "title": [
                    "content": "Try AI Assistant"
                ],
                "body": [
                    "content": "Quickly fill out forms, sign them, then share."
                ],
                "image": [
                    "bundle": "acrobatAI"
                ],
                "buttons": [
                    "interactId": "purchaseID",
                    "text": [
                        "content": "Purchase Now"
                    ],
                    "actionUrl": "https://adobe.com/offer"
                ]
            ]
        ],
        [
            "publishedDate": 1701538942,
            "expiryDate": 1712190456,
            "meta": [
                "adb_template": [
                    "type": "small_image"
                ]
            ],
            "contentType": "application/json",
            "content": [
                "actionUrl": "https://luma.com/sale",
                "title": [
                    "content": "Try AI Assistant"
                ],
                "body": [
                    "content": "Quickly fill out forms, sign them, then share."
                ],
                "image": [
                    "bundle": "acrobatAI"
                ],
                "buttons": [
                    "interactId": "purchaseID",
                    "text": [
                        "content": "Purchase Now"
                    ],
                    "actionUrl": "https://adobe.com/offer"
                ]
            ]
        ],
        [
            "publishedDate": 1701538942,
            "expiryDate": 1712190456,
            "meta": [
                "adb_template": [
                    "type": "small_image"
                ]
            ],
            "contentType": "application/json",
            "content": [
                "actionUrl": "https://luma.com/sale",
                "title": [
                    "content": "Try AI Assistant"
                ],
                "body": [
                    "content": "Quickly fill out forms, sign them, then share."
                ],
                "image": [
                    "bundle": "acrobatAI"
                ],
                "buttons": [
                    "interactId": "purchaseID",
                    "text": [
                        "content": "Purchase Now"
                    ],
                    "actionUrl": "https://adobe.com/offer"
                ]
            ]
        ],
        [
            "publishedDate": 1701538942,
            "expiryDate": 1712190456,
            "meta": [
                "adb_template": [
                    "type": "small_image"
                ]
            ],
            "contentType": "application/json",
            "content": [
                "actionUrl": "https://luma.com/sale",
                "title": [
                    "content": "Try AI Assistant"
                ],
                "body": [
                    "content": "Quickly fill out forms, sign them, then share."
                ],
                "image": [
                    "bundle": "acrobatAI"
                ],
                "buttons": [
                    "interactId": "purchaseID",
                    "text": [
                        "content": "Purchase Now"
                    ],
                    "actionUrl": "https://adobe.com/offer"
                ]
            ]
        ]
    ]
    
    public static func getCardsForSurfaces(_ surface: Surface,
                                           cardListener listener: ContentCardUIEventListener? = nil,
                                           cardCustomizer customizer: ContentCardUICustomizer? = nil,
                                           _ completion: @escaping ([ContentCardUI]) -> Void) {
        
            //        Messaging.getPropositionsForSurfaces([surface], {_,_ in
            //        })
        
        var cards: [ContentCardUI] = []
        do {
            for cardData in cardDataList {
                let jsonData = try JSONSerialization.data(withJSONObject: cardData, options: [])
                let card = try JSONDecoder().decode(ContentCardSchemaData.self, from: jsonData)
                let contentCard = ContentCardUI(data: card)
                contentCard.listener = listener
                contentCard.customizer = customizer
                cards.append(contentCard)
            }
        } catch {
            print("Failed to decode JSON:", error)
        }
        completion(cards)
    }
    
}

///
/// Messaging extension changes
///
/// 1. Remove ContentCard Public class
/// 2. Messaging.getContentCardData [surface : ContentCard]
@available(iOS 13.0, *)
public protocol ContentCardUICustomizer {
    func customize(forTemplate : SmallImageTemplate) 
}

@available(iOS 13.0, *)
public protocol ContentCardUIEventListener {
    func didDisplay(_ card: ContentCardUI)
    func didDismiss(_ card: ContentCardUI)
    func didInteract(_ card: ContentCardUI, withInteraction: String?)
}
