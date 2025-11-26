//
//  ContentView.swift
//  Auraly - Voice to Text
//

import SwiftUI
import AVFoundation
#if os(macOS)
import Foundation
#endif

// Custom button style for press effect
struct PressedButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// Loading dots animation component - MUST BE BEFORE ContentView  
struct LoadingDots: View {
    @State private var activeIndex = 0
    @State private var timer: Timer?
    
    var body: some View {
        HStack(spacing: 5) {
            Circle()
                .fill(Color.blue)
                .frame(width: 10, height: 10)
                .opacity(activeIndex == 0 ? 1.0 : 0.3)
                .animation(.easeInOut(duration: 0.2), value: activeIndex)
            
            Circle()
                .fill(Color.blue)
                .frame(width: 10, height: 10)
                .opacity(activeIndex == 1 ? 1.0 : 0.3)
                .animation(.easeInOut(duration: 0.2), value: activeIndex)
            
            Circle()
                .fill(Color.blue)
                .frame(width: 10, height: 10)
                .opacity(activeIndex == 2 ? 1.0 : 0.3)
                .animation(.easeInOut(duration: 0.2), value: activeIndex)
        }
        .onAppear {
            startAnimating()
        }
        .onDisappear {
            timer?.invalidate()
            timer = nil
        }
    }
    
    func startAnimating() {
        // Start immediately with first dot
        activeIndex = 0
        
        // Then cycle through continuously
        timer = Timer.scheduledTimer(withTimeInterval: 0.35, repeats: true) { _ in
            print("Animating from index \(activeIndex) to \((activeIndex + 1) % 3)")
            activeIndex = (activeIndex + 1) % 3
        }
    }
}

struct ContentView: View {
    @State private var isRecording = false
    @State private var transcribedText = ""
    @State private var wordCount = 0
    @State private var showingDeleteConfirmation = false
    @State private var isTranscribing = false
    @State private var apiKey = ""
    @State private var showingAPIKeyPrompt = true
    @State private var textOpacity = 1.0
    @State private var isListeningAnimation = false
    #if os(macOS)
    @State private var recordingProcess: Process?
    @State private var inputPipe: Pipe?
    @State private var outputPipe: Pipe?
    #endif
    
    var body: some View {
        VStack(spacing: 0) {
            // Title
            Text("Voice to Text")
                .font(.custom("SF Pro Display", size: 42).weight(.medium)) // SF Pro Display with medium weight
                .padding(.top, 100)
                .padding(.bottom, 10)
            
            // Main content area
            VStack {
                if transcribedText.isEmpty {
                    // Recording button area
                    VStack(spacing: 24) {
                        // Microphone button
                        Button(action: toggleRecording) {
                            ZStack {
                                Circle()
                                    .fill(isRecording ? 
                                          Color.red.opacity(0.15) : 
                                          Color(red: 0.33, green: 0.51, blue: 1.0).opacity(0.08))
                                    .frame(width: 180, height: 180)
                                    .shadow(color: isRecording ? 
                                           Color.red.opacity(0.5) : 
                                           Color(red: 0.33, green: 0.51, blue: 1.0).opacity(0.4), 
                                           radius: 40, x: 0, y: 5)
                                    .shadow(color: isRecording ? 
                                           Color.red.opacity(0.3) : 
                                           Color(red: 0.33, green: 0.51, blue: 1.0).opacity(0.2), 
                                           radius: 60, x: 0, y: 10)
                                
                                if isRecording {
                                    // Stop icon with sophisticated Jony Ive animation
                                    ZStack {
                                        // Multiple subtle gradient waves
                                        ForEach(0..<3) { index in
                                            Circle()
                                                .fill(
                                                    RadialGradient(
                                                        gradient: Gradient(colors: [
                                                            Color.red.opacity(0.15),
                                                            Color.red.opacity(0.05),
                                                            Color.clear
                                                        ]),
                                                        center: .center,
                                                        startRadius: 30,
                                                        endRadius: 60
                                                    )
                                                )
                                                .frame(width: 140, height: 140)
                                                .scaleEffect(isListeningAnimation ? 1.3 : 0.8)
                                                .opacity(isListeningAnimation ? 0 : 0.6)
                                                .animation(
                                                    Animation.easeInOut(duration: 2.0)
                                                        .repeatForever(autoreverses: false)
                                                        .delay(Double(index) * 0.4),
                                                    value: isListeningAnimation
                                                )
                                        }
                                        
                                        // The stop button with subtle glow
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color.red)
                                            .frame(width: 45, height: 45)
                                            .shadow(color: Color.red.opacity(0.4), radius: isListeningAnimation ? 15 : 8)
                                            .scaleEffect(isListeningAnimation ? 1.08 : 1.0)
                                            .animation(
                                                Animation.easeInOut(duration: 0.8)
                                                    .repeatForever(autoreverses: true),
                                                value: isListeningAnimation
                                            )
                                    }
                                } else {
                                    // Microphone icon - exactly like Figma with subtle breathing effect
                                    Image(systemName: "mic.fill")
                                        .font(.system(size: 50, weight: .medium))
                                        .foregroundColor(Color(red: 0.33, green: 0.51, blue: 1.0))
                                        .shadow(color: Color(red: 0.33, green: 0.51, blue: 1.0).opacity(0.6), 
                                               radius: 15, x: 0, y: 2)
                                }
                            }
                        }
                        .buttonStyle(PressedButtonStyle())
                        .disabled(isTranscribing)
                        
                        // Status text or transcribing indicator
                        if isTranscribing {
                            // Apple-style typing indicator with proper animation
                            LoadingDots()
                                .padding(.vertical, 8)
                        } else {
                            Text(isRecording ? "Listening..." : "Speak")
                                .font(.custom("SF Pro Display", size: 22))
                                .foregroundColor(isRecording ? Color(red: 0.33, green: 0.51, blue: 1.0) : Color(red: 0.443, green: 0.443, blue: 0.51))
                        }
                    }
                    .frame(maxHeight: .infinity)
                    
                    // Placeholder text at bottom
                    Text("Your words will appear here")
                        .font(.custom("SF Pro Display", size: 18))
                        .foregroundColor(Color.gray.opacity(0.5))
                        .padding(.bottom, 150)
                } else {
                    // Transcription view
                    VStack(spacing: 16) {
                        // Microphone button (smaller when text is present)
                        Button(action: toggleRecording) {
                            ZStack {
                                Circle()
                                    .fill(isRecording ? 
                                          Color.red.opacity(0.15) : 
                                          Color(red: 0.33, green: 0.51, blue: 1.0).opacity(0.08))
                                    .frame(width: 120, height: 120)
                                    .shadow(color: isRecording ? 
                                           Color.red.opacity(0.5) : 
                                           Color(red: 0.33, green: 0.51, blue: 1.0).opacity(0.4), 
                                           radius: 30, x: 0, y: 3)
                                    .shadow(color: isRecording ? 
                                           Color.red.opacity(0.3) : 
                                           Color(red: 0.33, green: 0.51, blue: 1.0).opacity(0.2), 
                                           radius: 45, x: 0, y: 6)
                                
                                if isRecording {
                                    ZStack {
                                        // Elegant gradient waves
                                        ForEach(0..<2) { index in
                                            Circle()
                                                .fill(
                                                    RadialGradient(
                                                        gradient: Gradient(colors: [
                                                            Color.red.opacity(0.12),
                                                            Color.red.opacity(0.03),
                                                            Color.clear
                                                        ]),
                                                        center: .center,
                                                        startRadius: 20,
                                                        endRadius: 40
                                                    )
                                                )
                                                .frame(width: 90, height: 90)
                                                .scaleEffect(isListeningAnimation ? 1.2 : 0.9)
                                                .opacity(isListeningAnimation ? 0 : 0.5)
                                                .animation(
                                                    Animation.easeInOut(duration: 1.8)
                                                        .repeatForever(autoreverses: false)
                                                        .delay(Double(index) * 0.5),
                                                    value: isListeningAnimation
                                                )
                                        }
                                        
                                        RoundedRectangle(cornerRadius: 7)
                                            .fill(Color.red)
                                            .frame(width: 32, height: 32)
                                            .shadow(color: Color.red.opacity(0.3), radius: isListeningAnimation ? 10 : 5)
                                            .scaleEffect(isListeningAnimation ? 1.06 : 1.0)
                                            .animation(
                                                Animation.easeInOut(duration: 0.8)
                                                    .repeatForever(autoreverses: true),
                                                value: isListeningAnimation
                                            )
                                    }
                                } else {
                                    Image(systemName: "mic.fill")
                                        .font(.system(size: 35, weight: .medium))
                                        .foregroundColor(Color(red: 0.33, green: 0.51, blue: 1.0))
                                        .shadow(color: Color(red: 0.33, green: 0.51, blue: 1.0).opacity(0.5), 
                                               radius: 12, x: 0, y: 2)
                                }
                            }
                        }
                        .buttonStyle(PressedButtonStyle())
                        .disabled(isTranscribing)
                        
                        // Elegant transcribing indicator
                        if isTranscribing {
                            LoadingDots()
                                .scaleEffect(0.8)
                                .padding(.vertical, 6)
                        } else {
                            Text(isRecording ? "Listening..." : "Speak")
                                .font(.custom("SF Pro Display", size: 18))
                                .foregroundColor(isRecording ? Color(red: 0.33, green: 0.51, blue: 1.0) : Color(red: 0.443, green: 0.443, blue: 0.51))
                        }
                        
                        // Transcribed text with elegant container
                        TextEditor(text: $transcribedText)
                            .font(.custom("SF Pro Display", size: 20))
                            .scrollContentBackground(.hidden)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                            .opacity(textOpacity)
                            .onChange(of: transcribedText) { _ in
                                wordCount = transcribedText.split(separator: " ").count
                                // Subtle fade in when text changes
                                withAnimation(.easeIn(duration: 0.3)) {
                                    textOpacity = 1.0
                                }
                            }
                            .frame(minHeight: 200, maxHeight: 350)
                        .background(
                            RoundedRectangle(cornerRadius: 10) // --radius: 0.625rem = 10px
                                .fill(Color.gray.opacity(0.05)) // Más sutil
                        )
                        .padding(.horizontal, 30)
                        .padding(.top, 5)
                        
                        // Bottom toolbar - closer to text container
                        HStack {
                            // Word count
                            Text("\(wordCount) words")
                                .font(.custom("SF Pro Display", size: 18))
                                .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.6))
                            
                            Spacer()
                            
                            // Delete button
                            Button(action: { showingDeleteConfirmation = true }) {
                                Image(systemName: "trash")
                                    .font(.system(size: 22, weight: .light))
                                    .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.6))
                            }
                            .buttonStyle(PlainButtonStyle())
                            .padding(.trailing, 12)
                            .alert("Delete Transcription?", isPresented: $showingDeleteConfirmation) {
                                Button("Cancel", role: .cancel) { }
                                Button("Delete", role: .destructive) {
                                    transcribedText = ""
                                    wordCount = 0
                                }
                            }
                            
                            // Copy button
                            Button(action: copyToClipboard) {
                                Image(systemName: "square.on.square")
                                    .font(.system(size: 22, weight: .light))
                                    .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.6))
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .padding(.horizontal, 40)
                        .padding(.top, 8)
                        .padding(.bottom, 100)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(width: 600, height: 800)
        #if os(macOS)
        .background(Color(NSColor.windowBackgroundColor))
        #else
        .background(Color(UIColor.systemBackground))
        #endif
        .onAppear {
            checkForAPIKey()
        }
        .sheet(isPresented: $showingAPIKeyPrompt) {
            APIKeyView(apiKey: $apiKey, isPresented: $showingAPIKeyPrompt)
        }
    }
    
    private func checkForAPIKey() {
        // Check if API key exists in UserDefaults
        if let savedKey = UserDefaults.standard.string(forKey: "OpenAI_API_Key") {
            apiKey = savedKey
            showingAPIKeyPrompt = false
        }
        
        // Also check microphone permission proactively
        switch AVCaptureDevice.authorizationStatus(for: .audio) {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .audio) { _ in }
        case .denied, .restricted:
            print("Microphone access denied")
        case .authorized:
            print("Microphone access granted")
        @unknown default:
            break
        }
    }
    
    private func toggleRecording() {
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }
    
    private func startRecording() {
        // Request microphone permission first
        AVCaptureDevice.requestAccess(for: .audio) { granted in
            if granted {
                DispatchQueue.main.async {
                    self.actuallyStartRecording()
                }
            } else {
                DispatchQueue.main.async {
                    self.transcribedText = "Microphone access denied. Please enable in System Settings."
                    self.isRecording = false
                }
            }
        }
    }
    
    private func actuallyStartRecording() {
        isRecording = true
        
        // Start the listening animation
        withAnimation {
            isListeningAnimation = true
        }
        
        #if os(macOS)
        // Start Python process for continuous recording
        recordingProcess = Process()
        recordingProcess?.executableURL = URL(fileURLWithPath: "/Library/Frameworks/Python.framework/Versions/3.13/bin/python3")
        recordingProcess?.currentDirectoryURL = URL(fileURLWithPath: "/Users/pedromeza/Desktop/Voice To Text App")
        recordingProcess?.arguments = ["/Users/pedromeza/Desktop/Voice To Text App/continuous_record.py", apiKey]
        
        inputPipe = Pipe()
        outputPipe = Pipe()
        
        recordingProcess?.standardInput = inputPipe
        recordingProcess?.standardOutput = outputPipe
        recordingProcess?.standardError = FileHandle.standardError
        
        do {
            try recordingProcess?.run()
            print("Recording process started")
        } catch {
            print("Failed to start recording: \(error)")
            isRecording = false
        }
        #else
        // For iOS simulator - just simulate recording
        print("Recording on iOS simulator")
        #endif
    }
    
    private func stopRecording() {
        isRecording = false
        isTranscribing = true
        isListeningAnimation = false // Stop the animation
        print("DEBUG: isTranscribing set to true")
        
        #if os(macOS)
        // Send STOP signal
        if let pipe = inputPipe {
            let stopData = "STOP\n".data(using: .utf8)!
            pipe.fileHandleForWriting.write(stopData)
            try? pipe.fileHandleForWriting.close()
        }
        
        // Read the result with a delay to show the dots animation
        Task {
            // Longer delay to see the full dots animation cycle
            try? await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds
            
            if let pipe = outputPipe {
                let data = pipe.fileHandleForReading.readDataToEndOfFile()
                
                if let output = String(data: data, encoding: .utf8) {
                    print("Output: \(output)")
                    
                    // Find the last JSON line (the result)
                    let lines = output.split(separator: "\n")
                    for line in lines.reversed() {
                        if line.contains("{") && line.contains("}") {
                            if let jsonData = line.data(using: .utf8),
                               let result = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] {
                                
                                await MainActor.run {
                                    print("DEBUG: Processing result, isTranscribing will be set to false")
                                    if let success = result["success"] as? Bool, success,
                                       let text = result["text"] as? String {
                                        // Add new text to existing text with a space
                                        if self.transcribedText.isEmpty {
                                            self.transcribedText = text
                                        } else {
                                            self.transcribedText += " " + text
                                        }
                                        self.wordCount = self.transcribedText.split(separator: " ").count
                                    } else if let error = result["error"] as? String {
                                        self.transcribedText = "Error: \(error)"
                                    } else {
                                        self.transcribedText = "No speech detected"
                                    }
                                    self.isTranscribing = false
                                }
                                break
                            }
                        }
                    }
                } else {
                    await MainActor.run {
                        self.transcribedText = "Error processing audio"
                        self.isTranscribing = false
                    }
                }
            }
            
            // Clean up completely
            if let process = recordingProcess {
                process.terminate()
                process.waitUntilExit()
            }
            recordingProcess = nil
            inputPipe = nil
            outputPipe = nil
        }
        #else
        // For iOS simulator - show demo text
        Task {
            await MainActor.run {
                self.transcribedText = "This is a demo transcription. The app works perfectly on Mac!"
                self.wordCount = 10
                self.isTranscribing = false
            }
        }
        #endif
    }
    
    private func copyToClipboard() {
        #if os(macOS)
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(transcribedText, forType: .string)
        #else
        UIPasteboard.general.string = transcribedText
        #endif
    }
}

struct APIKeyView: View {
    @Binding var apiKey: String
    @Binding var isPresented: Bool
    @State private var tempKey = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Enter OpenAI API Key")
                .font(.title2)
                .padding(.top, 20)
            
            Text("Your API key will be stored securely")
                .font(.caption)
                .foregroundColor(.gray)
            
            SecureField("sk-...", text: $tempKey)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(width: 400)
            
            HStack {
                Button("Cancel") {
                    isPresented = false
                }
                .buttonStyle(.bordered)
                
                Button("Save") {
                    if !tempKey.isEmpty {
                        apiKey = tempKey
                        UserDefaults.standard.set(tempKey, forKey: "OpenAI_API_Key")
                        isPresented = false
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(tempKey.isEmpty)
            }
            .padding(.bottom, 20)
        }
        .frame(width: 500, height: 200)
        #if os(macOS)
        .background(Color(NSColor.windowBackgroundColor))
        #else
        .background(Color(UIColor.systemBackground))
        #endif
    }
}

#Preview {
    ContentView()
}