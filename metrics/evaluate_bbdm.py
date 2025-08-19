from skimage.metrics import structural_similarity as ssim
from skimage.metrics import peak_signal_noise_ratio as psnr
from PIL import Image
import numpy as np
import os

def evaluate(dir_path):
    gen_dir = os.path.join(dir_path, "200")
    gt_dir = os.path.join(dir_path, "ground_truth")

    psnr_scores = []
    ssim_scores = []
    mse_scores = []

    for fname in sorted(os.listdir(gen_dir)):
        gen_img = np.array(Image.open(os.path.join(gen_dir, fname)).convert("RGB"))
        gt_img = np.array(Image.open(os.path.join(gt_dir, fname)).convert("RGB"))

        psnr_scores.append(psnr(gt_img, gen_img, data_range=255))
        ssim_scores.append(ssim(gt_img, gen_img, channel_axis=-1, data_range=255))
        mse_scores.append(np.mean((gt_img.astype(np.float32) - gen_img.astype(np.float32)) ** 2))

    print(f"PSNR: {np.mean(psnr_scores):.2f}")
    print(f"SSIM: {np.mean(ssim_scores):.4f}")
    print(f"MSE: {np.mean(mse_scores):.2f}")

print("Primary dataset:")
evaluate("../BBDM/results/YeastLume/LBBDM-f4/sample_to_eval")

print("\n")
print("Full test dataset:")
evaluate("../BBDM/results/YeastLume-Full-Test-Set/LBBDM-f4/sample_to_eval")
