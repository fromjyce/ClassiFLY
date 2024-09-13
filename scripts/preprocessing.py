import os
import cv2
import numpy as np
from PIL import Image
input_dir = r'Dataset\Original_Dataset\Drone'
output_dir = r'Dataset\Preprocessed_Dataset\Drone'
os.makedirs(output_dir, exist_ok=True)

uniform_size = (224, 224)

for filename in os.listdir(input_dir):
    if filename.endswith('.jpg'):
        img_path = os.path.join(input_dir, filename)
        img = Image.open(img_path)
        img_np = np.array(img)
        grayscale_img = 0.228 * img_np[:, :, 0] + 0.587 * img_np[:, :, 1] + 0.114 * img_np[:, :, 2]
        grayscale_img = np.clip(grayscale_img, 0, 255).astype('uint8')
        resized_img = cv2.resize(grayscale_img, uniform_size)
        normalized_img = resized_img / 255.0
        clahe = cv2.createCLAHE(clipLimit=2.0, tileGridSize=(8, 8))
        clahe_img = clahe.apply((normalized_img * 255).astype('uint8'))
        output_path = os.path.join(output_dir, filename)
        cv2.imwrite(output_path, clahe_img)

print(f"Processed and saved images in {output_dir}.")
