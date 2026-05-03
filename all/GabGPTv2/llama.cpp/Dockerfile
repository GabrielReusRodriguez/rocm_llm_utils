# https://rocm.docs.amd.com/projects/install-on-linux/en/latest/how-to/docker.html

# Usamos una imagen base con ROCm (para AMD GPU)
#FROM rocm/dev-ubuntu-24.04:latest
FROM rocm/rocm-terminal:latest

USER root

# Para que Dockerfile reciba las variables del docker-compose.yml
ARG LLM_FILE
ARG LLM_URL

# Instalamos dependencias necesarias y borramos el almacen temporal de apt /var/lib/lists/*
RUN apt-get update && apt-get install -y \
    git \
    cmake \
    build-essential \
    hipblas-dev     \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Clonamos el repositorio de llama.cpp
WORKDIR /app
RUN git clone --depth 1 https://github.com/ggml-org/llama.cpp.git

# Copiamos los scripts auxiliares
WORKDIR /app/scripts
COPY ./scripts/llama_optimized_compilation.sh /app/scripts/llama_optimized_compilation.sh
RUN chmod +x /app/scripts/llama_optimized_compilation.sh

# Declaramos las variables de entorno para compilar
#ENV ROCM_PATH=/opt/rocm
#ENV LD_LIBRARY_PATH:=${ROCM_PATH}/lib:${LD_LIBRARY_PATH}

#  Compilamos llama.cpp con los flags optimizados.
WORKDIR /app/llama.cpp
RUN /app/scripts/llama_optimized_compilation.sh

# Cramos la carpeta
RUN mkdir -p /app/llama.cpp/models

# Copiamos el modelo (opcional: puedes montarlo como volumen)
ENV LLAMA_LLM_MODEL_PATH="/app/llama.cpp/models/${LLM_FILE}"
RUN wget -O $LLAMA_LLM_MODEL_PATH ${LLM_URL}

COPY ./scripts/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

