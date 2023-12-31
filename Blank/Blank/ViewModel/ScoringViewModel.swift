//
//  ScoringViewModel.swift
//  Blank
//
//  Created by 윤범태 on 2023/10/24.
//

import UIKit

final class ScoringViewModel: ObservableObject {
    /*
     문제 풀이: 푼 것과 정답을 비교
     맞으면 isCorrect = true
     
     배열이므로 순서가 같다고 가정 =>
     currentWritingValues에는 입력하는 값들
     words는 세션의 words 를 대입
     == 반드시 == initCurrentWritingValues을 words.count와 동일하게 설정해야 합니다.
     */
    
    @Published var page: Page
    @Published var session: Session
    /// 현재 풀고있는 단어들
    @Published var currentWritingWords: [Word] = []
    /// 정답 단어들
    @Published var targetWords: [Word] = []
    /// 넘어온 이미지
    @Published var currentImage: UIImage?
    
    init(page: Page, 
         session: Session,
         currentWritingWords: [Word] = [],
         targetWords: [Word] = [],
         currentImage: UIImage? = nil) {
        self.page = page
        self.session = session
        self.currentWritingWords = currentWritingWords
        self.targetWords = targetWords
        self.currentImage = currentImage
    }
    
    func score() {
        // print("[DEBUG]",  #function,currentWritingWords.count, targetWords.count)
        guard currentWritingWords.count == targetWords.count else {
            print("[DEBUG] currentWritingValues.count와 targetWords.count가 같아야 채점할 수 있습니다.")
            return
        }
        
        currentWritingWords.enumerated().forEach { (index, currentWord) in
            let targetWordIndex = targetWords.firstIndex(where: { $0.id == currentWord.id })!
            
            // 채점 로직:
            // 1) 채점시에는 대소문자 구분없이 글자만 같으면 정답으로 처리한다.
            // 2) 띄어쓰기 입력은 받되 채점시 고려안함
            // 3) [ . ] , [ , ] 도 입력은 받되 채점시 고려 안함
            let replacingRegex = "([ .,…])"
            
            let currentWordValue = currentWord.wordValue
                .lowercased()
                .replacingOccurrences(of: replacingRegex, with: "", options: .regularExpression)
            let targetWordValue = targetWords[targetWordIndex].wordValue
                .lowercased()
                .replacingOccurrences(of: replacingRegex, with: "", options: .regularExpression)
            
            targetWords[targetWordIndex].isCorrect = currentWordValue == targetWordValue
            
        }
    }
    
    /// 워드의 ID를 찾아 해당 워드값을 새값으로 바꿈
    func changeTargetWordValue(id: UUID, newValue: String) {
        guard let index = currentWritingWords.firstIndex(where: { $0.id == id }) else {
            return
        }
        
        currentWritingWords[index].wordValue = newValue
    }
    
    /// CoreData에 현재 세션을 저장
    func saveSessionToDatabase() {
        // CoreData에 세션 저장
        do {
            for i in 0..<targetWords.count {
                targetWords[i].sessionId = session.id
            }
            
            try CDService.shared.appendSession(to: page, session: session)
            try CDService.shared.appendAllWords(to: session, words: targetWords)
        } catch {
            print(error)
        }
    }
    
    var correctCount: Int {
        return targetWords.reduce(0, { $0 + ($1.isCorrect ? 1 : 0) })
    }
    
    var totalWordCount: Int {
        targetWords.count
    }
    
    var correctRate: Double {
        Double(correctCount) / Double(totalWordCount)
    }

    var correctRateTextValue: String {
        return String(format: "%.1f%%", correctRate * 100)
    }
}
