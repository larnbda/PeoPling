//
//  MainTabView.swift
//  PeoPling
//
//  Created by 맥14 on 6/19/25.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            BoardView()
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("게시판")
                }

            MemoView()
                .tabItem {
                    Image(systemName: "note.text")
                    Text("메모장")
                }

            ProfileView()
                .tabItem {
                    Image(systemName: "person.circle")
                    Text("프로필")
                }
        }
    }
}
