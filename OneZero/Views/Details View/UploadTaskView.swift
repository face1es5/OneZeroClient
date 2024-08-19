//
//  UploadTaskView.swift
//  OneZero
//
//  Created by Fish on 20/8/2024.
//

import SwiftUI

/// View for mininum task.
struct TaskUnitView: View {
    @ObservedObject var taskItem: VideoItem
    var body: some View {
        HStack {
            Image(systemName: taskItem.uploading ? "icloud" : "checkmark.icloud.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 12, height: 12)
            Text(taskItem.name)
        }
    }
}

/// View for a group of tasks.
struct TaskGroupView: View {
    @ObservedObject var taskGroup: UploadTaskGroup
    var body: some View {
        HStack(alignment: .top) {
            ZStack(alignment: .top) {
                ProgressView(value: taskGroup.finishedNum, total: taskGroup.totalNum)
                    .opacity(0.5)
                    .padding(.top, 2)
                    .scaleEffect(x: 1, y: 3)
                DisclosureGroup(taskGroup.name) {
                    Form {
                        ForEach(taskGroup.videos) { video in
                            TaskUnitView(taskItem: video)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                }
                .padding(.leading, 2)
            }
            .padding(.trailing, 1)

            Image(systemName: taskGroup.isPaused ? "play.circle" : "pause.circle")
                .resizable()
                .frame(width: 12, height: 12)
                .onTapGesture {
                    taskGroup.isPaused.toggle()
                }
                .padding(.top, 7)
            Image(systemName: "xmark.circle")
                .resizable()
                .frame(width: 12, height: 12)
                .onTapGesture {
                    taskGroup.isHalted.toggle()
                }
                .padding(.top, 7)
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
