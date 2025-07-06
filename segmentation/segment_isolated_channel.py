import os
import sys
from cellpose import models
from PIL import Image
import numpy as np

def segment_folder(input_folder, output_folder):
    # Load Cellpose with the nuclei model
    model = models.CellposeModel(gpu=True, model_type='nuclei')

    # Collect all .png files in the directory
    image_files = sorted([f for f in os.listdir(input_folder) if f.lower().endswith(".png")])

    if not image_files:
        print("No PNG files found in input directory. Exiting...")
        return

    print(f"Found {len(image_files)} image(s) for segmentation")

    # Create output directory if it doesn't exist
    os.makedirs(output_folder, exist_ok=True)

    for fname in image_files:
        img_path = os.path.join(input_folder, fname)
        img = np.array(Image.open(img_path).convert("RGB"))

        # Run Cellpose segmentation
        masks, _, _, _ = model.eval(
            img,
            diameter=None,
            channels=[0, 0],  # Use grayscale
            flow_threshold=None,
            do_3D=False
        )

        # Convert mask to binary (0 or 255)
        binary_mask = (masks > 0).astype(np.uint8) * 255

        # Save to the output directory
        out_path = os.path.join(output_folder, fname.replace(".png", "_mask.png"))
        Image.fromarray(binary_mask).save(out_path)

    print(f"✅ Saved all masks to {output_folder}")

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python segment_isolated_channel.py <input_folder> <output_folder>")
        sys.exit(1)

    segment_folder(sys.argv[1], sys.argv[2])
