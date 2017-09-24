//
//  Response.swift
//  MusicSearch
//
//  Created by Rey Isla on 9/24/17.
//  Copyright © 2017 Rey Isla. All rights reserved.
//

import Foundation

enum Response<T> {
    case Success(T)
    case Error(ResponseError)
}

enum ResponseError {
    case Parsing
    case Requesting
    case API(errorMessage: String)
}
