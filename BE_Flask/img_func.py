import requests
from PIL import Image
import io as io_module
import numpy as np
from skimage import img_as_ubyte
import os

# AWB-white patch algorithm
def white_patch(image, percentile=100):
    white_patch_image = img_as_ubyte((image * 1.0/np.percentile(image,percentile,axis=(0, 1))).clip(0, 1))
    return white_patch_image


# 이미지 전처리 함수 (이미지 URL 입력 및 처리 후 이미지 경로 반환)
def img_preprocess(input_image_url, output_path):
    # URL에서 이미지 다운로드
    response = requests.get(input_image_url)
    input_image = Image.open(io_module.BytesIO(response.content))

    # 이미지를 불러온 후 AWB 적용
    white_balanced_image = white_patch(input_image)

    # PIL 이미지로 변환
    pil_image = Image.fromarray(white_balanced_image)

    # 처리된 이미지를 파일로 저장
    output_file = os.path.join(output_path, "processed_image.png")
    pil_image.save(output_file)

    # 저장된 파일 경로를 반환 (또는 웹 서버를 사용 중이라면 해당 경로의 URL 반환)
    return output_file