//
//  LoadImagesFromRemoteUseCaseTests.swift
//  ImagesAppTests
//
//  Created by Lynneker Souza on 15/06/24.
//

import XCTest
import Foundation
import ImagesApp

final class LoadImagesFromRemoteUseCaseTests: XCTestCase {
    
    func test_init_shouldNotRequestDataFromURL() {
        let (_, client) = makeSUT()

        XCTAssertTrue(client.requestedURLs.isEmpty)
    }

    func test_loadTwice_shouldRequestDataFromURLTwice() {
        let url = URL(string: "https://url.com")!
        let (sut, client) = makeSUT(url: url)

        let search1 = "search1"
        sut.load(search1) { _ in }
        
        let search2 = "search2"
        sut.load(search2) { _ in }
        
        let expect1 = URL(string: url.absoluteString + search1)
        let expect2 = URL(string: url.absoluteString + search2)
        XCTAssertEqual(client.requestedURLs, [expect1, expect2])
    }
    
    func test_load_shouldBeInvalidDataErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()

        let samples = [199, 201, 300, 400, 500]

        samples.enumerated().forEach { index, code in
            expect(sut, toSeach: "test", toCompleteWith: .failure(.invalidData)) {
                let json = makeItemsJSON([])
                client.complete(withStatusCode: code,
                                data: json,
                                at: index)
            }
        }
    }
    
    
    func test_load_shouldDelivesInvalidDataErrorOn200HTTPResponseWithInvalidJSON() {
        let (sut, client) = makeSUT()

        expect(sut, toSeach: "search", toCompleteWith: .failure(.invalidData)) {
            let invalidJSON = Data("invalid json".utf8)
            client.complete(withStatusCode: 200, data: invalidJSON)
        }
    }
    
    // MARK: - Helpers
    private func makeSUT(url: URL = URL(string: "https://url.com")!,
                         file: StaticString = #filePath,
                         line: UInt = #line) -> (sut: RemoteImagesLoader,
                                                 client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteImagesLoader(url: url, client: client)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(client, file: file, line: line)
        return (sut, client)
    }
    
    func expect(_ sut: ImagesSearchLoader,
                toSeach searchString: String,
                toCompleteWith expectedResult: Result<ImagesSerach, RemoteImagesLoader.Error>,
                when action: () -> Void,
                file: StaticString = #filePath,
                line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")

        sut.load(searchString) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedItems), .success(expectedItems)):
                XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)

            case let (.failure(receivedError as RemoteImagesLoader.Error), .failure(expectedError)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)

            default:
                XCTFail("Expected result \(expectedResult) got \(receivedResult) instead", file: file, line: line)
            }

            exp.fulfill()
        }

        action()

        waitForExpectations(timeout: 0.1)
    }
    
    class HTTPClientSpy: HTTPClient {
        private var messages = [(url: URL, 
                                 completion: (HTTPClient.Result) -> Void)]()

        var requestedURLs: [URL] {
            return messages.map { $0.url }
        }

        func get(from url: URL, 
                 completion: @escaping (HTTPClient.Result) -> Void) {
            messages.append((url, completion))
        }

        func complete(with error: Error, 
                      at index: Int = 0,
                      file: StaticString = #filePath,
                      line: UInt = #line) {
            guard messages.count > index else {
                return XCTFail("Can't complete request never made", 
                               file: file,
                               line: line)
            }

            messages[index].completion(.failure(error))
        }

        func complete(withStatusCode code: Int, 
                      data: Data,
                      at index: Int = 0,
                      file: StaticString = #filePath,
                      line: UInt = #line) {
            guard requestedURLs.count > index else {
                return XCTFail("Can't complete request never made", 
                               file: file,
                               line: line)
            }
            
            let response = HTTPURLResponse(url: requestedURLs[index],
                                           statusCode: code,
                                           httpVersion: nil,
                                           headerFields: nil)!

            messages[index].completion(.success((data, response)))
        }
    }

    private func makeItemsJSON(_ items: [[String: Any]]) -> Data {
        let json = ["items": items]
        return try! JSONSerialization.data(withJSONObject: json)
    }
}
