# ComfyUI Cloud Setup for Image & Video Workflows

This repository contains a comprehensive setup script (`setup_lambda.sh`) to automate the installation and configuration of a feature-rich ComfyUI instance on a cloud server, specifically tailored for Lambda Cloud running Ubuntu.

The script is designed to create a production-ready environment for advanced image and video generation by pre-installing a wide range of models and essential custom nodes. It solves common installation pitfalls, such as PyTorch and CUDA dependency conflicts, ensuring a smooth setup process.

---

## Features

-   **Automated Installation**: Performs a complete, clean installation of ComfyUI.
-   **Correct PyTorch First**: Installs the GPU-enabled version of PyTorch in isolation *before* other dependencies to prevent CUDA errors.
-   **Essential Custom Nodes**: Pre-installs a curated list of the most useful custom nodes:
    -   ComfyUI Manager
    -   WAS Node Suite
    -   rgthree-comfy
    -   ComfyUI-GGUF
    -   ComfyUI-KJNodes
-   **Comprehensive Model Pack**: Downloads and organizes all necessary models for multiple advanced workflows:
    -   Qwen Image Editing & Generation
    -   WAN 2.2 Text-to-Video Generation
-   **Unattended Setup**: Prompts for an optional Hugging Face token at the start, then runs completely unattended.
-   **Easy Startup**: Creates a simple `start_comfyui.sh` script in the user's home directory for easy launching.

---

## Requirements

-   An Ubuntu-based cloud instance.
-   An NVIDIA GPU with the appropriate drivers installed (tested on Lambda Cloud with a 4090).
-   `git` and `curl` installed (the script installs these if they are missing).

---

## How to Use

1.  **SSH into your Cloud Instance**
    Log into your fresh Ubuntu server.

2.  **Clone this Repository**
    ```bash
    git clone [https://github.com/tourniquetrules/comfyuisetup.git](https://github.com/tourniquetrules/comfyuisetup.git)
    cd comfyuisetup
    ```

3.  **Make the Script Executable**
    ```bash
    chmod +x setup_lambda.sh
    ```

4.  **Run the Script**
    ```bash
    ./setup_lambda.sh
    ```

5.  **Enter Hugging Face Token (Optional)**
    The script will immediately prompt you for a Hugging Face token. This is required to download certain "gated" models.
    -   **If you have one:** Paste your token and press Enter.
    -   **If you don't:** Just press Enter to skip. The script will continue but may fail to download a few specific models.

6.  **Wait for Setup to Complete**
    The script will take several minutes to download all the models and install the dependencies. Once it's finished, it will display a "Setup complete" message.

7.  **Launch ComfyUI**
    You can now start the ComfyUI server at any time by running:
    ```bash
    ~/start_comfyui.sh
    ```
    You can then access the web interface at `http://<YOUR_INSTANCE_IP>:8188`.

---

## Pre-Installed Models

This script installs all the necessary models to run the following workflows out of the box:

#### 🖼️ Qwen Image Workflows
-   **Diffusion Models**: `qwen_image_edit_fp8_e4m3fn.safetensors`, `qwen_image_fp8_e4m3fn.safetensors`
-   **Text Encoder**: `qwen_2.5_vl_7b_fp8_scaled.safetensors`
-   **VAE**: `qwen_image_vae.safetensors`
-   **LoRA**: `Qwen-Image-Lightning-4steps-V1.0-bf16.safetensors`

#### 📹 WAN 2.2 Video Workflow
-   **Diffusion Models**: `wan2.2_t2v_high_noise_14B_fp8_scaled.safetensors`, `wan2.2_t2v_low_noise_14B_fp8_scaled.safetensors`
-   **Text Encoder**: `umt5_xxl_fp8_e4m3fn_scaled.safetensors`
-   **VAE**: `wan_2.1_vae.safetensors`
-   **LoRAs**: `wan2.2_t2v_lightx2v_4steps_lora_v1.1_high_noise.safetensors`, `wan2.2_t2v_lightx2v_4steps_lora_v1.1_low_noise.safetensors`

---

## Troubleshooting

-   **`AssertionError: Torch not compiled with CUDA enabled`**: This script is specifically designed to prevent this error by installing PyTorch first. If you encounter this, it means another Python package is causing a conflict. The best solution is to delete the `~/ComfyUI` directory and run this script again on a clean instance.
-   **Missing `SetNode`/`GetNode`**: This script installs both the WAS Node Suite and KJNodes, which should provide these. If a workflow still reports them as missing, use the ComfyUI Manager to search for and install any other missing custom nodes.
