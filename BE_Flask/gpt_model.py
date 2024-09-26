import os
import requests
import uuid
from flask import jsonify
from openai import OpenAI
from dotenv import load_dotenv

# load .env
load_dotenv()

API_KEY= os.getenv("API_KEY")
GPT_URL = "https://api.openai.com/v1/chat/completions"



# GPT-4o API 호출 함수
def call_gpt4o(messages):
    headers = {
        "Authorization": f"Bearer {API_KEY}",
        "Content-Type": "application/json"
    }

    payload = {
        "model": "gpt-4o",
        "messages": messages,
        "max_tokens": 2048
    }

    response = requests.post(GPT_URL, headers=headers, json=payload)

    if response.status_code == 200:
        result = response.json()
        return result['choices'][0]['message']['content']
    else:
        raise Exception(f"GPT-4o API 호출 실패: {response.status_code}, {response.text}")


# 새로운 대화 시작 엔드포인트
def start(base64_image, conversations):
    # 세션 ID 생성
    session_id = str(uuid.uuid4())
    
    initial_question = "아기 기저귀 사진의 똥 부분만 보고 건강 상태를 설명해줘. 이상이 있다면 가능한 원인과 추가로 확인해야 할 상황에 대해 알려줘. 똥이 없는 경우 000 이라고만 해."
    
    content = [
                {
                    "type": "text",
                    "text": initial_question
                },
                {
                    "type": "image_url",
                    "image_url": {
                        "url": f"data:image/jpeg;base64,{base64_image}",
                        "detail": "auto"
                    }
                }
            ]
    
    # 대화 기록을 초기화
    conversations[session_id] = [
        {"role": "user", "content": content}
    ]

    # GPT-4 호출하여 첫 질문에 대한 답변을 받음
    try:
        response = call_gpt4o(conversations[session_id])
        
        if response=="000":  #재촬영 필요
            return 0
        
        else:
            # GPT의 답변을 대화 기록에 추가
            conversations[session_id].append({"role": "assistant", "content": response})
            audio_response = speak(response)
            
            return {"session_id": session_id, "response": response, "audio": audio_response}
        
    except Exception as e:
        return jsonify({"error": str(e)}), 500


speaker = OpenAI(api_key=API_KEY)

# text to speach
def speak(text):
    
    response = speaker.audio.speech.create(
        model = "tts-1",
        input = text,
        voice = "alloy",
        response_format = "mp3",
        speed = 1.0
    )
    return response