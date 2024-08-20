//
//  UploadTaskView.swift
//  OneZero
//
//  Created by Fish on 20/8/2024.
//

import SwiftUI

/// View for a group of tasks.
struct TaskGroupView: View {
    @ObservedObject var taskGroup: UploadTaskGroup
    @State var showPreview = false
    var body: some View {
        HStack(alignment: .top) {
            ZStack(alignment: .top) {
                ProgressView(value: taskGroup.finishedNum, total: taskGroup.totalNum)
                    .opacity(0.5)
                    .scaleEffect(x: 1, y: 3)
                    .tint(taskGroup.failedNum != 0 ? .red : .accentColor)
                Text(taskGroup.name)
                    .frame(alignment: .leading)
            }
            .padding(.trailing, 1)
            
            Image(systemName: taskGroup.isPaused ? "play.circle" : "pause.circle")
                .resizable()
                .frame(width: 12, height: 12)
                .onTapGesture {
                    taskGroup.isPaused.toggle()
                }
                .padding(.top, 3)
            Image(systemName: "xmark.circle")
                .resizable()
                .frame(width: 12, height: 12)
                .onTapGesture {
                    taskGroup.isHalted.toggle()
                }
                .padding(.top, 3)
            Image(systemName: "eye")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 15, height: 12)
                .onTapGesture {
                    showPreview.toggle()
                }
                .padding(.top, 3)
                .popover(isPresented: $showPreview, arrowEdge: .trailing) {
                    TaskGroupPreview(taskGroup)
                        .padding()
                        .frame(width: 200)
                }
                .help("Show details.")
        }
    }
}

/// View for all group tasks.
struct UploadTaskView: View {
    @EnvironmentObject var uploadManager: UploadManager
    var body: some View {
        ScrollView {
            if uploadManager.taskGroups.count == 0 {
                Text("No uploading task.")
                    .font(.title2)
            } else {
                ForEach(uploadManager.taskGroups) { group in
                    TaskGroupView(taskGroup: group)
                }
            }
            Spacer()
        }
    }
}

struct UploadTaskView_Previews: PreviewProvider {
    static var previews: some View {
        UploadTaskView()
    }
}
