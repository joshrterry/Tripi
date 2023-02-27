//
//  TagSort.swift
//  Tripi
//
//  Created by Joshua Terry on 2023-01-14.
//

import SwiftUI

struct TagSort: View {
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \UserTag.dateCreated, ascending: true)], animation: .default)
    private var tags: FetchedResults<UserTag>
    @State private var showingAlert = false
    @State private var tagName = ""
    @State private var tagAmount = 0.0
    private let numberFormatter: NumberFormatter
    @State private var isEditing = false
    @State private var currentTag = UserTag()
    @State private var doneText = "Add Tag"
    @State private var showError = false
    
    init() {
      numberFormatter = NumberFormatter()
      numberFormatter.numberStyle = .currency
      numberFormatter.maximumFractionDigits = 2
    }
    
    var body: some View {
        List() {
            ForEach(tags, id: \.self) { tag in
                HStack {
                    Image(systemName: "circle.fill")
                        .foregroundColor(Color(red: tag.colour![0] / 255, green: tag.colour![1] / 255, blue: tag.colour![2] / 255))
                    Text(tag.name!)
                    Spacer()
                    Text("$\(String(format: "%.2f", tag.reimbursementAmount))")
                }
                .swipeActions(allowsFullSwipe: false) {
                    Button(role: .destructive) {
                        PersistenceController.shared.deleteTag(tag: tag)
                    } label: {
                        Text("Delete")
                    }

                    Button() {
                        tagName = tag.name ?? ""
                        tagAmount = tag.reimbursementAmount
                        currentTag = tag
                        doneText = "Save Edits"
                        isEditing.toggle()
                        showingAlert.toggle()
                    } label: {
                        Text("Edit")
                    }

                }
            }
            
            Section {
                Button {
                    doneText = "Add Tag"
                    showingAlert.toggle()
                } label: {
                    HStack {
                        Image(systemName: "plus")
                        Text("Add Tag")
                    }
                    .alert("Enter tag name and reimbursement amount:", isPresented: $showingAlert) {
                        VStack {
                            TextField("Name", text: $tagName)
                            TextField("$0.00", value: $tagAmount, formatter: numberFormatter)
                                .keyboardType(.decimalPad)
                            Button {
                                
                            } label: {
                                Text(doneText)
                            }

                        }
                        
                    }
                    .alert(isPresented: $showError) {
                        Alert(title: Text("Unable to save tag"), message: Text("Please make sure the name field is not empty and has a unique name"))
                    }
                    .onChange(of: showingAlert) { newValue in // monitor value of showingAlert
                        if !showingAlert {
                            if tagName.isEmpty || tags.contains(where: { $0.name == tagName}) {
                                // present error message if tag added with no name
                                showError.toggle()
                            } else {
                                if isEditing {
                                    // update current tag attributes, then save changes by overwriting existing values
                                    currentTag.name = tagName
                                    currentTag.reimbursementAmount = tagAmount
                                    PersistenceController.shared.save()
                                }
                                else {
                                    // add new tag to CoreData
                                    PersistenceController.shared.addTag(name: tagName, colour: [Double.random(in: 0...255), Double.random(in: 0...255), Double.random(in: 0...255)], reimbursementAmount: tagAmount)
                                }
                            }
                            // clear fields in alert dialogue
                            tagName = ""
                            tagAmount = 0.0
                            isEditing = false
                        }
                    }
                }
            }

        }
    }
    
    func delete(at offsets: IndexSet) {
        for offset in offsets {
            let tag = tags[offset]
            PersistenceController.shared.deleteTag(tag: tag)
        }
    }
    
}

struct TagSort_Previews: PreviewProvider {
    static var previews: some View {
        TagSort()
    }
}
