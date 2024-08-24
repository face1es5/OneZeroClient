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
    let pageIndex: Int
    let pageSize: Int
    var body: some View {
        HStack {
            Spacer()
            Button(action: {
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
            }).disabled(pageIndex <= 0)
            Button(action: {
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
            }).disabled(pageIndex <= 0)
            Text("\(pageIndex+1)")
                .font(.title2)
                .padding()
            Button(action: {
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
            }).disabled(pageIndex + 1 >= pageSize)
            Button(action: {
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
            }).disabled(pageIndex + 1 >= pageSize)
            Spacer()
        }
    }
}

