#!/bin/bash
# ComfyUI Setup Script for Vast.AI (Direct Installation)
# Run this script DIRECTLY on your Vast.AI instance after SSH'ing into it
# Usage: ./setup_comfyui_direct.sh [workflow_file]

set -e

WORKFLOW_FILE="$1"
PORT="${PORT:-8188}"

echo "🚀 Setting up ComfyUI on this Vast.AI instance"

# Prompt for Hugging Face token
echo ""
echo "🔑 Hugging Face Authentication Required"
echo "This script needs your Hugging Face token to download FLUX models."
echo "You can get your token from: https://huggingface.co/settings/tokens"
echo ""
read -p "Please enter your Hugging Face token: " HF_TOKEN

if [ -z "$HF_TOKEN" ]; then
    echo "❌ Error: Hugging Face token is required to download models."
    echo "Please get your token from https://huggingface.co/settings/tokens and run the script again."
    exit 1
fi

echo "✅ Token received, continuing with setup..."
echo ""

# Update system and install dependencies
echo "📦 Installing system packages..."
apt update && apt install -y git wget curl python3-pip jq

# Clone ComfyUI
echo "📥 Cloning ComfyUI..."
cd /workspace
git clone https://github.com/comfyanonymous/ComfyUI.git
cd ComfyUI

# Install Python requirements
echo "📦 Installing Python dependencies..."
pip install -r requirements.txt

# Create model directories
echo "📁 Creating model directories..."
mkdir -p models/diffusion_models
mkdir -p models/text_encoders
mkdir -p models/vae
mkdir -p models/loras
mkdir -p user/default/workflows

# Setup Hugging Face authentication
echo "🔑 Setting up Hugging Face authentication..."
pip install huggingface_hub
huggingface-cli login --token $HF_TOKEN

# Download models
echo "⬇️ Downloading models (this will take a while)..."

# Diffusion model (~11.9 GB)
echo "📥 Downloading FLUX.1-Krea diffusion model (~11.9 GB)..."
cd models/diffusion_models
wget -c --progress=bar:force:noscroll --timeout=300 --tries=3 \
     --header="Authorization: Bearer $HF_TOKEN" \
     -O flux1-krea-dev_fp8_scaled.safetensors \
     'https://huggingface.co/Comfy-Org/FLUX.1-Krea-dev_ComfyUI/resolve/main/split_files/diffusion_models/flux1-krea-dev_fp8_scaled.safetensors'

# Text encoders
echo "📥 Downloading CLIP text encoder..."
cd ../text_encoders
wget -c --progress=bar:force:noscroll --timeout=300 --tries=3 \
     --header="Authorization: Bearer $HF_TOKEN" \
     -O clip_l.safetensors \
     'https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/clip_l.safetensors'

echo "📥 Downloading T5 text encoder (~4.7 GB)..."
wget -c --progress=bar:force:noscroll --timeout=300 --tries=3 \
     --header="Authorization: Bearer $HF_TOKEN" \
     -O t5xxl_fp16.safetensors \
     'https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/t5xxl_fp16.safetensors'

# VAE
echo "📥 Downloading VAE..."
cd ../vae
wget -c --progress=bar:force:noscroll --timeout=300 --tries=3 \
     --header="Authorization: Bearer $HF_TOKEN" \
     -O ae.safetensors \
     'https://huggingface.co/Comfy-Org/Lumina_Image_2.0_Repackaged/resolve/main/split_files/vae/ae.safetensors'

# WAN2.2 T2V Models
echo "📥 Downloading WAN2.2 T2V models (~28 GB total)..."
cd ../diffusion_models

echo "📥 Downloading WAN2.2 T2V High Noise model (~14 GB)..."
wget -c --progress=bar:force:noscroll --timeout=600 --tries=3 \
     -O wan2.2_t2v_high_noise_14B_fp8_scaled.safetensors \
     'https://cas-bridge.xethub.hf.co/xet-bridge-us/6885cd8c6963bab90aab7f6f/05df25aaee6f71de8b854f1be0ae5c029484ddaf26292fa9c59bd2d6a6bdad97?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=cas%2F20250815%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20250815T130917Z&X-Amz-Expires=3600&X-Amz-Signature=92c1be0b026c4e014daf1c432c19f68c2560c06ec0e0157b2c8bd5bdd76c31a3&X-Amz-SignedHeaders=host&X-Xet-Cas-Uid=public&response-content-disposition=inline%3B+filename*%3DUTF-8%27%27wan2.2_t2v_high_noise_14B_fp8_scaled.safetensors%3B+filename%3D%22wan2.2_t2v_high_noise_14B_fp8_scaled.safetensors%22%3B&x-id=GetObject&Expires=1755266957&Policy=eyJTdGF0ZW1lbnQiOlt7IkNvbmRpdGlvbiI6eyJEYXRlTGVzc1RoYW4iOnsiQVdTOkVwb2NoVGltZSI6MTc1NTI2Njk1N319LCJSZXNvdXJjZSI6Imh0dHBzOi8vY2FzLWJyaWRnZS54ZXRodWIuaGYuY28veGV0LWJyaWRnZS11cy82ODg1Y2Q4YzY5NjNiYWI5MGFhYjdmNmYvMDVkZjI1YWFlZTZmNzFkZThiODU0ZjFiZTBhZTVjMDI5NDg0ZGRhZjI2MjkyZmE5YzU5YmQyZDZhNmJkYWQ5NyoifV19&Signature=W7VmQ8TGcEx8DI-FC6G3IEsa5dnoiamk9kYjIvJJwbcis41B2s7cL3ik-vEhpzssl4v7xlXwCcsLEeQlTmw0FitF3MUT5jogZ99uBR906yyHHQORwP6NL-9TWdH0o7yXrCWnxqYfRtn1ujtXtRn83UajUH4jEEaNHCC3BwAaEkGfhMm5%7Es5tm04UmFBhADDlZoB0BkVOH95lOUjVRSQLaJ71%7EbCfK3jht96f5qkpeI3GhiXFuCJg1zMlU9cGYQBJzi%7ExK2L6ILn7A0mzfTSU-Mr-rOD6C%7Ea6rjyPMhaiDhTPzU0-oyNlMfgkp4P7oIt8wVc2HD9wQqskR8ftBPtoDA__&Key-Pair-Id=K2L8F4GPSG1IFC'

echo "📥 Downloading WAN2.2 T2V Low Noise model (~14 GB)..."
wget -c --progress=bar:force:noscroll --timeout=600 --tries=3 \
     -O wan2.2_t2v_low_noise_14B_fp8_scaled.safetensors \
     'https://cas-bridge.xethub.hf.co/xet-bridge-us/6885cd8c6963bab90aab7f6f/d5de0e4fafbf5a545fbed060aee18ac0615a8c06ed571e3bbc77126de683cbc9?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=cas%2F20250815%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20250815T131924Z&X-Amz-Expires=3600&X-Amz-Signature=583049b54f37255b79410a59a52fa34be8c40193d43f618c865f3586605d440c&X-Amz-SignedHeaders=host&X-Xet-Cas-Uid=public&response-content-disposition=inline%3B+filename*%3DUTF-8%27%27wan2.2_t2v_low_noise_14B_fp8_scaled.safetensors%3B+filename%3D%22wan2.2_t2v_low_noise_14B_fp8_scaled.safetensors%22%3B&x-id=GetObject&Expires=1755267564&Policy=eyJTdGF0ZW1lbnQiOlt7IkNvbmRpdGlvbiI6eyJEYXRlTGVzc1RoYW4iOnsiQVdTOkVwb2NoVGltZSI6MTc1NTI2NzU2NH19LCJSZXNvdXJjZSI6Imh0dHBzOi8vY2FzLWJyaWRnZS54ZXRodWIuaGYuY28veGV0LWJyaWRnZS11cy82ODg1Y2Q4YzY5NjNiYWI5MGFhYjdmNmYvZDVkZTBlNGZhZmJmNWE1NDVmYmVkMDYwYWVlMThhYzA2MTVhOGMwNmVkNTcxZTNiYmM3NzEyNmRlNjgzY2JjOSoifV19&Signature=lBc8sRfxFlyPubqliFq8zNlp9-mqdCNHaW78K7llCORWuNtg1dVphKaDakhet5BsL7wEFlJOIW1KNWlVHzZQzdqjhE5-8hiTXpQimjLYHedG-7YBpp2meVvsjEJvmyuZiHguxd5CKuG8%7ElvDp14xWvUEq9uE7HcIQzst3s54jfL82Z03b-1GbjyrxrbaveJlzviyEBE-zL-iKMTmhUXNRfcBXL43eLWjnh7MbKiVW9sPkt9xKmhqxQYn5p60w0QYKXnhob3zfrZzYHM%7EQTGbnMrW4Yi3ZsoO4MJuIP9CCWXqrrXZ08vdMn4FOHACwqY%7EuDlOH9mg1NgQkiDdk-WRQg__&Key-Pair-Id=K2L8F4GPSG1IFC'

# WAN2.2 LoRA Models
echo "📥 Downloading WAN2.2 LightX2V LoRA models..."
mkdir -p ../loras
cd ../loras

echo "📥 Downloading WAN2.2 LightX2V High Noise LoRA..."
wget -c --progress=bar:force:noscroll --timeout=300 --tries=3 \
     -O wan2.2_t2v_lightx2v_4steps_lora_v1.1_high_noise.safetensors \
     'https://cas-bridge.xethub.hf.co/xet-bridge-us/6885cd8c6963bab90aab7f6f/899e3479db9f13951436e8bf624c968b7a57260caf7fa64555c524585c64485b?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=cas%2F20250815%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20250815T131000Z&X-Amz-Expires=3600&X-Amz-Signature=27977037297e8a3eeacb548456416c6723ba6f7ab889957d7b7de7ff5ced4103&X-Amz-SignedHeaders=host&X-Xet-Cas-Uid=public&response-content-disposition=inline%3B+filename*%3DUTF-8%27%27wan2.2_t2v_lightx2v_4steps_lora_v1.1_high_noise.safetensors%3B+filename%3D%22wan2.2_t2v_lightx2v_4steps_lora_v1.1_high_noise.safetensors%22%3B&x-id=GetObject&Expires=1755267000&Policy=eyJTdGF0ZW1lbnQiOlt7IkNvbmRpdGlvbiI6eyJEYXRlTGVzc1RoYW4iOnsiQVdTOkVwb2NoVGltZSI6MTc1NTI2NzAwMH19LCJSZXNvdXJjZSI6Imh0dHBzOi8vY2FzLWJyaWRnZS54ZXRodWIuaGYuY28veGV0LWJyaWRnZS11cy82ODg1Y2Q4YzY5NjNiYWI5MGFhYjdmNmYvODk5ZTM0NzlkYjlmMTM5NTE0MzZlOGJmNjI0Yzk2OGI3YTU3MjYwY2FmN2ZhNjQ1NTVjNTI0NTg1YzY0NDg1YioifV19&Signature=uwfsTfYhZQzKJ3UILRoKg0y7G5jjNLJVrYv5cykUwNl2aYSIlr51l1mIWxCt76hVZvfok65adhCXeaS4JiXVrWLsO8S0qPDgjAXWByfxrgcfAIHVX%7EFz-z%7EPFVyqG8Y5N5r7r7rosFyn-WcEaTSfsGLFtgMYZYadtJCuuVJcGXqzxQWlMefckt5HOOKvdN0WvEqym56v3XIDSsk7EmYyCfub-iheRSRppUhI4yiBvGowmOVotmvK0UXmOWrMZh437DleArF4PrXeDHIn2Rt6Xa4LoJ2Ljz-CzsOewFRf6xXaKQNOWToLEryBDFME2OkfI366TfdCVzyBfxy30XndnQ__&Key-Pair-Id=K2L8F4GPSG1IFC'

echo "📥 Downloading WAN2.2 LightX2V Low Noise LoRA..."
wget -c --progress=bar:force:noscroll --timeout=300 --tries=3 \
     -O wan2.2_t2v_lightx2v_4steps_lora_v1.1_low_noise.safetensors \
     'https://cas-bridge.xethub.hf.co/xet-bridge-us/6885cd8c6963bab90aab7f6f/eed5ad739eddfb442452b4f43460ff5f226743f9aead1d2102da8851507329c2?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=cas%2F20250815%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20250815T130827Z&X-Amz-Expires=3600&X-Amz-Signature=d6186bfa86676c8c4a1f1f1a5ec502dfc52eddabce5b927be7838e887f4175d2&X-Amz-SignedHeaders=host&X-Xet-Cas-Uid=public&response-content-disposition=inline%3B+filename*%3DUTF-8%27%27wan2.2_t2v_lightx2v_4steps_lora_v1.1_low_noise.safetensors%3B+filename%3D%22wan2.2_t2v_lightx2v_4steps_lora_v1.1_low_noise.safetensors%22%3B&x-id=GetObject&Expires=1755266907&Policy=eyJTdGF0ZW1lbnQiOlt7IkNvbmRpdGlvbiI6eyJEYXRlTGVzc1RoYW4iOnsiQVdTOkVwb2NoVGltZSI6MTc1NTI2NjkwN319LCJSZXNvdXJjZSI6Imh0dHBzOi8vY2FzLWJyaWRnZS54ZXRodWIuaGYuY28veGV0LWJyaWRnZS11cy82ODg1Y2Q4YzY5NjNiYWI5MGFhYjdmNmYvZWVkNWFkNzM5ZWRkZmI0NDI0NTJiNGY0MzQ2MGZmNWYyMjY3NDNmOWFlYWQxZDIxMDJkYTg4NTE1MDczMjljMioifV19&Signature=d%7ENvQagN6uFgynFK6VeuAJ2TL0Ja6-G1aNQuQdhbxc0NDtATgoT6BXQS7lh7tBz2m8W%7EIeY8b5LAk0Cm9obj1M8cAJw5duJ4VP9bcRO%7EJapGbdajj0V7-GeYI5ZRYCjChnTIfsI29xxuRZAN0dUbYHiEnBiPMXf4fFdIS7P4HbP2QPVJbrwDtDMEod9IJ0gueKycWODtKFlPvQpSusCDTQFvJ0U0HSNK0zoSHOPM5pK6gdatJ73Fox3Ctpz4JRR-5Tj7ZnwDps3o3IJ1VIVtmN6L-fxcNNWjO%7E3nSwW2Lj2fwxurWr25pd%7EWQdUJC%7EzDIQYlU0bdezzXN0g-uYEmmw__&Key-Pair-Id=K2L8F4GPSG1IFC'

# WAN2.1 VAE
echo "📥 Downloading WAN2.1 VAE..."
cd ../vae
wget -c --progress=bar:force:noscroll --timeout=300 --tries=3 \
     -O wan_2.1_vae.safetensors \
     'https://cas-bridge.xethub.hf.co/xet-bridge-us/6885cd8c6963bab90aab7f6f/2e358d90f91ce658dc1be053d44cf2d6437e5f517c71ae89fcb2c89fd54ca67e?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=cas%2F20250815%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20250815T132449Z&X-Amz-Expires=3600&X-Amz-Signature=0f915f4124b7d92e514d8f75a7528236667ee980cd7b5ece3cd3b42c81ba9515&X-Amz-SignedHeaders=host&X-Xet-Cas-Uid=public&response-content-disposition=inline%3B+filename*%3DUTF-8%27%27wan_2.1_vae.safetensors%3B+filename%3D%22wan_2.1_vae.safetensors%22%3B&x-id=GetObject&Expires=1755267889&Policy=eyJTdGF0ZW1lbnQiOlt7IkNvbmRpdGlvbiI6eyJEYXRlTGVzc1RoYW4iOnsiQVdTOkVwb2NoVGltZSI6MTc1NTI2Nzg4OX19LCJSZXNvdXJjZSI6Imh0dHBzOi8vY2FzLWJyaWRnZS54ZXRodWIuaGYuY28veGV0LWJyaWRnZS11cy82ODg1Y2Q4YzY5NjNiYWI5MGFhYjdmNmYvMmUzNThkOTBmOTFjZTY1OGRjMWJlMDUzZDQ0Y2YyZDY0MzdlNWY1MTdjNzFhZTg5ZmNiMmM4OWZkNTRjYTY3ZSoifV19&Signature=Ri3dlMpofEqqBO63LN174P3hmbVeokesI7U-ROcxXxmwlZcnblj1qC18zkY1yMbEyJChtVtGgNHpyqoKdQGrRsM7FFJkabUrCaXz%7Ex89xUFSPacMqtnyzRk8sJ0elGN5nNg3KS6Xo0c2Cs1xRVir%7EcKwYSy7dGqUGYxE2ZuYM2ozIASzU1ZG2oepg37KCvets0obpn0-7FHGu%7EaLZ9Zvz7Dm0nfwlbfdXqWXtL1SGsYXiIrCfhKFTzZGTMCtepJ9av%7E%7EZaSo5gfSFRICDNPt5IEMh8VbtkvoNTHCJzRB8cNJqKU9EYGc%7Eaa22zVe58eVmLCqg2d41a9vtvFFs0qZ4Q__&Key-Pair-Id=K2L8F4GPSG1IFC'

# UMT5 Text Encoder
echo "📥 Downloading UMT5 text encoder..."
cd ../text_encoders
wget -c --progress=bar:force:noscroll --timeout=300 --tries=3 \
     -O umt5_xxl_fp8_e4m3fn_scaled.safetensors \
     'https://cas-bridge.xethub.hf.co/xet-bridge-us/67be35b066f702bfed7d3bdc/b94ab462ac11c85e60e2e9bd4045d8eaad6f38186936cb6f8909ca43f6bdd348?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=cas%2F20250815%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20250815T131215Z&X-Amz-Expires=3600&X-Amz-Signature=61169d08fca067519ef3e80959807f4d25b88e57498ae5b50b6391ea163a7666&X-Amz-SignedHeaders=host&X-Xet-Cas-Uid=public&response-content-disposition=inline%3B+filename*%3DUTF-8%27%27umt5_xxl_fp8_e4m3fn_scaled.safetensors%3B+filename%3D%22umt5_xxl_fp8_e4m3fn_scaled.safetensors%22%3B&x-id=GetObject&Expires=1755267135&Policy=eyJTdGF0ZW1lbnQiOlt7IkNvbmRpdGlvbiI6eyJEYXRlTGVzc1RoYW4iOnsiQVdTOkVwb2NoVGltZSI6MTc1NTI2NzEzNX19LCJSZXNvdXJjZSI6Imh0dHBzOi8vY2FzLWJyaWRnZS54ZXRodWIuaGYuY28veGV0LWJyaWRnZS11cy82N2JlMzViMDY2ZjcwMmJmZWQ3ZDNiZGMvYjk0YWI0NjJhYzExYzg1ZTYwZTJlOWJkNDA0NWQ4ZWFhZDZmMzgxODY5MzZjYjZmODkwOWNhNDNmNmJkZDM0OCoifV19&Signature=pQ1Opxx8MIpweHgz1XVCVtD7q06eIQG3f0G4hwUwq4cvJ9pvTMY0t94B1wy9LoXpGjdSynlUb3rcDZzOLejljLi4DL%7EM-fy4ouNNxFVYlrOXHbTf3B9loj91RS0d6HQ1ufLmQTRplNd-KGCgcm4PDCE07tCL3fvRmCVAcKs69mRCiIQwvK3xPfSTBiQMOar0k947V5E5qUUVG8uzeeH1-61Y9zPWUHU8XIlU6qvmeQjfdKe16UdIoRlysAf-J9MrTaGBM0YGAMyAXeDT8zbk%7E4DoS0TnuQZy1X8qRLkN%7EUFT6%7EktNpRbFeRKURqV9O5nVGTKLbfS%7EJJQxvM3JJNtFQ__&Key-Pair-Id=K2L8F4GPSG1IFC'

# Return to ComfyUI root
cd /workspace/ComfyUI

# Copy workflow if provided
if [ -n "$WORKFLOW_FILE" ] && [ -f "/workspace/$WORKFLOW_FILE" ]; then
    echo "📋 Copying workflow file..."
    cp "/workspace/$WORKFLOW_FILE" user/default/workflows/
    echo "✅ Workflow copied successfully"
fi

# Verify downloads
echo "✅ Verifying downloads..."
echo "Diffusion models:"
ls -lh models/diffusion_models/
echo "Text encoders:"
ls -lh models/text_encoders/
echo "VAE:"
ls -lh models/vae/
echo "LoRAs:"
ls -lh models/loras/

echo ""
echo "🎉 Setup completed successfully!"
echo ""
echo "🚀 To start ComfyUI, run:"
echo "cd /workspace/ComfyUI"
echo "python main.py --listen 0.0.0.0 --port $PORT --enable-cors-header"
echo ""
echo "🌐 Then access ComfyUI at: http://YOUR_INSTANCE_IP:$PORT"
echo ""
echo "💡 To run in background:"
echo "nohup python main.py --listen 0.0.0.0 --port $PORT --enable-cors-header > comfyui.log 2>&1 &"
echo ""
echo "📋 To check logs: tail -f comfyui.log"
