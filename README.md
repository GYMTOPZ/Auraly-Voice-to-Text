# Auraly - Voice to Text

A beautiful, native macOS app for voice-to-text transcription using OpenAI's Whisper API.

![macOS](https://img.shields.io/badge/macOS-14.0+-blue)
![Swift](https://img.shields.io/badge/Swift-5.9-orange)
![License](https://img.shields.io/badge/License-MIT-green)

## Features

- **One-tap recording** - Simple, intuitive interface with a large microphone button
- **Real-time transcription** - Powered by OpenAI's Whisper API for accurate results
- **Multi-language support** - Auto-detects English, Spanish, and many other languages
- **Copy to clipboard** - One-click copy of transcribed text
- **Word count** - Track the length of your transcriptions
- **Beautiful UI** - Clean, Apple-inspired design with smooth animations

## Screenshots

*Coming soon*

## Requirements

- macOS 14.0 or later
- OpenAI API key
- Python 3.13 with `sounddevice`, `numpy`, and `openai` packages (for audio recording)

## Installation

1. Clone this repository:
   ```bash
   git clone https://github.com/GYMTOPZ/Auraly-Voice-to-Text.git
   ```

2. Open the project in Xcode:
   ```bash
   cd Auraly-Voice-to-Text
   open "Auraly - Voice to Text.xcodeproj"
   ```

3. Build and run (Cmd + R)

4. On first launch, enter your OpenAI API key when prompted

## Python Dependencies

The app uses a Python script for audio recording. Install the required packages:

```bash
pip3 install sounddevice numpy openai
```

## Usage

1. Launch the app
2. Click the microphone button to start recording
3. Speak clearly into your microphone
4. Click the stop button (red square) when finished
5. Wait for transcription to complete
6. Copy or edit the transcribed text as needed

## Privacy

- Your API key is stored locally in macOS UserDefaults
- Audio is processed through OpenAI's Whisper API
- No data is stored on external servers beyond API processing

## Tech Stack

- **SwiftUI** - Native macOS UI framework
- **AVFoundation** - Microphone access and permissions
- **OpenAI Whisper API** - Speech-to-text transcription
- **Python** - Audio recording with sounddevice

## License

MIT License - feel free to use and modify as needed.

## Author

Created by Pedro Meza ([@GYMTOPZ](https://github.com/GYMTOPZ))
