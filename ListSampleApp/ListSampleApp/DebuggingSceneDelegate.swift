//
//  DebuggingSceneDelegate.swift
//  ListSampleApp
//
//  Created by Pallavi on 01.09.23.
//

import UIKit
import EssentialFeed

#if DEBUG
class DebuggingSceneDelegate: SceneDelegate {
    
    override  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
        
        
        if CommandLine.arguments.contains("-reset") {
            try? FileManager.default.removeItem(at: localStoreURL)
        }
        
        super.scene(scene, willConnectTo: session, options: connectionOptions)
    }
    
   override func makeRemoteClient() -> Httpclient {
       if let connectivity =  UserDefaults.standard.string(forKey: "connectivity")  {
            return DebuggingHTTPClient(connectivity: connectivity)
        }
       return super.makeRemoteClient()
    }
    
}


private class DebuggingHTTPClient: Httpclient {
    private class Task: HTTPClientTask {
        func cancel() {}
    }
    
    private let connectivity: String

        init(connectivity: String) {
            self.connectivity = connectivity
        }
    
    func get(from url: URL, completion: @escaping (Httpclient.Result) -> Void) -> HTTPClientTask {
        completion(.failure(NSError(domain: "offline", code: 0)))
        return Task()
    }
}
#endif
