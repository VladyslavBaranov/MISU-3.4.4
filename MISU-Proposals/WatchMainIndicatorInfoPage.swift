//
//  WatchMainIndicatorInfoPage.swift
//  CoronaVirTracker
//
//  Created by Vladyslav Baranov on 14.12.2022.
//  Copyright © 2022 CVTCompany. All rights reserved.
//

import SwiftUI

struct WatchMainIndicatorInfoPage: View {
    var body: some View {
        VStack(spacing: 0) {
            Color.clear
                .frame(height: 10)
            ZStack {
                HStack {
                    Image("blood-pressure")
                        .resizable()
                        .frame(width: 35, height: 35)
                    Spacer()
                    Button {
                    } label: {
                        Text("Скасувати")
                            .font(CustomFonts.createInter(weight: .regular, size: 15))
                            .foregroundColor(Color(Style.TextColors.mainRed))
                    }
                }
                Text("Кровʼяний тиск")
                    .font(CustomFonts.createInter(weight: .semiBold, size: 16))
                    .foregroundColor(.black)
                
            }
            .padding()
            .foregroundColor(.black)
            
            
            
            Form {
                Section {
                    HStack {
                        Text("Кількість вимірювань")
                        Spacer()
                        Text("10")
                    }
                    .font(CustomFonts.createInter(weight: .regular, size: 16))
                    HStack {
                        Text("Останнє вимірювання")
                        Spacer()
                        Text("10/12/2022")
                    }
                    .font(CustomFonts.createInter(weight: .regular, size: 16))
                } header: {
                    Text("Статистика")
                }
                
                Section {
                    Button {
                        
                    } label: {
                        HStack {
                            Text("Всі вимірювання")
                            Spacer()
                            Image(systemName: "list.dash")
                        }
                        .font(CustomFonts.createInter(weight: .regular, size: 16))
                    }
            
                } header: {
                    Text("Дії")
                }

                Section {
                    Button {
                        
                    } label: {
                        HStack {
                            Text("Зупинити вимірювання")
                                .font(CustomFonts.createInter(weight: .regular, size: 16))
                                .foregroundColor(Color(Style.TextColors.mainRed))
                            Spacer()
                        }
                    }
            
                } header: {
                    Text("Редагувати стан")
                }
            }
            
            
            
            Spacer()

        }
        .background(Color(UIColor.systemGray6))
        .ignoresSafeArea()
    }
}
