#!/usr/bin/env bash
#
# Setup Script for the Infinite Talk ComfyUI Workflow on Lambda Cloud
#

# --- Prompt for Hugging Face Token at the very beginning ---
echo -e "\033[1;36mSome models require a Hugging Face token for authorized download.\033[0m"
read -sp "Please enter your Hugging Face token (or press Enter to skip): " HF_TOKEN
echo # Move to a new line after the prompt
# --- End of Prompt Section ---

set -euo pipefail

########################################
# Config
########################################
COMFY_DIR="$HOME/ComfyUI"
PYTHON_BIN="python3"
PORT="8188"
LISTEN_ADDR="0.0.0.0"
A2_CONN=16

########################################
# Model & Node Definitions
########################################
CUSTOM_NODES_DIR="${COMFY_DIR}/custom_nodes"
DIFFUSION_DIR="${COMFY_DIR}/models/diffusion_models"
LORA_DIR="${COMFY_DIR}/models/loras"
VAE_DIR="${COMFY_DIR}/models/vae"
CLIP_VISION_DIR="${COMFY_DIR}/models/clip_vision"
WAV2VEC2_DIR="${COMFY_DIR}/models/wav2vec2"
TEXT_ENCODER_DIR="${COMFY_DIR}/models/text_encoders" # Corresponds to the 'clip' folder in the workflow notes

# --- Model URLs for Infinite Talk Workflow ---
#
IT_MODEL_URL="https://huggingface.co/city96/Wan2.1-I2V-14B-480P-gguf/resolve/main/wan2.1-i2v-14b-480p-Q4_0.gguf"
IT_LORA_URL="https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/Lightx2v/lightx2v_I2V_14B_480p_cfg_step_distill_rank64_bf16.safetensors"
IT_MULTITALK_URL="https://huggingface.co/Kijai/WanVideo_comfy_GGUF/resolve/main/InfiniteTalk/Wan2_1-InfiniteTalk_Single_Q8.gguf"
IT_VAE_URL="https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/vae/wan_2.1_vae.safetensors"
IT_CLIP_VISION_URL="https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/clip_vision/clip_vision_h.safetensors"
IT_WAV2VEC2_URL="https://huggingface.
