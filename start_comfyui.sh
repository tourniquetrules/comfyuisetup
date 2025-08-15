#!/bin/bash
# ComfyUI Start Script
# Run this after setup to start ComfyUI server

PORT="${PORT:-8188}"

echo "🚀 Starting ComfyUI server..."

# Check if ComfyUI exists
if [ ! -d "/workspace/ComfyUI" ]; then
    echo "❌ ComfyUI not found. Please run setup_comfyui_direct.sh first"
    exit 1
fi

cd /workspace/ComfyUI

# Check if models exist
if [ ! -f "models/diffusion_models/flux1-krea-dev_fp8_scaled.safetensors" ]; then
    echo "❌ Models not found. Please run setup_comfyui_direct.sh first"
    exit 1
fi

# Get the public IP
PUBLIC_IP=$(curl -s ifconfig.me 2>/dev/null || curl -s ipinfo.io/ip 2>/dev/null || echo "YOUR_INSTANCE_IP")

echo "🌐 ComfyUI will be available at: http://$PUBLIC_IP:$PORT"
echo "🔄 Starting server (Ctrl+C to stop)..."
echo ""

# Start ComfyUI with proper Linux command
python main.py --listen 0.0.0.0 --port $PORT --enable-cors-header
