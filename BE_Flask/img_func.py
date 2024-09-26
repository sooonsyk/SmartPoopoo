import base64
from skimage import img_as_ubyte, io
import numpy as np
from PIL import Image
import io as io_module

# AWB-white patch algorithm
def white_patch(image, percentile=100):
    white_patch_image = img_as_ubyte((image * 1.0/np.percentile(image,percentile,axis=(0, 1))).clip(0, 1))
    return white_patch_image

# 이미지 전처리 함수
#############33 base64로 이미지가 들어오는 거에 맞춰서 수정해야함
def img_preprocess(image_path):
    
    # 이미지를 불러온 후 AWB 적용
    input_image = io.imread(image_path)
    white_balanced_image = white_patch(input_image)
    pil_image = Image.fromarray(white_balanced_image)

    # 메모리 버퍼에 저장
    buffered = io_module.BytesIO()
    pil_image.save(buffered, format="PNG")

    # base64로 인코딩
    return base64.b64encode(buffered.getvalue()).decode('utf-8')
