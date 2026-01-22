#!/bin/bash

if command -v nvidia-smi >/dev/null 2>&1; then
    util=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits 2>/dev/null | head -n1)
    if [[ "$util" =~ ^[0-9]+$ ]]; then
        echo "$util%"
        exit 0
    fi
fi

if command -v radeontop >/dev/null 2>&1; then
    util=$(radeontop -d - -l 1 2>/dev/null | awk -F, '{for(i=1;i<=NF;i++){if($i~/% gpu/){gsub(/[^0-9.]/,"",$i); print $i; exit}}}')
    if [ -n "$util" ]; then
        echo "${util}%"
        exit 0
    fi
fi

if command -v lspci >/dev/null 2>&1; then
    gpu=$(lspci 2>/dev/null | grep -Ei 'vga|3d|display' | head -n1 | sed -E 's/^.*: //')
    if [ -n "$gpu" ]; then
        echo "$gpu"
        exit 0
    fi
fi

echo "GPU"

