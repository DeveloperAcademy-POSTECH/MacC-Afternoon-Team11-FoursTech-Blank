//
//  ResultPageView.swift
//  MacroView
//
//  Created by Greed on 10/14/23.
//

import SwiftUI

struct ResultPageView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var isLinkActive: Bool
    @State var seeCorrect: Bool = true
    @Binding var generatedImage: UIImage?
    @State var visionStart: Bool = false
    
    @StateObject var scoringViewModel: ScoringViewModel
    @StateObject var overViewModel: OverViewModel
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                VStack{
                    resultImage
                    Spacer().frame(height : UIScreen.main.bounds.height * 0.12)
                }
                bottomCorrectInfo
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                     homeBtn
                }
                ToolbarItem(placement: .topBarTrailing) {
                    HStack {
                        seeCorrectBtn
                        backToOverViewBtn
                    }
                }
            }
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(.white, for: .navigationBar)
            .navigationTitle("결과")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
        }
        .background(Color(.systemGray6))
    }
    
    private var bottomCorrectInfo: some View {
        HStack {
            if seeCorrect == true {
                // TODO: 정답률, 문제개수, 정답개수 받아오기
                Spacer().frame(width: 50)
                CorrectInfoView(scoringViewModel: scoringViewModel)
                    .frame(minWidth: 600, maxWidth: 800, minHeight: 50, maxHeight: 70)
                Spacer().frame(width: 50)
            }
            else {
                
            }
        }
    }
    
    private var resultImage: some View {
        // TODO: 각 단어의 정답여부에 따른 색상 마스킹
        PinchZoomView(image: generatedImage, visionStart: $visionStart, basicWords: .constant([]), overViewModel: overViewModel)
    }
    
    private var homeBtn: some View {
        // destination 임시처리
        NavigationLink(destination: HomeView()) {
            Image(systemName: "house")
        }
    }
    
    private var seeCorrectBtn: some View {
        Button {
            seeCorrect.toggle()
        } label: {
            if seeCorrect == true {
                Text("정답률끄기")
            } else {
                Text("정답률보기")
            }
        }
    }
    
    private var backToOverViewBtn: some View {
        Button {
            isLinkActive = false
        } label: {
            Text("페이지 선택으로 이동")
                .fontWeight(.bold)
        }
    }
}

//#Preview {
//    ResultPageView(viewModel: OverViewModel(), isLinkActive: .constant(true))
//}
