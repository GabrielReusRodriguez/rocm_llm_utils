#!/bin/env bash

: ${LLM_DOCKER_CONTAINER_NAME:='llama-cpp-qwen'}

docker build \
        --build-arg URL_LLM = 'https://huggingface.co/Qwen/Qwen3-14B-GGUF/resolve/main/Qwen3-14B-Q5_K_M.gguf?download=true'  \
        --build-arg FILE_LLM = 'Qwen3-14B-Q5_K_M.gguf'
        -t ${LLM_DOCKER_CONTAINER_NAME}