//
//  TaskGroupPreview.swift
//  OneZero
//
//  Created by Fish on 20/8/2024.
//

import SwiftUI

/// View for mininum task.
struct TaskUnitView: View {
    @ObservedObject var taskItem: MediaItem
    @State var showPopover: Bool = false
    var body: some View {
        HStack {
            Image(systemName: taskItem.uploading ? "icloud" : (taskItem.failedToUploading ? "exclamationmark.icloud.fill" : "checkmark.icloud.fill"))
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24)
                .foregroundColor(taskItem.failedToUploading ? .yellow : .accentColor)
                .popover(isPresented: $showPopover, arrowEdge: .leading) {
                    if taskItem.uploading || !taskItem.failedToUploading {
                        VStack(alignment: .leading) {
                            HStack {
                                Image(systemName: "icloud")
                                Text("Uploading.")
                            }
                            HStack {
                                Image(systemName: "checkmark.icloud.fill")
                                Text("Upload success.")
                            }
                            HStack {
                                Image(systemName: "exclamationmark.icloud.fill")
                                Text("Upload failed.")
                            }
                        }
                        .padding()
                    }
                    else {
                        Text("\(NSLocalizedString("Uploading failed", comment: "")) : \(taskItem.errorHint!)")
                            .font(.title3)
                            .padding()
                            .lineLimit(10)
                    }

                }
                .onHover { _ in
                    showPopover.toggle()
                }
                
            Text(taskItem.name)
            
            if taskItem.failedToUploading && !taskItem.uploading {  // not uploading and upload failed.
                Button("Re-upload") {
                    Task.detached(priority: .background) {
                        await Uploader.shared.upload(for: taskItem, to: "api/upload")
                    }
                }
            }
        }
    }
}

struct TaskGroupPreview: View {
    @ObservedObject var taskGroup: UploadTaskGroup
    @State var showHint: Bool = false
    
    init (_ group: UploadTaskGroup) {
        taskGroup = group
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Form {
                    Field(key: "Total upload num", value: "\(Int(taskGroup.totalNum))")
                    Field(key: "Finished num", value: "\(Int(taskGroup.finishedNum))")
                    Field(key: "Failed num", value: "\(taskGroup.failedNum)")
                }
                .font(.title3)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(0)
                
                ForEach(taskGroup.mediaItems) { media in
                    TaskUnitView(taskItem: media)
                }
            }
        }
    }
}

struct TaskGroupPreview_Previews: PreviewProvider {
    static var previews: some View {
        EmptyView()
    }
}
