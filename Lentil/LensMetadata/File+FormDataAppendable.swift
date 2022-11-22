// Lentil
// Created by Laura and Cordt Zermin

import Foundation


protocol FormDataAppendable {
  var data: Data { get }
  var name: String { get }
  var fileName: String { get }
  var fileMimeType: String? { get }
}
