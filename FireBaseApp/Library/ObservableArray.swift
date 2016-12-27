//
//  ObservableArray.swift
//  VidMeTest
//
//  Created by Nikola Andriiev on 23.11.16.
//  Copyright © 2016 Andriiev.Mykola. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

public enum ChangeModel {
    case add(index: Int)
    case addInRange(range: CountableRange<Int>)
    case remove(index: Int)
    //not implemented
//    case move(fromIndex: Int, toIndex: Int)
//    case exchange(index: Int, witnIndex: Int)
}

struct ObservableArray <Element: Equatable> {
    var content = [Element]()
    
    // MARK: Observable variable changeModel (add, remove)
    public let changeModel = PublishSubject<ChangeModel>()
    
    // MARK: Public fuctions and variables
    public var count: Int { return self.content.count }
    public var isEmpty: Bool { return self.content.isEmpty }
    
    public func contains<Element: Equatable>(obj: Element) -> Bool {
       return Locker.syncedValue(lock: self, closure: {
            return self.content.filter({ $0 as? Element == obj }).count > 0
        })
    }
    
    public mutating func add(_ member: Element, atIndex index: Int) {
        Locker.synced(lock: self, closure: {
            if  self.contains(obj: member) == false {
                self.content.insert(member, at: index)
                self.changeModel.onNext(.add(index: index))
            }
        })
    }
    
    public mutating func add(_ member: Element) {
        self.add(member, atIndex: self.count)
    }
    
    public mutating func addMembers(_ members: [Element]) {
        Locker.synced(lock: self, closure: {
            var elementsCount = 0
            for member in members {
                if self.contains(obj: member) == false {
                    self.content.append(member)
                    elementsCount += 1
                }
            }
            
            if elementsCount > 0 {
                let lastIndex = self.count
                let range = lastIndex - elementsCount..<lastIndex
                self.changeModel.onNext(ChangeModel.addInRange(range: range))
            }
        })
    }

    public mutating func removeAtIndex(_ index: Int) {
        Locker.synced(lock: self, closure: {
            if index < self.content.count {
                self.content.remove(at: index)
                self.changeModel.onNext(.remove(index: index))
            }
        })
    }
    
    public mutating func remove(_ member: Element) {
        Locker.synced(lock: self, closure: {
            if let index = self.content.index(of: member) {
                self.removeAtIndex(index)
            }
        })
    }
    
    public mutating func removeAll() {
        return Locker.syncedValue(lock: self, closure: {
            self.content.removeAll()
        })  
    }
    
    public func objectAtIndex(_ index: Int) -> Element? {
        return  Locker.syncedValue(lock: self, closure: {
            if index < self.count {
                return self.content[index]
            }
            
            return nil
        })
    }
    
    //public func moveOb
}

extension ObservableArray: Collection {
    typealias Iterator = IndexingIterator<[Element]>
    func makeIterator() -> ObservableArray.Iterator {
        return self.content.makeIterator()
    }
    
    var startIndex: Int { return content.startIndex }
    var endIndex: Int { return content.endIndex }
    var indices: CountableRange <Int> { return content.indices }
    subscript (position: Int) -> Element { return content[position] }
    func index(after i: Int) -> Int { return self.content.index(after: i) }
}

