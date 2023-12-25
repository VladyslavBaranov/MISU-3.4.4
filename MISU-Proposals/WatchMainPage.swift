//
//  WatchPage.swift
//  NotifyTest
//
//  Created by Vladyslav Baranov on 08.07.2022.
//

import SwiftUI

struct WatchMainPage: View {
    
    @ObservedObject var state = WatchMainPageState()
    
    var onWatchConnectionTapped: (() -> ())?
    
    var onIndicatorsTapped: (() -> ())?
    
    var onCharacteristicTapped: ((__HealthIndicatorType) -> ())?
    
    var shouldPresentMonitoring: (() -> ())?
	
	var columns: [GridItem] = [
		GridItem(.flexible()), GridItem(.flexible())
	]
    
    @State var watchName = ""
    
    @State var isHidden = true
    @State var isConnected = true
    
    @State var isInfoPresented = false
    
    @State var xOffset: CGFloat = 0
    
    var body: some View {
        VStack(spacing: 0) {
            Color.clear
                .frame(height: 40)
            ZStack {
                /*
                HStack {
                    Spacer()
                    Button {
                        withAnimation {
                            isHidden.toggle()
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
                            withAnimation {
                                isConnected.toggle()
                            }
                        }
                    } label: {
                        if watchName.isEmpty {
                            Image("watch_icon")
                                .font(.system(size: 24))
                                .foregroundColor(.black)
                        }
                    }
                }
                 */
                Text(locStr("wm_str_6"))
                    .font(CustomFonts.createInter(weight: .semiBold, size: 16))
                    .foregroundColor(.black)
               
            }
            .padding()
            .foregroundColor(.black)
            
            
            ScrollView {
                VStack(alignment: .leading) {
                    
                    if isConnected {
                        WatchConnectionView {
                            onWatchConnectionTapped?()
                        } shouldPresentMonitoring: {
                            shouldPresentMonitoring?()
                        }
                        .rotation3DEffect(.degrees(isHidden ? 0 : 90), axis: (x: 1, y: 0, z: 0))
                        .offset(x: 0, y: isHidden ? 0 : -40)
                    }
                    
					
                    Color.clear
                        .frame(height: 30)
                    
                    Group {
                        HStack {
                            Text(locStr("mah_str_6"))
                                .font(CustomFonts.createInter(weight: .bold, size: 22))
                                .foregroundColor(Color(Style.TextColors.commonText))
                            Spacer()
                            HStack {
                                Button {
                                    onIndicatorsTapped?()
                                } label: {
                                    Text(locStr("mah_str_7"))
                                        .font(CustomFonts.createInter(weight: .regular, size: 16))
                                        .foregroundColor(Color(Style.TextColors.mainRed))
                                }
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 16))
                                    .foregroundColor(.red)
                            }
                            

                        }.padding([.trailing, .leading], 16)
                        
                        
                        ScrollView(.horizontal, showsIndicators: false) {
							HStack(spacing: 16) {
                                IndicatorView(indicators: state.pressureIndicators, type: .pressure)
									.onTapGesture {
										onCharacteristicTapped?(.pressure)
									}
                                    .contextMenu {
                                        Button {
                                            print("Change country setting")
                                        } label: {
                                            Label("Оновити", systemImage: "arrow.clockwise")
                                        }
                                        
                                        Button {
                                            print("Enable geolocation")
                                        } label: {
                                            Label("Додати", systemImage: "plus")
                                        }
                                        Divider()
                                        Button {
                                            isInfoPresented = true
                                        } label: {
                                            Label("Більше інформації", systemImage: "info.circle")
                                        }
                                    }
                                    .sheet(isPresented: $isInfoPresented) {
                                        WatchMainIndicatorInfoPage()
                                    }
                                IndicatorView(indicators: .init(), type: .sugar)
									.onTapGesture {
										onCharacteristicTapped?(.sugar)
								}
                                IndicatorView(indicators: state.heartrateIndicators, type: .heartrate)
									.onTapGesture {
										onCharacteristicTapped?(.heartrate)
									}
                                IndicatorView(indicators: state.temperatureIndicators, type: .temperature)
									.onTapGesture {
										onCharacteristicTapped?(.temperature)
									}
							}
                            .padding([.leading, .trailing], 16)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: UIScreen.main.bounds.width * 0.4)
                
                    }
                    
                }
				
				Color.clear
					.frame(height: 30)
				
				Group {
					HStack {
						Text(locStr("wm_str_5"))
							.font(CustomFonts.createInter(weight: .bold, size: 22))
							.foregroundColor(Color(Style.TextColors.commonText))
						Spacer()
					}
					.padding([.trailing, .leading], 16)
				   
					LazyVGrid(columns: columns, spacing: 13) {
						WatchGeneralCard(
							model: .init(title: locStr("hc_str_2"), value: getLastSleepString(), unit: nil, _indicator: .sleep),
							imageName: "Sleep",
							colors: [
								Color(red: 0.32, green: 0.53, blue: 0.98),
								Color(red: 0.14, green: 0.37, blue: 0.85)
							])
						.onTapGesture {
							onCharacteristicTapped?(.sleep)
						}
						/*
						WatchGeneralCard(
							model: state.allHealthIndicatorsData[1],
							imageName: "Shoe",
							colors: [
								Color(red: 0.53, green: 0.57, blue: 0.95),
								Color(red: 0.39, green: 0.44, blue: 0.93)
							])
						.onTapGesture {
							onCharacteristicTapped?(.activity)
						}
						 */
					}.padding([.leading, .trailing], 16)
					
				}
                
            }.background(Color(red: 0.98, green: 0.99, blue: 1))
        }
        .navigationBarHidden(true)
        .ignoresSafeArea()
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("didConnectNewWatch"))) { output in
            if let watch = output.object as? AbstractWatch {
                watchName = watch.getName()
            }
        }
    }
    
    private func getLastSleepString() -> String {
        guard let last = RealmSleepIndicator.getAll().last else { return "--" }
        return last.getDurationString()
    }
}
