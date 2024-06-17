//
//  OptionMenuItemView.swift
//  CodeEdit
//
//  Created by Tommy Ludwig on 15.06.24.
//

import SwiftUI

struct OptionMenuItemView: View {
    var label: String
    var action: () -> Void
    var body: some View {
        HStack {
            Text(label)
            Spacer()
        }
        .padding(.vertical, 5)
        .padding(.horizontal, 28)
        .modifier(DropdownMenuItemViewModifier())
        .clipShape(RoundedRectangle(cornerRadius: 5))
        .onTapGesture {
            action()
        }
    }
}

#Preview {
    OptionMenuItemView(label: "Tst") {
        print("test")
    }
}
