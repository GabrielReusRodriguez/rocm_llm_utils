#!/bin/env bash

#TODO: Configurar los chat-models y los stops...

# Ejecutamos el servidor
: '
exec /app/llama.cpp/build/bin/llama-server \
    --model "${LLAMACPP_MODEL_2_RUN}" \
    --host 0.0.0.0 \
    --port ${LLAMACPP_CONTAINER_PORT} \
    --mlock \
    --flash-attn on \
    --n-gpu-layers "${GPU_CFG_NUM_GPU_LAYERS}" \
    --ctx-size "${LLAMACPP_MODEL_CTX_SIZE}"
'

#exec /app/llama.cpp/build/bin/llama-cli --list-devices


exec /app/llama.cpp/build/bin/llama-server
