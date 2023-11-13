//
//  LoadImageCommentsFromRemoteUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Pallavi on 26.09.23.
//

import XCTest
import EssentialFeed

class ImageCommentsMapperTests: XCTestCase {
    
    

    
    func test_map_ThrowsErrorOnNon200HTTPResponse() throws {
        let json = makeItemJSON(item: [])
     
        let samples = [199, 300, 400, 500, 150]
        
       try samples.forEach {  code in
            XCTAssertThrowsError(
                try ImageCommentMapper.map(json, response: HTTPURLResponse(url: anyURL(), statusCode: code, httpVersion: nil, headerFields: nil)!)
            )
            
            }
        }
    
    
    
  
    func test_map_throwsErrorOn2xxHTTPResponseWithInvalidJSON() throws {
        let invalidJSON = Data("invalid json".utf8)

            let samples = [200, 201, 250, 280, 299]

            try samples.forEach {  code in
                XCTAssertThrowsError(
                    try ImageCommentMapper.map(invalidJSON, response: HTTPURLResponse(url: anyURL(), statusCode: code, httpVersion: nil, headerFields: nil)!)
                )
            }
        }

        func test_map_ThrowsNoItemsOn2xxHTTPResponseWithEmptyJSONList() throws {

            let Emptyjson = makeItemJSON(item: [])
            let samples = [200, 201, 250, 280, 299]

           try samples.forEach{  code in
                 let result  = try ImageCommentMapper.map(Emptyjson, response: HTTPURLResponse(url: anyURL(), statusCode: code, httpVersion: nil, headerFields: nil)!)
               XCTAssertEqual(result, [])
            }
        }
    
    func test_map_ThrowsItemsOn2xxHTTPResponseWithJSONItems() throws{
        
        let item1 = makeItem(id: UUID(),
                             message: "First message",
                             createdAt: (Date(timeIntervalSince1970: 1577881882), "2020-01-01T12:31:22+00:00"),
                             username: "Dnyanesh")
        
        let item2 = makeItem(id: UUID(),
                             message: "I am working",
                             createdAt: (Date(timeIntervalSince1970: 1598627222), "2020-08-28T15:07:02+00:00"),
                             username:"Pallavi")
        
        
        let json = makeItemJSON(item: [item1.json, item2.json])
        
        let samples = [200, 201, 250, 280, 299]
        
        try samples.forEach {  code in
            let result  = try ImageCommentMapper.map(json, response: HTTPURLResponse(url: anyURL(), statusCode: code, httpVersion: nil, headerFields: nil)!)
            XCTAssertEqual(result, [item1.model,item2.model])
        }
    }
    
    
    
    private func makeItem(id:  UUID, message: String, createdAt: (date: Date, isoString: String),username: String ) -> (model: ImageComment, json: [String: Any])
    {
        let item = ImageComment(id: id, message: message, createdAt: createdAt.date, username: username)
        
        let json: [String:Any] = ["id":  id.uuidString,
                    "message": message,
                     "created_at":  createdAt.isoString,
                    "author": [
                        "username": username
                    ]
        ]
        
        return (item, json)
        
        
    }
    
    private func makeItemJSON(item: [[String: Any]]) -> Data {
        let json = ["items": item]
        
        return try! JSONSerialization.data(withJSONObject: json)
    }
}

