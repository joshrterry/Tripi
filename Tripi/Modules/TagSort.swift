//
//  TagSort.swift
//  Tripi
//
//  Created by Joshua Terry on 2023-01-14.
//

import SwiftUI
import CoreData

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
    @AppStorage("selectedUnits") var selectedUnits = "metric"
    
    init() {
        numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.minimumFractionDigits = 2
        numberFormatter.maximumFractionDigits = 4
    }
    
    private let tagColours = [[251.0, 248.0, 204.0], [253.0, 228.0, 207.0], [255.0, 207.0, 210.0], [241.0, 192.0, 232.0], [207.0, 186.0, 240.0], [163.0, 196.0, 243.0], [144.0, 219.0, 244.0], [142.0, 236.0, 245.0], [152.0, 245.0, 225.0], [185.0, 251.0, 192.0]]
    
    var body: some View {
        // list out tags that the user has created
        List {
            ForEach(tags, id: \.self) { tag in
                HStack(spacing: 0) {
                    Image(systemName: "circle.fill")
                        .foregroundColor(Color(red: tag.colour![0] / 255, green: tag.colour![1] / 255, blue: tag.colour![2] / 255))
                        .padding(.trailing, 10)
                    Text(tag.name!)
                    Spacer()
                    Text("\(selectedUnits == "metric" ? tag.reimbursementAmount as NSNumber : tag.reimbursementAmount*1/0.62137119223733 as NSNumber, formatter: numberFormatter)")
                    Text("/\(selectedUnits == "metric" ? "km" : "mi")")
                        .foregroundColor(.secondary)
                }
                .swipeActions(allowsFullSwipe: false) {
                    // swipe to delete
                    Button(role: .destructive) {
                        PersistenceController.shared.deleteTag(tag: tag)
                    } label: {
                        Text("Delete")
                    }
                    // swipe to edit
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
                // add tag button
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
                    .onChange(of: showingAlert) { _, newValue in // monitor value of showingAlert
                        if !showingAlert {
                            if tagName.isEmpty || (tags.contains(where: { $0.name?.trimmingCharacters(in: .whitespacesAndNewlines) == tagName.trimmingCharacters(in: .whitespacesAndNewlines)}) && !isEditing) {
                                // present error message if tag added with no name
                                showError.toggle()
                            } else {
                                if isEditing {
                                    // update current tag attributes, then save changes by overwriting existing values
                                    currentTag.name = tagName.trimmingCharacters(in: .whitespacesAndNewlines)
                                    currentTag.reimbursementAmount = tagAmount
                                    PersistenceController.shared.save()
                                }
                                else {
                                    
                                    // add new tag to CoreData
                                    PersistenceController.shared.addTag(name: tagName.trimmingCharacters(in: .whitespacesAndNewlines), colour: tagColours.randomElement()!, reimbursementAmount: selectedUnits == "metric" ? tagAmount : tagAmount * 0.62137119223733)
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
    
    // function for deleting tag from swipe action
    func delete(at offsets: IndexSet) {
        for offset in offsets {
            let tag = tags[offset]
            PersistenceController.shared.deleteTag(tag: tag)
        }
    }
    
}
