# ComfyUI Vast.AI Deployment

Simple deployment script to automatically set up ComfyUI on Vast.AI instances with all necessary models for FLUX.1-Krea and WAN2.2 text-to-video workflows.

## 🚀 Quick Start

### Prerequisites

1. **Vast.AI Instance**: Rent a GPU instance at [vast.ai](https://vast.ai/)
   - Recommended: RTX 4090, RTX 3090, A6000 or better
   - Minimum: 12GB VRAM, 16GB RAM, 60GB storage
2. **SSH Access**: Ensure you can SSH to your instance
3. **Hugging Face Token**: Get a token from [huggingface.co/settings/tokens](https://huggingface.co/settings/tokens)

### Installation

1. **Rent a Vast.AI instance** with sufficient specs
2. **SSH to your instance**:
   ```bash
   ssh root@<instance_ip> -p <port>
   ```
3. **Download the setup script**:
   ```bash
   cd /workspace
   wget https://raw.githubusercontent.com/your-repo/setup_comfyui_direct.sh
   chmod +x setup_comfyui_direct.sh
   ```
4. **Run the setup**:
   ```bash
   ./setup_comfyui_direct.sh
   ```
   - The script will prompt for your Hugging Face token
   - Enter your token when prompted
   - Wait for setup to complete (~45GB download)

5. **Start ComfyUI**:
   ```bash
   cd /workspace/ComfyUI
   python main.py --listen 0.0.0.0 --port 8188 --enable-cors-header
   ```

6. **Access ComfyUI**: Open `http://<your_instance_ip>:8188` in your browser

## 🛠️ What the Script Does

1. **System Setup**:
   - Updates packages and installs dependencies
   - Installs Git, wget, curl, Python packages

2. **ComfyUI Installation**:
   - Clones ComfyUI from GitHub
   - Installs Python requirements
   - Creates model directory structure

3. **Model Downloads** (~45 GB total):
   - **FLUX.1-Krea Diffusion Model** (11.9 GB)
   - **WAN2.2 T2V High Noise Model** (14 GB)
   - **WAN2.2 T2V Low Noise Model** (14 GB)
   - **Text Encoders**: CLIP, T5, UMT5 (5+ GB total)
   - **VAE Models**: Standard and WAN2.1 VAE
   - **LoRA Models**: WAN2.2 LightX2V optimizations

4. **Authentication**:
   - Securely prompts for Hugging Face token
   - Sets up authentication for model downloads

## � Complete Model Suite

| Model Type | File | Size | Purpose |
|------------|------|------|---------|
| **FLUX Models** | | | |
| Diffusion | `flux1-krea-dev_fp8_scaled.safetensors` | 11.9 GB | Main image generation |
| **WAN2.2 T2V Models** | | | |
| Diffusion | `wan2.2_t2v_high_noise_14B_fp8_scaled.safetensors` | 14 GB | Text-to-video (high noise) |
| Diffusion | `wan2.2_t2v_low_noise_14B_fp8_scaled.safetensors` | 14 GB | Text-to-video (low noise) |
| LoRA | `wan2.2_t2v_lightx2v_4steps_lora_v1.1_high_noise.safetensors` | Small | 4-step optimization |
| LoRA | `wan2.2_t2v_lightx2v_4steps_lora_v1.1_low_noise.safetensors` | Small | 4-step optimization |
| **Text Encoders** | | | |
| CLIP | `clip_l.safetensors` | 0.25 GB | Text understanding |
| T5 | `t5xxl_fp16.safetensors` | 4.7 GB | Advanced text processing |
| UMT5 | `umt5_xxl_fp8_e4m3fn_scaled.safetensors` | Variable | Enhanced text encoding |
| **VAE Models** | | | |
| Standard | `ae.safetensors` | 0.33 GB | Image encoding/decoding |
| WAN2.1 | `wan_2.1_vae.safetensors` | Variable | Video-optimized VAE |

**Total Download Size: ~45 GB**

## 🖥️ Recommended Instance Specifications

### Minimum Requirements
- **GPU**: RTX 3080 (10GB VRAM)
- **RAM**: 16 GB
- **Storage**: 60 GB SSD
- **Network**: Stable connection for downloads

### Recommended Specifications
- **GPU**: RTX 4090, RTX 3090, A6000, A100
- **VRAM**: 16+ GB (24GB+ for best performance)
- **RAM**: 32+ GB
- **Storage**: 100+ GB NVMe SSD
- **Network**: High bandwidth for faster downloads

## 🔧 Usage Instructions

### Starting ComfyUI Server

**Foreground (see output):**
```bash
cd /workspace/ComfyUI
python main.py --listen 0.0.0.0 --port 8188 --enable-cors-header
```

**Background (detached):**
```bash
cd /workspace/ComfyUI
nohup python main.py --listen 0.0.0.0 --port 8188 --enable-cors-header > comfyui.log 2>&1 &
```

**Check background process:**
```bash
tail -f /workspace/ComfyUI/comfyui.log
```

### Accessing ComfyUI

1. **Web Interface**: `http://<instance_public_ip>:8188`
2. **Load Workflows**: Drag and drop JSON files or use the Load button
3. **Model Selection**: Choose appropriate models for your workflow type

## 🎯 Model Usage Guide

### For Image Generation (FLUX.1-Krea)
- **Diffusion Model**: `flux1-krea-dev_fp8_scaled.safetensors`
- **Text Encoders**: `clip_l.safetensors`, `t5xxl_fp16.safetensors`
- **VAE**: `ae.safetensors`

### For Text-to-Video (WAN2.2)
- **Diffusion Model**: Choose high or low noise variant
- **Text Encoder**: `umt5_xxl_fp8_e4m3fn_scaled.safetensors`
- **VAE**: `wan_2.1_vae.safetensors`
- **LoRA**: Use LightX2V models for 4-step generation

## 🔧 Troubleshooting

### Setup Issues

**Script fails to download models:**
- Check your Hugging Face token permissions
- Verify internet connection
- Check available storage space

**Permission denied:**
```bash
chmod +x setup_comfyui_direct.sh
```

**Out of storage:**
- Choose instance with more disk space
- Clean temporary files: `rm -rf /tmp/*`

### Runtime Issues

**ComfyUI won't start:**
```bash
# Check Python path
which python
python --version

# Check dependencies
pip list | grep torch

# Check model files
ls -lh /workspace/ComfyUI/models/*/
```

**Out of memory errors:**
- Use smaller batch sizes
- Choose instance with more VRAM
- Use FP8 quantized models when available

**Server not accessible:**
- Verify instance public IP: `curl ifconfig.me`
- Check firewall settings
- Ensure port 8188 is open

### Manual Verification

```bash
# Check ComfyUI installation
ls -la /workspace/ComfyUI/

# Verify all models downloaded
find /workspace/ComfyUI/models -name "*.safetensors" -ls

# Check server process
ps aux | grep python

# Monitor logs
tail -f /workspace/ComfyUI/comfyui.log
```

## 🔒 Security Best Practices

- Never share your Hugging Face token
- Use SSH key authentication when possible
- Monitor instance costs and usage
- Terminate instances when not in use
- Keep your token secure and private

## 📁 File Structure After Setup

```
/workspace/ComfyUI/
├── main.py                     # ComfyUI main application
├── models/
│   ├── diffusion_models/       # FLUX and WAN2.2 models
│   ├── text_encoders/          # CLIP, T5, UMT5 encoders
│   ├── vae/                    # VAE models
│   ├── loras/                  # LoRA optimization models
│   └── ...
├── user/default/workflows/     # Workflow files
└── ...
```

## 📚 Additional Resources

- [ComfyUI Documentation](https://github.com/comfyanonymous/ComfyUI)
- [Vast.AI Getting Started](https://vast.ai/docs/getting-started)
- [FLUX.1 Model Card](https://huggingface.co/black-forest-labs/FLUX.1-dev)
- [ComfyUI Workflows](https://comfyworkflows.com/)
- [Hugging Face Tokens](https://huggingface.co/docs/hub/security-tokens)

## 🤝 Support

If you encounter issues:
1. Check the troubleshooting section above
2. Verify your instance specifications meet requirements
3. Ensure your Hugging Face token has proper permissions
4. Check ComfyUI logs for specific error messages

---

**Note**: This setup downloads approximately 45GB of models. Ensure your Vast.AI instance has sufficient storage and bandwidth. Model downloads may take 30-60 minutes depending on connection speed.
   - Configure ComfyUI settings

5. **Server Launch**:
   - Start ComfyUI server
   - Display access URL and connection info

## 💾 Models Included

The scripts automatically download all models required for the FLUX.1-Krea workflow:

| Model Type | File | Size | Purpose |
|------------|------|------|---------|
| Diffusion | `flux1-krea-dev_fp8_scaled.safetensors` | 11.9 GB | Main image generation model |
| Text Encoder | `clip_l.safetensors` | 0.25 GB | Text understanding |
| Text Encoder | `t5xxl_fp16.safetensors` | 4.7 GB | Advanced text processing |
| VAE | `ae.safetensors` | 0.33 GB | Image encoding/decoding |
| Checkpoint | `v1-5-pruned-emaonly-fp16.safetensors` | 4.3 GB | Stable Diffusion 1.5 model |

**Total Download Size: ~21.5 GB**

## 🖥️ Recommended Instance Specifications

For optimal performance with FLUX.1-Krea:

- **GPU**: RTX 4090, RTX 3090, A6000, or better
- **VRAM**: Minimum 12 GB (16+ GB recommended)
- **RAM**: 16+ GB
- **Storage**: 50+ GB SSD
- **Network**: Good bandwidth for model downloads

## 📁 File Structure

```
ComfyUI Deployment/
├── deploy_comfyui_vast.py      # Main Python deployment script
├── deploy_comfyui_vast.sh      # Bash script for Linux/Mac
├── deploy_comfyui_vast.ps1     # PowerShell script for Windows
├── config.py                   # Configuration settings
├── requirements.txt            # Python dependencies
├── flux1_krea_dev.json        # Example workflow file
└── README.md                   # This file
```

## ⚙️ Configuration

Edit `config.py` to customize:
- Model URLs and requirements
- ComfyUI settings
- Deployment timeouts
- Custom nodes to install

## 🔧 Troubleshooting

### Common Issues

1. **SSH Connection Failed**
   - Ensure your Vast.AI instance is running
   - Check if SSH is enabled on the instance
   - Verify your SSH key configuration

2. **Model Download Timeout**
   - Increase timeout values in config
   - Check instance internet speed
   - Use resume-capable wget commands

3. **Out of Memory**
   - Choose instance with more VRAM/RAM
   - Use FP8 quantized models when available
   - Reduce batch size in workflows

4. **ComfyUI Won't Start**
   - SSH to instance and check logs: `tail -f /root/ComfyUI/comfyui.log`
   - Verify all models downloaded correctly
   - Check Python dependencies

### Manual Verification

SSH to your instance and check:

```bash
# Check ComfyUI installation
ls -la /root/ComfyUI/

# Check models
ls -lh /root/ComfyUI/models/*/

# Check server status  
ps aux | grep python

# View logs
tail -f /root/ComfyUI/comfyui.log
```

## 🌐 Accessing ComfyUI

After successful deployment:

1. **Web Interface**: `http://<instance_public_ip>:8188`
2. **Load Workflow**: Drag and drop the JSON file or use Load button
3. **Generate Images**: Queue prompt and wait for results

## 🔒 Security Notes

- Change default passwords if any
- Consider using SSH key authentication
- Limit access to ComfyUI port if needed
- Monitor instance costs and usage

## 📝 License

This project is provided as-is for educational and development purposes. Please respect the licenses of ComfyUI and the individual models.

## 🤝 Contributing

Feel free to submit issues, improvements, or additional workflow configurations!

## 📚 Additional Resources

- [ComfyUI Documentation](https://github.com/comfyanonymous/ComfyUI)
- [Vast.AI Documentation](https://vast.ai/docs/)
- [FLUX.1 Model Information](https://huggingface.co/black-forest-labs/FLUX.1-dev)
- [ComfyUI Workflows](https://comfyworkflows.com/)
