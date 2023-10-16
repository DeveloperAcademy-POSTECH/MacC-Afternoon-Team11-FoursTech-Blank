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
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                resultImage
                bottomCorrectInfo
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    homeBtn
                }
                ToolbarItem(placement: .topBarTrailing) {
                    backToOverViewBtn
                }
            }
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(.white, for: .navigationBar)
            .navigationTitle("결과")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
        }
    }
    
    private var bottomCorrectInfo: some View {
        HStack {
            // TODO: 정답률, 문제개수, 정답개수 받아오기
            Spacer().frame(width: 50)
            CorrectInfoView()
                .frame(minWidth: 600, maxWidth: 800, minHeight: 50, maxHeight: 70)
            Spacer().frame(width: 50)
        }
    }
    
    private var resultImage: some View {
        VStack {
            // TODO: 각 단어의 정답여부에 따른 색상 마스킹
            Image("myImage")
                .resizable()
                .scaledToFit()
        }
    }
    
    private var homeBtn: some View {
        NavigationLink(destination: HomeView()) {
            Image(systemName: "house")
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

#Preview {
    ResultPageView(isLinkActive: .constant(true))
}
