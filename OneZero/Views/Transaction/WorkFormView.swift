//
//  Workshop.swift
//  OneZero
//
//  Created by Fish on 21/8/2024.
//

import SwiftUI

struct GalleriesPreview: View {
    @EnvironmentObject var selectionModel: SelectionModel<MediaItem>
    @State var selectedItems: [MediaItem] = []
    @State var showPreview: [Bool] = []

    var body: some View {
        ScrollView {
            VStack {
                ForEach(selectedItems.indices, id: \.self) { idx in
                    MediaThumbView(media: selectedItems[idx])
                        .frame(maxWidth: .infinity)
                        .frame(height: 150)
                        .popover(isPresented: $showPreview[idx]) {
                            MediaPreview(media: selectedItems[idx])
                        }
                        .onTapGesture {
                            showPreview[idx].toggle()
                        }
                }
            }
            .padding()
        }
        .onAppear {
            selectedItems = selectionModel.itemsArray
            showPreview = selectedItems.map { _ in false }
        }
        .padding(0)
    }
}

struct SubmitFormView: View {
    @EnvironmentObject var selectionModel: SelectionModel<MediaItem>
    @EnvironmentObject var appViewModel: AppViewModel
    @Binding var isPresented: Bool
    @State var title: String = ""
    @State var description: String = ""
    @State var prepare: Bool = false
    @State var failure: Bool = false
    @State var hovering: Bool = false
    @State var errorInfo: String = ""
    @State var uploadingInfo: Bool = false
    @State var category: WorkCategory = .all
    let pop: Bool
    var baseURL = UserDefaults.standard.string(forKey: "api") ?? "what://"
    var cloudURL = UserDefaults.standard.string(forKey: "cloudURL") ?? "what://"
    
    var body: some View {
        VStack {
            Form {
                TextField("Title: ", text: $title)
                    .font(.title2)
                TextField("Description: ", text: $description)
                    .font(.title2)
                    .lineLimit(5)
                Picker("Category:", selection: $category) {
                    ForEach(WorkCategory.allCases) { cate in
                        Text(cate.localizedString)
                    }
                }
            }
            HStack {
                Spacer()
                Button(prepare ? "Upload extra files" : failure ? "Re-upload" : "Upload workshop") {
                    if prepare {    // workshop json has been posted, ready to post related data.
                        print("Ready to post workshop data.")
                        if pop {
                            isPresented = false
                            appViewModel.showRightPanel = true
                        } else {
                            prepare = false
                        }
                        UploadManager.shared.uploadRequest(for: selectionModel.selectedItems, to: "api/upload", groupName: title)
                    } else {        // post workshop info
                        uploadingInfo = true
                        print("Try to post workshop info.")
                        let mediaRecords = selectionModel.selectedItems.map {
                                MediaRecord(id: UUID().uuidString, name: $0.name, description: $0.description, url: "\(cloudURL)/media/\($0.name)", type: $0 is VideoItem ? "video" : "image")
                            }
                        let work = WorkshopRecord(id: UUID().uuidString, title: title, description: description,
                                                  media: mediaRecords, category: category)
                        Task.detached {
                            let res = await APIService(to: "\(baseURL)/workshop").postJson(work)
                            switch res {
                            case .success(let message):
                                await MainActor.run {
                                    failure = false
                                    prepare = true
                                }
                                print("Received after uploding workshop: \(message)")
                            case .failure(let error):
                                await MainActor.run {
                                    failure = true
                                    errorInfo = error.localizedDescription
                                    print(errorInfo)
                                }
                            }
                            
                            await MainActor.run { uploadingInfo = false }
                        }
                    }
                }
                .disabled(title.count == 0 || !selectionModel.hasSelection || uploadingInfo)
                .buttonStyle(.borderedProminent)
                
                if pop {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
            }
            HStack {
                if failure || uploadingInfo {
                    if uploadingInfo {
                        ProgressView()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 48, height: 48)
                        Text("Uploading workshop...")
                    } else {
                        Image(systemName: "exclamationmark.icloud")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(.yellow)
                            .frame(width: 48, height: 48)
                            .onHover { _ in
                                hovering.toggle()
                            }
                            .popover(isPresented: $hovering) {
                                Text(errorInfo)
                                    .font(.title3)
                                    .padding()
                            }
                        Text("Upload workshop failed.")
                    }

                }
                else if prepare {
                    Image(systemName: "checkmark.icloud.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.accentColor)
                        .frame(width: 48, height: 48)
                    Text("Upload workshop success.")
                }
                Spacer()
            }

            Spacer()
        }
        
    }
}

struct WorkForm: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack {
            HStack(spacing: 0) {
                SubmitFormView(isPresented: $isPresented, pop: true)
                .padding()
                HStack {
                    Divider()
                    GalleriesPreview()
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .frame(width: 600, height: 400)
    }
}

struct SubmitWorkButton: View {
    @EnvironmentObject var selectionModel: SelectionModel<MediaItem>
    @State private var showSheet: Bool = false
    var body: some View {
        Button(action: {
            showSheet = true
        }) {
            Image(systemName: "square.and.arrow.up")
        }
        .sheet(isPresented: $showSheet) {
            WorkForm(isPresented: $showSheet)
        }
        .help("Upload selected items")
        .disabled(selectionModel.hasSelection == false)
        .keyboardShortcut("u", modifiers: .command)
    }
}

struct Workshop_Previews: PreviewProvider {
    static var previews: some View {
        SubmitWorkButton()
    }
}
