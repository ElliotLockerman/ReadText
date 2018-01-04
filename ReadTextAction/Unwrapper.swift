//
//  Unwrapper.swift
//  ReadTextAction
//
//  Created by EL on 1/3/18.
//  Copyright © 2018 el. All rights reserved.
//

import Foundation

func shouldJoin(_ first: String, _ second: String) -> Bool {    
    if first == "" || second == "" {
        return false
    }
    
    if !NSCharacterSet.letters.contains(second.unicodeScalars.first!) {
        return false
    }
    
    guard let space_idx = second.index(of: " ") else {
        return false
    }
    
    
    if first.count + second.distance(from: String.Index(encodedOffset: 0), to:space_idx) <= second.count {
        return false
    }
    
    return true
}



class UnwrapperIterator: IteratorProtocol  {

    typealias Element = String
    
    var lines: [String]
    var line: String?
    var it: IndexingIterator<[String]>
    
    init(_ input: String) {
        var tmp = [String]()
        input.enumerateLines { line, _ in
            tmp.append(line)
        }
        
        lines = tmp
        it = lines.makeIterator()
        line = it.next()
    }
    
    func next() -> String? {
        guard var currentLine = self.line else {
            return nil
        }
        
        while let nextLine = it.next() {
            if shouldJoin(currentLine, nextLine) {
                currentLine = currentLine + " " + nextLine;
            } else {
                self.line = nextLine
                return currentLine
            }
            self.line = currentLine
            
        }
        
        let tmp = self.line
        self.line = nil
        return tmp
    }
    
}

class Unwrapper: Sequence {
    var input = ""
    
    init(_ input: String) {
        self.input = input
    }
    
    func makeIterator() -> UnwrapperIterator {
        return UnwrapperIterator(input)
    }
}


