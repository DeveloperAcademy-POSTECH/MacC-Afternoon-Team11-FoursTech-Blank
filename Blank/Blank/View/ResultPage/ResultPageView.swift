//
//  ResultPageView.swift
//  MacroView
//
//  Created by Greed on 10/14/23.
//

import SwiftUI

struct ResultPageView: View {
    @State var seeCorrect: Bool = true
    @State var visionStart: Bool = false
    
    @StateObject var scoringViewModel: ScoringViewModel
    @State var zoomScale: CGFloat = 1.0
    
    @State private var showTutorial = false
    @AppStorage(TutorialCategory.resultView.keyName)
    private var encounteredThisView = false
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                VStack{
                    resultImage
//                    Spacer().frame(height : UIScreen.main.bounds.height * 0.12)
                }
                correctInfo
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    homeButton
                }
                ToolbarItem(placement: .topBarTrailing) {
                    HStack {
                        seeCorrectButton
                        backToOverViewButton
                    }
                }
            }
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color.customToolbarBackgroundColor, for: .navigationBar)
            .navigationTitle("결과")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
        }
        .background(Color.customViewBackgroundColor)
        // 풀스크린 오버레이 튜토리얼
        .fullScreenCover(isPresented: $showTutorial) {
            encounteredThisView = true
        } content: {
            FullScreenTutorialView(tutorialCategory: .resultView)
        }
        .onAppear {
            scoringViewModel.score()
            scoringViewModel.saveSessionToDatabase()
            
            if !encounteredThisView {
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(exhibitionHideTime)) {
                    withoutAnimation {
                        showTutorial = true
                    }
                }
            }
        }
    }
    
    private var correctInfo: some View {
        HStack {
            if seeCorrect == true {
                // TODO: 정답률, 문제개수, 정답개수 받아오기
                Spacer().frame(width: 50)
                CorrectInfoView(scoringViewModel: scoringViewModel)
                    .frame(minWidth: 600, maxWidth: 800, minHeight: 50, maxHeight: 70)
                    .cornerRadius(20)
                Spacer().frame(width: 50)
            } else {
                
            }
        }
    }
    
    private var resultImage: some View {
        // TODO: 각 단어의 정답여부에 따른 색상 마스킹
        ZoomableContainer(zoomScale: $zoomScale) {
            ImageView(
                uiImage: scoringViewModel.currentImage,
                visionStart: $visionStart,
                viewName: "ResultPageView",
                isSelectArea: .constant(false),
                isBlankArea: .constant(false),
                basicWords: .constant([]),
                targetWords: $scoringViewModel.targetWords,
                currentWritingWords: $scoringViewModel.currentWritingWords, selectedOption: .constant("")
                
            )
        }
    }
    
    private var homeButton: some View {
        Button {
            NavigationUtil.popToRootView(animated: true)
        } label: {
            Image(systemName: "house")
        }
        .buttonStyle(.bordered)
        
    }
    
    private var seeCorrectButton: some View {
        Button {
            seeCorrect.toggle()
        } label: {
            if seeCorrect == true {
                Text("정답률끄기")
            } else {
                Text("정답률보기")
            }
        }
        .buttonStyle(.bordered)
    }
    
    private var backToOverViewButton: some View {
        Button {
            NavigationUtil.popToOverView(animated: true)
        } label: {
            Text("페이지 선택으로 이동")
                .fontWeight(.bold)
        }
        .buttonStyle(.borderedProminent)
    }
}

//#Preview {
//    ResultPageView(viewModel: OverViewModel(), isLinkActive: .constant(true))
//}
