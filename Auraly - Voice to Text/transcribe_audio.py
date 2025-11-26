#!/usr/bin/env python3
import sys
import json
from openai import OpenAI

def transcribe_audio(audio_path, api_key):
    try:
        client = OpenAI(api_key=api_key)
        
        with open(audio_path, 'rb') as audio_file:
            response = client.audio.transcriptions.create(
                model="whisper-1",
                file=audio_file,
                response_format="json",
                prompt="Please transcribe with proper punctuation, including periods, commas, question marks, and exclamation points."
            )
        
        return {"success": True, "text": response.text}
    except Exception as e:
        return {"success": False, "error": str(e)}

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print(json.dumps({"success": False, "error": "Usage: script.py <audio_file> <api_key>"}))
        sys.exit(1)
    
    result = transcribe_audio(sys.argv[1], sys.argv[2])
    print(json.dumps(result))