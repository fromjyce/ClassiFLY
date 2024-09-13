import os
directory = r'DIAT-uSAT_dataset\Bird+mini-helicopter_2\Bird+2_Blade_rotor_2'
png_files = [f for f in os.listdir(directory) if f.endswith('.jpg')]
png_files.sort()
for i, filename in enumerate(png_files, start=3650):
    new_name = f"drone_{i}.jpg"
    old_file = os.path.join(directory, filename)
    new_file = os.path.join(directory, new_name)
    os.rename(old_file, new_file)

print(f"Renamed {len(png_files)} files.")
