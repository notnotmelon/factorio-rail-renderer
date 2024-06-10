import os
import shutil

# Specify the destination directory
destination_directory = 'C:/Users/zacha/Documents/factorio/mods/pystellarexpeditiongraphics/graphics/entity/space-rail/vanilla'
# Create the destination directory if it doesn't exist
os.makedirs(destination_directory, exist_ok=True)

# Specify the source directory
for source_directory in ['C:/Users/zacha/Documents/factorio/data/base/graphics/entity/straight-rail', 'C:/Users/zacha/Documents/factorio/data/base/graphics/entity/curved-rail']:
    # Iterate over all files in the source directory
    for filename in os.listdir(source_directory):
        if filename.startswith('hr-') and filename.endswith('-background.png'):
            print(filename)
            # Construct the source and destination paths
            source_path = os.path.join(source_directory, filename)
            destination_path = os.path.join(destination_directory, filename)
            
            # Move the file to the destination directory
            shutil.copy(source_path, destination_path)

    print('Extraction complete!')