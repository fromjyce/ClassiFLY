import os
import shutil
import random

base_dir = r'C:\Shanmathi\Hackathon_Projects\SIH\sih24\Dataset\Preprocessed_Dataset'
train_dir = r'C:\Shanmathi\Hackathon_Projects\SIH\sih24\Dataset\Model_Dataset\Train'
test_dir = r'C:\Shanmathi\Hackathon_Projects\SIH\sih24\Dataset\Model_Dataset\Test'

os.makedirs(train_dir, exist_ok=True)
os.makedirs(test_dir, exist_ok=True)


for category in ['drone', 'bird']:
    os.makedirs(os.path.join(train_dir, category), exist_ok=True)
    os.makedirs(os.path.join(test_dir, category), exist_ok=True)

split_ratio = 0.8

for category in ['drone', 'bird']:
    category_path = os.path.join(base_dir, category)
    images = os.listdir(category_path)
    random.shuffle(images)
    split_index = int(len(images) * split_ratio)
    train_images = images[:split_index]
    test_images = images[split_index:]
    for image in train_images:
        shutil.copy(os.path.join(category_path, image), os.path.join(train_dir, category, image))

    for image in test_images:
        shutil.copy(os.path.join(category_path, image), os.path.join(test_dir, category, image))

print("Data splitting complete.")