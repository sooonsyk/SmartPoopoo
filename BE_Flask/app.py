from flask import Flask, jsonify, request
import torch
import numpy as np
from skimage import io
from PIL import Image
import base64


import img_func
import gpt_model


app = Flask(__name__)

###################
#      YOLO      
###################
#diaper_model = torch.hub.load('ultralytics/yolov5', 'custom', path='/best_diaper.pt', source='local')
tester_model = torch.hub.load('ultralytics/yolov5', 'custom', path='/best_tester.pt', source='local')

# 메모리상에 대화 기록을 저장하는 딕셔너리 (세션별로 기록)
conversations = {}

# 아기 똥 
# 기저귀 탐지 및 건강 상태 진단
@app.route('/smartpoopoo', methods=['POST'])
def smartpoopoo():
    try:
        
        # Base64 형식으로 이미지 전달 받음
        data = request.get_json()
        base64_image = data['image']

        # Base64를 디코딩하여 이미지로 변환
        image_data = base64.b64decode(base64_image)
        image = Image.open(io.BytesIO(image_data))

        # 이미지 전처리
        input_img = img_func.img_preprocess(image)
        
        # yolo를 프론트에서 하면 불필요한 부분
        
        # diaper_result = diaper_model(input_img)

        # # 바운딩 박스 추출
        # bounding_box = diaper_result.xyxy[0].numpy()

        # # 감지 안 됐으면 에러 응답 반환 - 다시 이미지 요청
        # if len(bounding_box) == 0:
        #     return jsonify({'error': 'No object detected'}), 400

        # # 감지 됐으면 크롭
        # ################  audio_success = gpt_model.speak("기저귀 발견") 이걸 먼저 전달하고 싶은데 방법이 없나
        # x1, y1, x2, y2 = map(int, bounding_box[0][:4])
        # img_np = np.array(input_img)
        # detected_diaper = img_np[y1:y2, x1:x2]

        
        #first_answer = gpt_model.start(detected_diaper)
        
        # smart model 호출
        first_answer = gpt_model.start(input_img, conversations)
        
        if not first_answer:
            # 재촬영 필요
            audio_failed = gpt_model.speak("기저귀에 똥이 없어요.")
            return jsonify({'error': 'No poopoo detected', 'audio': audio_failed}), 400
        
        else :
            # 크롭된 이미지를 Base64로 변환
            #cropped_image_pil = Image.fromarray(detected_diaper)
            
            cropped_image_pil = Image.fromarray(input_img)
            buffered = io.BytesIO()
            cropped_image_pil.save(buffered, format="JPEG")
            cropped_image_base64 = base64.b64encode(buffered.getvalue()).decode("utf-8")
            
            first_answer['cropped_image'] = cropped_image_base64

            # 응답 반환 - 크롭된 이미지(Base64)와 첫 답변 반환
            return jsonify(first_answer), 200

    # 오류 발생 시
    except Exception as e:
        return jsonify({"error": str(e)}), 500

    
# # 결정되는 대로 완성
# # 임신 테스트기 분류
# @app.route('/upload_tester', methods=['POST'])
# def upload_tester():
#     try:
#         data = request.get_json()
#         base64_image = data['image']

#         # Base64를 디코딩하여 이미지로 변환
#         image_data = base64.b64decode(base64_image)
#         image = Image.open(io.BytesIO(image_data))

#         input_img = img_func.img_preprocess(image)
#         tester_result = tester_model(input_img)
#         bounding_box = tester_result.xyxy[0].numpy()

#         #감지 안 됐으면 계속 감지 시도 됐으면 결과 전달
#         if len(bounding_box):
#             # image crop
#             x1, y1, x2, y2 = map(int, bounding_box[0][:4])
#             img_np = np.array(input_img)
#             detected_tester = img_np[y1:y2, x1:x2]
            
#             # smart model ??? - 임테기 모델을 어떻게 할 것인지 추후 반영
#             result = gpt_model.start(detected_tester)

#         # 예시로 응답 반환
#         return jsonify({'image' : detected_tester, 'result' : result}), 200
#     except Exception as e:
#         return jsonify({"error": str(e)}), 500


###################
#     ChatGPT     
###################

# 추가 질문
@app.route('/ask', methods=['POST'])
def ask():
    
    # 세션 ID와 추가 질문을 음성으로 받아옴
    data = request.form
    session_id = data.get("session_id")
    audio_file = request.files.get("audio")
    
    if not session_id or session_id not in conversations:
            return jsonify({"error": "Invalid or missing session_id"}), 400

    if not audio_file:
            return jsonify({"error": "No audio file provided"}), 400

    # speach to text
    question = gpt_model.client.audio.transcriptions.create(
        model = "whisper-1", 
        file = audio_file
    )
        
    # 대화 기록에 추가 질문을 저장
    conversations[session_id].append({"role": "user", "content": question})

    # GPT-4 호출하여 추가 질문에 대한 답변을 받음
    try:
        response = gpt_model.call_gpt4o(conversations[session_id])
        # GPT의 답변을 대화 기록에 추가
        conversations[session_id].append({"role": "assistant", "content" : response})
        
        return jsonify({"response": response})
    
    except Exception as e:
        return jsonify({"error": str(e)}), 500


if __name__ == '__main__':
    app.run(debug=True)