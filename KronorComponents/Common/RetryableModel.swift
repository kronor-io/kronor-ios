//
//  RetryableModel.swift
//  
//
//  Created by lorenzo on 2023-01-19.
//

import Foundation

protocol RetryableModel: Sendable {
    func cancel() async
    func retry() async
}
