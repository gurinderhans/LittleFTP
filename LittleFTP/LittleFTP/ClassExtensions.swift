//
//  ClassExtensions.swift
//  LittleFTP
//
//  Created by Gurinder Hans on 2015-05-26.
//  Copyright (c) 2015 Gurinder Hans. All rights reserved.
//

import Foundation

//
// MARK: Extensions
//


extension String {
    
    // removes all given characters from string
    func stripCharactersInSet(chars: [Character]) -> String {
        return String(filter(self) {find(chars, $0) == nil})
    }
}

extension String {
    
    func contains(find: String) -> Bool{
        return self.rangeOfString(find) != nil
    }
}