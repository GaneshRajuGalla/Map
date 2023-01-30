//
//  ContentView.swift
//  Map
//
//  Created by Ganesh Raju Galla on 30/01/23.
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    
    //MARK: - Varibles
    @State private var timerlength:Float = 25 * 60
    @State private var currentTime:Float = 25 * 60
    @State private var breaklength:Float = 5 * 60
    @State private var isRunning:Bool = false
    @State private var isTimer:Bool = true
    @State private var prviousIsRunning:Bool = false
    @State private var isBreak:Bool = true
    @State private var soundId:Int = 1013
    @State private var isHapticEnabled:Bool = true
    @State private var isSoundEnabled:Bool = true
    
    //MARK: - Custom Functions
    func playSound(){
        if isSoundEnabled{
            AudioServicesPlaySystemSound(SystemSoundID(soundId))
        }
    }
    
    func runHapticFeedback(withStyle style:HapticStyle){
        if isHapticEnabled{
            let generator: UIImpactFeedbackGenerator
            switch style{
            case .light:
                generator = UIImpactFeedbackGenerator(style: .light)
            case .medium:
                generator = UIImpactFeedbackGenerator(style: .medium)
            }
            generator.impactOccurred()
        }
    }
    
    func runHapticSuccessFeedback(){
        if isHapticEnabled{
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        }
    }
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    let gradient = AngularGradient(gradient: Gradient(colors: [.red,.orange,.yellow,.green,.blue,.purple]), center:.center)
    

    //MARK: - Body
    var body: some View {
        ZStack{
            Color(red: 32 / 255, green: 1 / 255, blue: 34 / 255)
                .edgesIgnoringSafeArea(.all)
            VStack{
                
                HStack{
                    Text("Map")
                        .font(.largeTitle)
                }
                
                Spacer()
                
                ZStack{
                    VStack{
                        Text(currentTime != timerlength ? "\(Int((currentTime/60).rounded(.up)))" : "\(Int((timerlength/60).rounded()))")
                            .font(.system(size: 104))
                    }
                     
                    Circle()
                        .rotation(.degrees(-90))
                        .stroke(Color.white.opacity(0.3),style: StrokeStyle(lineWidth: 12,dash: [CGFloat.pi / 2, CGFloat.pi * 3.5]))
                        .frame(width: 240,height: 240)
                    
                    Circle()
                        .trim(from: 0,to: CGFloat(((currentTime).truncatingRemainder(dividingBy: 60) - 0.25) / 60))
                        .rotation(.degrees(-90))
                        .stroke(style: StrokeStyle(lineWidth: 12,dash: [CGFloat.pi / 2 , CGFloat.pi * 3.5]))
                        .frame(width: 240,height: 240)
                }
                Spacer()
                HStack{
                    Text("Work: \(Int(timerlength/60)) min")
                        .frame(minWidth: 120,alignment: .leading)
                    
                    Slider(value: $timerlength,in: 60...60 * 60,step: 60,onEditingChanged: { _ in
                        currentTime = timerlength
                        runHapticSuccessFeedback()
                        
                    }
                    ).tint(Color(red: 111 / 255, green: 0 / 255, blue: 0 / 255)).disabled(isRunning)
                    }
                HStack{
                    Text("Break: \(Int(breaklength/60)) min")
                        .frame(minWidth: 120,alignment: .leading)
                    Slider(value: $breaklength,in: 60...60 * 20,step: 60,onEditingChanged: {_ in
                        runHapticSuccessFeedback()
                        
                    })
                    .tint(Color(red: 111 / 255, green: 0 / 255, blue: 0 / 255)).disabled(isRunning)
                }
                
                Toggle(isOn: $isHapticEnabled) {
                    Text("Haptics")
                }.tint(Color(red: 111 / 255, green: 0 / 255, blue: 0 / 255))
                
                Toggle(isOn: $isSoundEnabled) {
                    Text("Sounds")
                }.tint(Color(red: 111 / 255, green: 0 / 255, blue: 0 / 255))
                
                Spacer()
                
                Button(action: {
                    isRunning.toggle()
                    if self.isRunning{
                        UIApplication.shared.isIdleTimerDisabled = true
                    }else{
                        UIApplication.shared.isIdleTimerDisabled = false
                    }
                }){
                    Text(isRunning ? "Stop" : "Start")
                }.padding(.bottom,30)
            }.onReceive(timer) { _ in
                guard self.isRunning else {return}
                let _ = print("test")
                if self.currentTime > 0{
                    self.currentTime -= 1
                }else{
                    if self.isBreak{
                        playSound()
                        self.isTimer.toggle()
                        self.currentTime = self.isTimer ? self.timerlength : self.breaklength
                    }else{
                        playSound()
                        self.isBreak = true
                        self.currentTime = self.breaklength
                    }
                }
            }.onReceive([self.isRunning].publisher.first()) { (value) in
                print("New Value is \(value)")
                let _ = print("Time: \(currentTime)")
                if self.prviousIsRunning && !value{
                    self.prviousIsRunning = value
                }else{
                    runHapticFeedback(withStyle: .light)
                }
            }
            .padding(.leading, 30)
            .padding(.trailing, 30)
            .frame(maxWidth: 500,maxHeight: .infinity)
            .foregroundColor(.white)
        }
        .preferredColorScheme(.dark)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

//MARK: - Enums
enum HapticStyle{
    case light
    case medium
}
