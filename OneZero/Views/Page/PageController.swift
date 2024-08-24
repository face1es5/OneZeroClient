//
//  PageController.swift
//  OneZero
//
//  Created by Fish on 24/8/2024.
//

import SwiftUI
import SwiftUIPager

struct PageController: View {
    let page: Page
    @Binding var currentPage: Int
    var pageSize: Int
    var body: some View {
        HStack {
            Spacer()
            Button(action: {
                currentPage = 1
                withAnimation {
                    page.update(.moveToFirst)
                }
            }, label: {
                VStack(spacing: 4) {
                    Image(systemName: "backward.end.alt.fill")
                        .padding()
                    Text("Start")
                        .font(.subheadline)
                }
            }).disabled(currentPage <= 1)
            Button(action: {
                currentPage -= 1
                withAnimation {
                    page.update(.previous)
                }
            }, label: {
                VStack(spacing: 4) {
                    Image(systemName: "backward.end.fill")
                        .padding()
                    Text("Previous")
                        .font(.subheadline)
                }
            }).disabled(currentPage <= 1)
            Text("\(currentPage)")
                .font(.title2)
                .padding()
            Button(action: {
                currentPage += 1
                withAnimation {
                    page.update(.next)
                }
            }, label: {
                VStack(spacing: 4) {
                    Image(systemName: "forward.end.fill")
                        .padding()
                    Text("Next")
                        .font(.subheadline)
                }
            }).disabled(currentPage >= pageSize)
            Button(action: {
                currentPage = pageSize
                withAnimation {
                    page.update(.moveToLast)
                }
            }, label: {
                VStack(spacing: 4) {
                    Image(systemName: "forward.end.alt.fill")
                        .padding()
                    Text("End")
                        .font(.subheadline)
                }
            }).disabled(currentPage >= pageSize)
            Spacer()
        }
    }
}

