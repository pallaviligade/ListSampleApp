//
//  FeedStoreSpec.swift
//  EssentialFeedTests
//
//  Created by Pallavi on 15.05.23.
//

import Foundation
protocol FeedStoreSpec {
    func test_retrieve_deliversEmptyOnEmptyCache()
    func test_retrieve_hasNoSideEffectsOnEmptyCache()
    func test_retrieve_deliversFoundValuesOnNonEmptyCache()
    func test_retrieve_hasNoSideEffectsOnNonEmptyCache()

    func test_insert_deliversNoErrorOnEmptyCache()
    func test_insert_deliversNoErrorOnNonEmptyCache()
    func test_insert_overridesPreviouslyInsertedCacheValues()

    func test_delete_deliversNoErrorOnEmptyCache()
    func test_delete_hasNoSideEffectsOnEmptyCache()
    func test_delete_deliversNoErrorOnNonEmptyCache()
    func test_delete_emptiesPreviouslyInsertedCache()

}
protocol FailableRetrieveFeedStoreSpecs: FeedStoreSpec {
    func test_retrieve_deliversFailureOnRetrievalError()
    func test_retrieve_hasNoSideEffectsOnFailure()
}
protocol FailableInsertFeedStoreSpecs: FeedStoreSpec {
    func test_insert_deliveryErrorOnInsertionError()
    func test_insert_hasNoSideEffectInInsertionError()
}

protocol FailableDeleteFeedStoreSpecs: FeedStoreSpec {
    func test_delete_deliversErrorOnDeletionError()
    func test_delete_hasNoSideEffectsOnDeletionError()
}

typealias FailableFeedStoreSpecs = FailableRetrieveFeedStoreSpecs & FailableInsertFeedStoreSpecs & FailableDeleteFeedStoreSpecs
