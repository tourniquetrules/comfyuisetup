#!/usr/bin/env bash
#
# Definitive ComfyUI Setup Script for Lambda Cloud
# Installs PyTorch for CUDA first, adds all custom nodes and workflows.
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
TEXT_ENCODER_DIR="${COMFY_DIR}/models/text_encoders"
VAE_DIR="${COMFY_DIR}/models/vae"
LORA_DIR="${COMFY_DIR}/models/loras"

# --- Custom User Workflow ---
USER_WORKFLOW_URL="https://raw.githubusercontent.com/tourniquetrules/comfyuisetup/main/1_Qwen-Edit_HRF_v0.json"
USER_WORKFLOW_DIR="${COMFY_DIR}/user/default/workflows"
USER_WORKFLOW_NAME="1_Qwen-Edit_HRF_v0.json"

# --- Model URLs ---
QWEN_UNET_EDIT_URL="https://huggingface.co/Comfy-Org/Qwen-Image-Edit_ComfyUI/resolve/main/split_files/diffusion_models/qwen_image_edit_fp8_e4m3fn.safetensors"
QWEN_UNET_NATIVE_URL="https://huggingface.co/Comfy-Org/Qwen-Image_ComfyUI/resolve/main/split_files/diffusion_models/qwen_image_fp8_e4m3fn.safetensors"
QWEN_LORA_URL="https://huggingface.co/lightx2v/Qwen-Image-Lightning/resolve/main/Qwen-Image-Lightning-4steps-V1.0-bf16.safetensors"
QWEN_CLIP_URL="https://huggingface.co/Comfy-Org/Qwen-Image_ComfyUI/resolve/main/split_files/text_encoders/qwen_2.5_vl_7b_fp8_scaled.safetensors"
QWEN_VAE_URL="https://huggingface.co/Comfy-Org/Qwen-Image_ComfyUI/resolve/main/split_files/vae/qwen_image_vae.safetensors"
WAN_UNET_HIGH_URL="https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/diffusion_models/wan2.2_t2v_high_noise_14B_fp8_scaled.safetensors"
WAN_UNET_LOW_URL="https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/diffusion_models/wan2.2_t2v_low_noise_14B_fp8_scaled.safetensors"
WAN_LORA_HIGH_URL="https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/loras/wan2.2_t2v_lightx2v_4steps_lora_v1.1_high_noise.safetensors"
WAN_LORA_LOW_URL="https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/loras/wan2.2_t2v_lightx2v_4steps_lora_v1.1_low_noise.safetensors"
WAN_VAE_URL="https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/vae/wan_2.1_vae.safetensors"
WAN_CLIP_URL="https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/text_encoders/umt5_xxl_fp8_e4m3fn_scaled.safetensors"

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
say "This script will perform a clean, robust installation of ComfyUI."

if [ -d "$COMFY_DIR" ]; then
  say "Removing existing ComfyUI directory for a clean install..."
  rm -rf "$COMFY_DIR"
fi

say "[1/8] Installing OS packages…"
sudo apt-get update -y
sudo apt-get install -y git "${PYTHON_BIN}-venv" "${PYTHON_BIN}-pip" ffmpeg aria2 curl

say "[2/8] Cloning a fresh copy of ComfyUI repository…"
git clone https://github.com/comfyanonymous/ComfyUI.git "$COMFY_DIR"

say "[3/8] Setting up Python environment and installing PyTorch for GPU…"
VENV_DIR="$COMFY_DIR/venv"
"$PYTHON_BIN" -m venv "$VENV_DIR"
VENV_PIP="${VENV_DIR}/bin/pip"
"$VENV_PIP" install --upgrade pip wheel
# CRITICAL STEP: Install PyTorch with CUDA support FIRST and in isolation.
"$VENV_PIP" install torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu121

say "[4/8] Verifying PyTorch and CUDA..."
"${VENV_DIR}/bin/python" -c "import torch; assert torch.cuda.is_available(), 'ERROR: CUDA not available to PyTorch. Installation failed.'; print(f'✅ PyTorch {torch.__version__} with CUDA {torch.version.cuda} is correctly installed.')"

say "[5/8] Installing ComfyUI and Custom Node Dependencies…"
# Now that PyTorch is correctly installed, we install other requirements.
"$VENV_PIP" install -r "${COMFY_DIR}/requirements.txt" --upgrade
# Install Custom Nodes
git clone https://github.com/ltdrdata/ComfyUI-Manager.git "${CUSTOM_NODES_DIR}/ComfyUI-Manager"
git clone https://github.com/WASasquatch/was-node-suite-comfyui.git "${CUSTOM_NODES_DIR}/was-node-suite-comfyui"
git clone https://github.com/rgthree/rgthree-comfy.git "${CUSTOM_NODES_DIR}/rgthree-comfy"
git clone https://github.com/city96/ComfyUI-GGUF.git "${CUSTOM_NODES_DIR}/ComfyUI-GGUF"
git clone https://github.com/kijai/ComfyUI-KJNodes.git "${CUSTOM_NODES_DIR}/ComfyUI-KJNodes"
# Install Custom Node Dependencies
"$VENV_PIP" install -r "${CUSTOM_NODES_DIR}/was-node-suite-comfyui/requirements.txt"
"$VENV_PIP" install -r "${CUSTOM_NODES_DIR}/ComfyUI-KJNodes/requirements.txt"
"$VENV_PIP" install gguf

say "[6/8] Downloading all required models…"
if [[ -n "${HF_TOKEN}" ]]; then say "Using HF Token for downloads."; else say "No HF Token provided."; fi
# Qwen Image Models
aria2_get "$DIFFUSION_DIR"    "qwen_image_edit_fp8_e4m3fn.safetensors" "$QWEN_UNET_EDIT_URL"
aria2_get "$DIFFUSION_DIR"    "qwen_image_fp8_e4m3fn.safetensors" "$QWEN_UNET_NATIVE_URL"
aria2_get "$LORA_DIR"         "Qwen-Image-Lightning-4steps-V1.0-bf16.safetensors" "$QWEN_LORA_URL"
aria2_get "$TEXT_ENCODER_DIR" "qwen_2.5_vl_7b_fp8_scaled.safetensors" "$QWEN_CLIP_URL"
aria2_get "$VAE_DIR"          "qwen_image_vae.safetensors" "$QWEN_VAE_URL"
# WAN Video Models
aria2_get "$DIFFUSION_DIR"    "wan2.2_t2v_high_noise_14B_fp8_scaled.safetensors" "$WAN_UNET_HIGH_URL"
aria2_get "$DIFFUSION_DIR"    "wan2.2_t2v_low_noise_14B_fp8_scaled.safetensors" "$WAN_UNET_LOW_URL"
aria2_get "$LORA_DIR"         "wan2.2_t2v_lightx2v_4steps_lora_v1.1_high_noise.safetensors" "$WAN_LORA_HIGH_URL"
aria2_get "$LORA_DIR"         "wan2.2_t2v_lightx2v_4steps_lora_v1.1_low_noise.safetensors" "$WAN_LORA_LOW_URL"
aria2_get "$VAE_DIR"          "wan_2.1_vae.safetensors" "$WAN_VAE_URL"
aria2_get "$TEXT_ENCODER_DIR" "umt5_xxl_fp8_e4m3fn_scaled.safetensors" "$WAN_CLIP_URL"

say "[7/8] Installing Custom User Workflow…"
say "Creating directory: ${USER_WORKFLOW_DIR}"
mkdir -p "${USER_WORKFLOW_DIR}"
say "Downloading ${USER_WORKFLOW_NAME} to user workflows folder..."
curl -Lo "${USER_WORKFLOW_DIR}/${USER_WORKFLOW_NAME}" "${USER_WORKFLOW_URL}"

say "[8/8] Creating start script…"
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
echo "Your custom workflow has been saved. You can load it from the Manager menu."
echo
echo "To start ComfyUI, run:"
echo "  ${HOME}/start_comfyui.sh"
echo
IP_ADDR="$(curl -s ifconfig.me || echo 'YOUR_INSTANCE_IP')"
echo "You can access the web UI at: http://${IP_ADDR}:${PORT}"
echo
