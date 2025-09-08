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
IT_WAV2VEC2_URL="https://huggingface.co/Kijai/wav2vec2_safetensors/resolve/main/wav2vec2-chinese-base_fp16.safetensors"
IT_TEXT_ENCODER_URL="https://huggingface.co/ALGOTECH/WanVideo_comfy/resolve/main/umt5-xxl-enc-bf16.safetensors"


########################################
# Helper Functions
########################################
say() { echo -e "\033[1;36m$*\033[0m"; }

aria2_get() {
  local dest="$1" filename="$2" url="$3"
  say "Downloading ${filename} to ${dest}…"
  mkdir -p "$dest"
  local headers=()
  if [[ -n "${HF_TOKEN}" ]]; then
    headers+=("--header=Authorization: Bearer ${HF_TOKEN}")
  fi
  aria2c -c -x "$A2_CONN" -s "$A2_CONN" -k 1M --summary-interval=0 \
    -d "$dest" -o "$filename" "${headers[@]}" "$url"
}

########################################
# Main Execution
########################################
say "This script will perform a clean installation of ComfyUI for the Infinite Talk workflow."

if [ -d "$COMFY_DIR" ]; then
  say "Removing existing ComfyUI directory for a clean install..."
  rm -rf "$COMFY_DIR"
fi

say "[1/7] Installing OS packages…"
sudo apt-get update -y
sudo apt-get install -y git "${PYTHON_BIN}-venv" "${PYTHON_BIN}-pip" ffmpeg aria2 curl

say "[2/7] Cloning a fresh copy of ComfyUI repository…"
git clone https://github.com/comfyanonymous/ComfyUI.git "$COMFY_DIR"

say "[3/7] Setting up Python environment and installing PyTorch for GPU…"
VENV_DIR="$COMFY_DIR/venv"
"$PYTHON_BIN" -m venv "$VENV_DIR"
VENV_PIP="${VENV_DIR}/bin/pip"
"$VENV_PIP" install --upgrade pip wheel
# CRITICAL STEP: Install PyTorch with CUDA support FIRST and in isolation.
"$VENV_PIP" install torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu129

say "[4/7] Verifying PyTorch and CUDA..."
"${VENV_DIR}/bin/python" -c "import torch; assert torch.cuda.is_available(), 'ERROR: CUDA not available to PyTorch. Installation failed.'; print(f'✅ PyTorch {torch.__version__} with CUDA {torch.version.cuda} is correctly installed.')"

say "[5/7] Installing ComfyUI requirements and Custom Nodes…"
"$VENV_PIP" install -r "${COMFY_DIR}/requirements.txt" --upgrade

# Install Custom Nodes required by the workflow
git clone https://github.com/ltdrdata/ComfyUI-Manager.git "${CUSTOM_NODES_DIR}/ComfyUI-Manager"
git clone https://github.com/Fannovel16/ComfyUI-WanVideoWrapper.git "${CUSTOM_NODES_DIR}/ComfyUI-WanVideoWrapper"
git clone https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite.git "${CUSTOM_NODES_DIR}/ComfyUI-VideoHelperSuite"
git clone https://github.com/rgthree/rgthree-comfy.git "${CUSTOM_NODES_DIR}/rgthree-comfy"

say "[6/7] Downloading all models for the Infinite Talk Workflow…"
if [[ -n "${HF_TOKEN}" ]]; then say "Using HF Token for downloads."; else say "No HF Token provided."; fi

# Download all 7 models specified in the workflow file
aria2_get "$DIFFUSION_DIR"   "wan2.1-i2v-14b-480p-Q4_0.gguf" "$IT_MODEL_URL"
aria2_get "$LORA_DIR"        "lightx2v_I2V_14B_480p_cfg_step_distill_rank64_bf16.safetensors" "$IT_LORA_URL"
aria2_get "$DIFFUSION_DIR"   "Wan2_1-InfiniteTalk_Single_Q8.gguf" "$IT_MULTITALK_URL"
aria2_get "$VAE_DIR"         "wan_2.1_vae.safetensors" "$IT_VAE_URL"
aria2_get "$CLIP_VISION_DIR" "clip_vision_h.safetensors" "$IT_CLIP_VISION_URL"
aria2_get "$WAV2VEC2_DIR"    "wav2vec2-chinese-base_fp16.safetensors" "$IT_WAV2VEC2_URL"
aria2_get "$TEXT_ENCODER_DIR" "umt5-xxl-enc-bf16.safetensors" "$IT_TEXT_ENCODER_URL"

say "[7/7] Creating start script…"
cat > "${HOME}/start_comfyui.sh" <<EOF
#!/usr/bin/env bash
set -e
cd "${COMFY_DIR}"
source "venv/bin/activate"
exec python main.py --listen ${LISTEN_ADDR} --port ${PORT}
EOF
chmod +x "${HOME}/start_comfyui.sh"

echo
echo -e "\033[1;32m✅ Setup complete.\033[0m"
echo
echo "The environment for the Infinite Talk workflow is ready."
echo "You can now upload the workflow file to the ComfyUI interface."
echo
echo "To start ComfyUI, run:"
echo "  ${HOME}/start_comfyui.sh"
echo
IP_ADDR="$(curl -s ifconfig.me || echo 'YOUR_INSTANCE_IP')"
echo "You can access the web UI at: http://${IP_ADDR}:${PORT}"
echo
