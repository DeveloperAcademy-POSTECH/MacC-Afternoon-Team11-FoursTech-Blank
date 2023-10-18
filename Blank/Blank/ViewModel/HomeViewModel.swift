//
//  HomeViewModel.swift
//  Blank
//
//  Created by 윤범태 on 2023/10/16.
//

import Foundation

class HomeViewModel: ObservableObject {
    @Published var fileList: [File] = []
    @Published var selectedFileList: Set<URL> = []
    @Published var searchText = ""
    
    init() {
        fetchDocumentFileList()
    }
    
    /// 검색(필터링) 결과를 출력
    /// https://www.swiftyplace.com/blog/swiftui-search-bar-best-practices-and-examples
    var filteredFileList: [File] {
        guard !searchText.isEmpty else {
            return fileList
        }
        
        return fileList.filter { info in
            let lastComponent = info.fileURL.lastPathComponent
            return lastComponent.lowercased().contains(searchText.lowercased())
        }
    }
    
    /// 파일 목록을 가져와서 [File] 형태로 저장
    func fetchDocumentFileList() {
        guard let documentDirectoryURL = FileManager.documentDirectoryURL else {
            return
        }
        
        do {
            let directoryContents = try FileManager.default.contentsOfDirectory(
                at: documentDirectoryURL,
                includingPropertiesForKeys: nil
            )
            
            
            // TODO: - File 오브젝트 생성 부분
            self.fileList = directoryContents.map { url in
                File(id: UUID(),
                     fileURL: url,
                     fileName: url.lastPathComponent,
                     totalPageCount: pageCount(of: url) ?? 0,
                     pages: []
                )
            }
            
        } catch {
            print(error)
        }
    }
    
    func removeFiles(urls: [URL]) {
        FileManager.default.delete(at: urls)
        fetchDocumentFileList()
    }
    
    /// 파일을 외부로부터 문서 폴더에 추가
    /// - Returns: 파일 복사의 성공/실패 여부
    func copyFileToDocumentBundle(from url: URL) -> Bool {
        // TODO: - 이미 존재하는 파일은 복사를 더 할지, 덮어쓸지, 아니면 그냥 지나칠지 물어보기
        guard let documentDirectoryURL = FileManager.documentDirectoryURL else {
            fatalError("[Fatal Error] Document 폴더는 무조건 있습니다.")
        }
        
        return FileManager.default.secureCopyItem(
            at: url,
            to: documentDirectoryURL.appendingPathComponent(url.lastPathComponent)
        )
    }
    
    /// 예제 파일들을 Document 폴더에 복사 (처음 설치했을 때만 실행되어야 함)
    static func copySampleFiles() {
        let sampleFiles: [URL] = [
            Bundle.main.url(forResource: "sample", withExtension: "pdf"),
            Bundle.main.url(forResource: "blank", withExtension: "pdf"),
            Bundle.main.url(forResource: "toeic", withExtension: "pdf"),
            Bundle.main.url(forResource: "horizontal", withExtension: "pdf"),
        ].compactMap { $0 }
        
        sampleFiles.forEach { fileURL in
            guard let newURL = FileManager.documentDirectoryURL?.appendingPathComponent(fileURL.lastPathComponent) else {
                return
            }
            
            let copyResult = FileManager.default.secureCopyItem(at: fileURL, to: newURL)
            print(newURL.lastPathComponent, " / result:", copyResult)
        }
    }
}