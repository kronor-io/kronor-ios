//
//  RetryableModel.swift
//  
//
//  Created by lorenzo on 2023-01-19.
//

import Foundation

protocol RetryableModel {
    func cancel()
    func retry()
}
