import os
from PIL import Image

def augment_images(input_dir, output_dir):
    os.makedirs(output_dir, exist_ok=True)
    for filename in os.listdir(input_dir):
        if filename.lower().endswith(('.jpg')):
            img_path = os.path.join(input_dir, filename)
            with Image.open(img_path) as img:
                augmentations = {
                    'vflip': img.transpose(Image.FLIP_TOP_BOTTOM),
                    'hflip': img.transpose(Image.FLIP_LEFT_RIGHT),
                    'rotate180': img.rotate(180)
                }
                for method, augmented_img in augmentations.items():
                    new_filename = f"{os.path.splitext(filename)[0]}_{method}.jpg"
                    output_path = os.path.join(output_dir, new_filename)
                    augmented_img.save(output_path)

input_directory = r'Dataset\Preprocessed_Dataset\Bird'
output_directory = r'Dataset\Augmented_Dataset\Bird'

augment_images(input_directory, output_directory)
