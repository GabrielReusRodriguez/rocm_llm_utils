#!/bin/env bash

# Servidor, puerto de escucha
#: ${HOST_PORT:=8080}
# Indicamos el número de threads
#: ${SERVER_CPU_NUM_THREADS:=12}

# Indicamos la ruta al modelo
#: ${LLAMA_MODEL_PATH:='/app/llama.cpp/models/Qwen3-14B-Q5_K_M.gguf'}
# El número de capas
#: ${LLAMA_N_GPU_LAYERS:=50}
# Indicamos el tamaño de contexto.
#: ${LLAMA_CTX_SIZE:=4096}


#TODO: Configurar los chat-models y los stops...

# Ejecutamos el servidor
exec /app/llama.cpp/build/bin/llama-server \
    --model "${LLAMA_LLM_MODEL_PATH}" \
    #--host 0.0.0.0 \
    --host 127.0.0.1 \
    --port ${LLAMA_DOCKER_CONTAINER_PORT} \
    --mlock \
    --flash-attn on \
    --n-gpu-layers "${LLAMA_GPU_CFG_NUM_GPU_LAYERS}" \
    --ctx-size "${LLAMA_LLM_CTX_SIZE}"
