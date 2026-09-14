#!/bin/sh
set -e

echo "Detecting GPU"

GPU=$(lspci -v | grep -A 12 -i "VGA\|3D")

if echo "$GPU" | grep -iq "nvidia"; then
    echo "Nvidia GPU detected"
    sudo pacman -S --noconfirm --needed --needed ollama-cuda

    VRAM=$(nvidia-smi --query-gpu=memory.total --format=csv,noheader,nounits | awk '{print int($1/1024)}')
elif echo "$GPU" | grep -iq "amd"; then
    echo "AMD GPU detected"
    sudo pacman -S --noconfirm --needed --needed ollama-rocm

    BYTES=$(cat /sys/class/drm/card*/device/mem_info_vram_total)
    VRAM=$(( BYTES / 1024 / 1024 / 1024 ))
elif echo "$GPU" | grep -iq "intel"; then
    sudo pacman -S --noconfirm --needed --needed ollama-vulkan

    if [ -f /sys/class/drm/card0/device/lmem_total_bytes ]; then
        echo "Intel Discrete GPU detected"

        BYTES=$(cat /sys/class/drm/card0/device/lmem_total_bytes)
        VRAM=$(( BYTES / 1024 / 1024 / 1024 ))
    else
        echo "Intel Integrated GPU detected"
        KB=$(grep MemTotal /proc/meminfo | awk '{print $2}')
        GB=$(( KB / 1024 / 1024 ))

        VRAM=$(( GB / 2 ))
    fi
else
    echo "No AI supported GPU detected"
    sudo pacman -S --noconfirm --needed --needed ollama

    VRAM=0
fi

echo "Enabling and starting Ollama service..."
sudo systemctl enable --now ollama

echo "Waiting for Ollama API daemon to respond..."
until curl -s http://localhost:11434/api/tags > /dev/null; do
    sleep 1
done

if [ "$VRAM" -ge 15 ]; then
    echo "VRAM is $VRAM GB, using high-performance mode"
    ollama pull qwen2.5-coder:14b
    ollama pull qwen2.5-coder:7b
elif [ "$VRAM" -ge 8 ]; then
    echo "VRAM is $VRAM GB, using middle mode"
    ollama pull qwen2.5-coder:7b
else
    echo "VRAM is $VRAM GB, using standard mode"
    ollama pull qwen2.5-coder:1.5b
fi
