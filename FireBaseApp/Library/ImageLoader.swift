//
//  imageLoader.swift
//  Compas
//
//  Created by Nikola Andriiev on 01.11.16.
//  Copyright © 2016 Andriiev.Mykola. All rights reserved.
//

import RxSwift
import Foundation

let LinkErrorDescription = "Inappropriate image link"

class ImageLoader: NSObject {
    private var url: String
    private var task: URLSessionDownloadTask! = nil
    
    deinit {
        self.task.cancel()
    }
    
    init(URLStirng url: String) {
        self.url = url
        super.init()
    }
    
    public func loadImage() -> Observable<UIImage> {
        return Observable<UIImage>.create { (observer) -> Disposable in
            guard let imageUrl = URL(string: self.url) else {
                let error = NSError(domain: LinkErrorDescription,
                                    code: 0,
                                    userInfo: nil)
                observer.onError(error)
                return Disposables.create()
            }
            
            let session = URLSession.shared
            self.task = session.downloadTask(with: imageUrl) { localURL, _, error in
                guard let image = (localURL?.path).flatMap({ return UIImage(contentsOfFile: $0) }) else {
                    if let error = error {
                        observer.onError(error)
                    }
                    
                    return
                }
 
                observer.onNext(image)
                observer.onCompleted()
            }
            
            self.task.resume()
            return Disposables.create {
                self.task.cancel()
            }
            
        }.observeOn(MainScheduler.asyncInstance)
    }
    
//ImageLoader END
}
