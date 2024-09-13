import os
import cv2
import numpy as np
from PIL import Image

input_dir = r'C:\Shanmathi\Hackathon_Projects\SIH\sih24\Dataset\Original_Dataset\Bird'
output_dir = r'C:\Shanmathi\Hackathon_Projects\SIH\sih24\Dataset\Preprocessed\Bird'
os.makedirs(output_dir, exist_ok=True)

uniform_size = (224, 224)

# Initialize CLAHE
clahe = cv2.createCLAHE(clipLimit=2.0, tileGridSize=(8, 8))

for filename in os.listdir(input_dir):
    if filename.endswith('.jpg'):
        img_path = os.path.join(input_dir, filename)
        img = Image.open(img_path)
        img_np = np.array(img)

        # Check if the image is grayscale or color
        if len(img_np.shape) == 2:  # Grayscale image
            # Resize image
            resized_img = cv2.resize(img_np, uniform_size)
            # Apply CLAHE
            clahe_img = clahe.apply(resized_img)
        elif len(img_np.shape) == 3:  # Color image (RGB)
            # Resize image
            resized_img = cv2.resize(img_np, uniform_size)
            # Split channels
            channels = cv2.split(resized_img)
            # Apply CLAHE to each channel
            clahe_channels = [clahe.apply(ch) for ch in channels]
            # Merge channels
            clahe_img = cv2.merge(clahe_channels)
        else:
            raise ValueError("Unsupported image format")

        # Normalize image
        normalized_img = clahe_img / 255.0

        output_path = os.path.join(output_dir, filename)
        cv2.imwrite(output_path, (normalized_img * 255).astype('uint8'))

print(f"Processed and saved images in {output_dir}.")
