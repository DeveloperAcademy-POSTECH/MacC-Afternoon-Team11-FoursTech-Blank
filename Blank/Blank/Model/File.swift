//
//  File.swift
//  Blank
//
//  Created by Sup on 10/16/23.
//

import SwiftUI

struct File {
    var id: UUID
    var fileURL: URL
    var fileName: String
    /// PDF 문서의 총 페이지를 표시하기 위한 변수
    var totalPageCount: Int
    var pages: [Page]
}
