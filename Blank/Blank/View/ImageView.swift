//
//  ImageView.swift
//  Blank
//
//  Created by 조용현 on 10/19/23.
//

import SwiftUI
import Vision

struct ImageView: View {
    //경섭추가코드
    var uiImage: UIImage?
    @Binding var visionStart:Bool
    @State private var recognizedBoxes: [(String, CGRect)] = []
    
    //경섭추가코드
    @Binding var zoomScale: CGFloat
    var viewName: String?
    
    // 다른 뷰에서도 사용할 수 있기 때문에 뷰모델로 전달하지 않고 개별 배열로 전달해봄
    @Binding var basicWords: [BasicWord]
    @Binding var targetWords: [Word]
    
    let cornerRadiusSize: CGFloat = 6
    let fontSizeRatio: CGFloat = 1.9
    
    var body: some View {
        GeometryReader { proxy in
            // ScrollView를 통해 PinchZoom시 좌우상하 이동
            ZoomableContainer {
                Image(uiImage: uiImage ?? UIImage())  //경섭추가코드를 받기위한 변경
                    .resizable()
                    .scaledToFit()
                
                // GeometryReader를 통해 화면크기에 맞게 이미지 사이즈 조정
                
                //                이미지가 없다면 , 현재 뷰의 너비(GeometryReader의 너비)를 사용하고
                //                더 작은 값을 반환할건데
                //                이미지 > GeometryReader 일 때 이미지는 GeometryReader의 크기에 맞게 축소.
                //                반대로 GeometryReader > 이미지면  이미지의 원래 크기를 사용
                    .frame(
                        width: max(uiImage?.size.width ?? proxy.size.width, proxy.size.width) * zoomScale,
                        height: max(uiImage?.size.height ?? proxy.size.height, proxy.size.height) * zoomScale
                    )
                    .onChange(of: visionStart, perform: { newValue in
                        if let image = uiImage {
                            recognizeTextTwo(from: image) { recognizedTexts in
                                self.recognizedBoxes = recognizedTexts
                                basicWords = recognizedTexts.map { .init(id: UUID(), wordValue: $0.0, rect: $0.1, isSelectedWord: false) }
                                //                                for (text, rect) in recognizedTexts {
                                //                                    print("Text: \(text), Rect: \(rect)")
                                //                                }
                            }
                        }
                        //                        print("view name : \(self.viewName)")
                    })
                // 조조 코드 아래 일단 냅두고 위의 방식으로 수정했음
                    .overlay {
                        // TODO: Image 위에 올릴 컴포넌트(핀치줌 시 크기고정을 위해 width, height, x, y에 scale갑 곱하기)
                        
                        if viewName == "OverView" {
                            ForEach(recognizedBoxes.indices, id: \.self) { index in
                                let box = recognizedBoxes[index]
                                Rectangle()
                                    .path(in:
                                            adjustRect(box.1, in: proxy))
                                    .stroke(Color.red, lineWidth: 1)
                            }
                        } else if viewName == "WordSelectView" {
                            ForEach(basicWords.indices, id: \.self) { index in
                                if basicWords[index].isSelectedWord  {
                                    Rectangle()
                                        .path(in: adjustRect(basicWords[index].rect, in: proxy))
                                        .fill(Color.green.opacity(0.4))
                                        .onTapGesture {
                                            withAnimation {
                                                print("3 : \(basicWords[index].isSelectedWord)")
                                                basicWords[index].isSelectedWord = false
                                                print("4 : \(basicWords[index].isSelectedWord)")
                                            }
                                        }
                                } else {
                                    // 선택되지 않은 상태의 처리 (예: 투명한 영역에 탭 제스처 인식기 추가)
                                    Rectangle()
                                        .path(in: adjustRect(basicWords[index].rect, in: proxy))
                                        .fill(Color.black.opacity(0.001))
                                        .onTapGesture {
                                            withAnimation {
                                                print("1 : \(basicWords[index].isSelectedWord)")
                                                basicWords[index].isSelectedWord = true
                                                print("2 : \(basicWords[index].isSelectedWord)")
                                            }
                                        }
                                }
                            }
                        } else if viewName == "ResultPageView" {
                            // TargetWords의 wordValue에는 원래 값이 넘어온다
                            ForEach(targetWords.indices, id: \.self) { index in
                                let adjustRect = adjustRect(targetWords[index].rect, in: proxy)
                                RoundedRectangle(cornerSize: .init(width: cornerRadiusSize, height: cornerRadiusSize))
                                    .path(in: adjustRect)
                                // .fill(word.isCorrect ? Color.green.opacity(0.4) : Color.red.opacity(0.4))
                                    .fill(targetWords[index].isCorrect ? Color(red: 183 / 255, green: 255 / 255, blue: 157 / 255) : Color(red: 253 / 255, green: 169 / 255, blue: 169 / 255))
                                    .shadow(color: .black, radius: 2, x: 0, y: 2)
                                    .overlay(
                                        Text("\(targetWords[index].isCorrect ? targetWords[index].wordValue : targetWords[index].wordValue)")
                                            .font(.system(size: adjustRect.height / fontSizeRatio, weight: .semibold))
                                            .offset(
                                                x: -(proxy.size.width / 2) + adjustRect.origin.x + (adjustRect.size.width / 2),
                                                y: -(proxy.size.height / 2) + adjustRect.origin.y + (adjustRect.size.height / 2)
                                            )
                                    )
                            }
                        }
                    }
            }
        }
    }
    
    
    // ---------- Mark : 반자동   ----------------
    func adjustRect(_ rect: CGRect, in geometry: GeometryProxy) -> CGRect {
        
        let imageSize = self.uiImage?.size ?? CGSize(width: 1, height: 1)
        
        // Image 뷰 너비와 UIImage 너비 사이의 비율
        let scaleY: CGFloat = geometry.size.height / imageSize.height
        //        let scaleX: CGFloat = geometry.size.width / imageSize.width
        
        //        print("----------------")
        //        print("imageSize.width: \(imageSize.width) , imageSize.height: \(imageSize.height)" )
        //        print("geometry.size.width: \(geometry.size.width) , geometry.size.height: \(geometry.size.width)")
        //        print("scaleX: \(scaleX) , scaleY: \(scaleY) , scale: \(zoomScale)")
        //        print("rect.origin.x: \(rect.origin.x) , rect.origin.y: \(rect.origin.y)")
        //        print("rect.size.width: \(rect.size.width) , rect.size.height: \(rect.size.height)")
        //        print("----------------")
        
        
        return CGRect(
            
            
            x: ( ( (geometry.size.width - imageSize.width) / 3.5 )  + (rect.origin.x * scaleY))   *  zoomScale   ,
            
            // 좌우반전
            //                x:  (imageSize.width - rect.origin.x - rect.size.width) * scaleX * scale ,
            
            y:( imageSize.height - rect.origin.y - rect.size.height) * scaleY * zoomScale ,
            width: rect.width * scaleY * zoomScale,
            height : rect.height * scaleY * zoomScale
        )
    }
    
    // completion은 recognizeText함수자체가 이미지에서 텍스트를 인식하는 비동기 작업을 수행하니까
    // 함수가 종료되었을 때가 아닌 작업이 완료되었을때 completion클로저를 호출해야됨
    func recognizeTextTwo(from image: UIImage, completion: @escaping ([(String, CGRect)]) -> Void) {
        // 이미지 CGImage로 받음
        guard let cgImage = image.cgImage else { return }
        // VNImageRequestHandler옵션에 URL로 경로 할 수도 있고 화면회전에 대한 옵션도 가능
        let requestHandler = VNImageRequestHandler(cgImage: cgImage)
        
        // 텍스트 인식 작업이 완료되었을때 실행할 클로저 정의
        let request = VNRecognizeTextRequest { (request, error) in
            var recognizedTexts: [(String, CGRect)] = [] // 단어랑 좌표값담을 빈 배열 튜플 생성
            
            if let results = request.results as? [VNRecognizedTextObservation] {
                for observation in results {
                    if let topCandidate = observation.topCandidates(1).first {
                        let words = topCandidate.string.split(separator: " ")
                        
                        for word in words {
                            if let range = topCandidate.string.range(of: String(word)) {
                                if let box = try? topCandidate.boundingBox(for: range) {
                                    let boundingBox = VNImageRectForNormalizedRect(box.boundingBox, Int(image.size.width), Int(image.size.height))
                                    recognizedTexts.append((String(word), boundingBox))
                                }
                            }
                        }
                    }
                }
            }
            completion(recognizedTexts)
        }
        
        request.recognitionLanguages = ["ko-KR"]
        request.recognitionLevel = .accurate
        request.minimumTextHeight = 0.01
        
        do {
            try requestHandler.perform([request])
        } catch {
            print("Error performing text recognition request: \(error)")
        }
    }
    
    
}

//
//#Preview {
//    ImageView(scale: .constant(1.0))
//}
