import Foundation

@available(iOS 13.0, *)
@objc public class MessagingUI : NSObject {
    
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
    
    public static func getCardsForSurfaces(_ surface: Surface, _ completion: @escaping ([ContentCardUI]) -> Void){
        
        Messaging.getPropositionsForSurfaces([surface], {_,_ in 
            var cards: [ContentCardUI] = []
            do {
                for cardData in cardDataList {
                    let jsonData = try JSONSerialization.data(withJSONObject: cardData, options: [])
                    let card = try JSONDecoder().decode(ContentCardSchemaData.self, from: jsonData)
                    cards.append(ContentCardUI(data: card))
                }
            } catch {
                print("Failed to decode JSON:", error)
            }
            completion(cards)
        })
    }
    
}

///
/// Messaging extension changes
///
/// 1. Remove ContentCard Public class
/// 2. Messaging.getContentCardData [surface : ContentCard]
