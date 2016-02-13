//
//  ClassExtensions.swift
//  LittleFTP
//
//  Created by Gurinder Hans on 2015-05-26.
//  Copyright (c) 2015 Gurinder Hans. All rights reserved.
//

extension String {
    
    // removes all given characters from string
    func stripCharactersInSet(chars: [Character]) -> String {
        return String(self.characters.filter {chars.indexOf($0) == nil})
    }
}

extension String {
    
    func contains(find: String) -> Bool{
        return self.rangeOfString(find) != nil
    }
}