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
                        isEditing.toggle()
                        showingAlert.toggle()
                    } label: {
                        Text("Edit")
                    }

                }
            }
            
            Section {
                Button {
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
                                Text("Add Tag")
                            }

                        }
                        
                    }.onChange(of: showingAlert) { newValue in
                        if !showingAlert {
                            if isEditing {
                                currentTag.name = tagName
                                currentTag.reimbursementAmount = tagAmount
                                PersistenceController.shared.save()
                                isEditing.toggle()
                            } else {
                                PersistenceController.shared.addTag(name: tagName, colour: [Double.random(in: 0...255), Double.random(in: 0...255), Double.random(in: 0...255)], reimbursementAmount: tagAmount)
                                tagName = ""
                                tagAmount = 0.0
                            }

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
