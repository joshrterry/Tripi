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
            }.onDelete(perform: delete)
            
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
                        }
                        
                    }.onChange(of: showingAlert) { newValue in
                        if showingAlert == false {
                            PersistenceController.shared.addTag(name: tagName, colour: [Double.random(in: 0...255), Double.random(in: 0...255), Double.random(in: 0...255)], reimbursementAmount: tagAmount)
                            tagName = ""
                            tagAmount = 0.0

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
