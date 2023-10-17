//
//  OverView.swift
//  MacroView
//
//  Created by Greed on 10/14/23.
//

import SwiftUI

struct OverView: View {
    @Environment(\.dismiss) private var dismiss
    @State var isLinkActive = false
    @State private var showPopover = false
    @State private var showModal = false
    @State var titleName = "파일이름"
    @State var currentPage = "5"
    
    
    var body: some View {
        NavigationStack {
            VStack {
                pdfView
                bottomScrollView
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    leftBtns
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    testBtn
                }
                
                ToolbarItem(placement: .principal) {
                    centerBtn
                }
            }
            .toolbarBackground(.white, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .navigationBarBackButtonHidden()
            .navigationTitle(titleName)
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationDestination(isPresented: $isLinkActive) {
            WordSelectView(isLinkActive: $isLinkActive)
        }
        
    }
    
    private var pdfView: some View {
        // TODO: PDFView
        ScrollView(showsIndicators: false) {
            Image("myImage")
                .resizable()
                .scaledToFit()
        }
    }
    
    private var bottomScrollView: some View {
        ScrollView(.horizontal, showsIndicators: true) {
            HStack(spacing: 10) {
                ForEach(0..<20) { index in
                    VStack {
                        Image("myImage")
                            .resizable()
                            .aspectRatio(contentMode:.fit)
                        Spacer().frame(height: 0)
                        Text("\(index+1)")
                    }
                }
            }
            .padding(.horizontal)
        }
        .frame(height : UIScreen.main.bounds.height * 0.1)
    }
    
    private var centerBtn: some View {
        Button {
            showPopover = true
        } label: {
            HStack {
                Text("\(titleName)")
                Image(systemName: "chevron.down")
            }
            .foregroundColor(.black)
            .fontWeight(.bold)
        }
        .popover(isPresented: $showPopover) {
            popoverContent
        }
    }
    
    private var popoverContent: some View {
        VStack {
            Form {
                // TODO: 파일 이름 연동
                TextField("\(titleName)", text: $titleName)
                HStack {
                    Text("페이지 : ")
                    TextField("\(currentPage)", text: $currentPage)
                    // TODO: 전체 페이지 수 가져오기
                    Text(" / 200")
                }
            }
        }
        .frame(width: 300, height: 150)
    }
    
    private var leftBtns: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
            }
            
            Button {
                showModal = true
            } label: {
                Image(systemName: "square.grid.2x2.fill")
            }
            .sheet(isPresented: $showModal) {
                OverViewModalView()
            }
            
            Menu {
                // TODO: 회차가 끝날때마다 해당 회차 결과 생성 및 시험 본 부분 색상 처리(버튼으로)
                Text("전체통계")
                Text("1회차")
                Text("2회차")
                Text("3회차")
                Text("4회차")
                
            } label: {
                Label("결과보기", systemImage: "chevron.down")
                    .labelStyle(.titleAndIcon)
            }
            
            Button {
                // TODO: 원본 페이지 상태로 변경
            } label: {
                Text("원본")
            }
        }
    }
    
    private var testBtn: some View {
        Button {
            // TODO: 해당 페이지 이미지 파일로 넘겨주기, layer 분리, 이미지 받아서 텍스트로 변환, 2회차 이상일때 내용수정 Alert 만들기
            isLinkActive = true
        } label: {
            Text("시험준비")
                .fontWeight(.bold)
        }
    }
    
}

#Preview {
    OverView()
}
