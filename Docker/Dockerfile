# https://rocm.docs.amd.com/projects/install-on-linux/en/latest/how-to/docker.html

# Usamos una imagen base con ROCm (para AMD GPU)
#FROM rocm/dev-ubuntu-24.04:latest
FROM rocm/rocm-terminal:latest

USER root

ARG LLM_URL
ARG LLM_FILE

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
ENV ROCM_PATH=/opt/rocm
ENV LD_LIBRARY_PATH:=${ROCM_PATH}/lib:${LD_LIBRARY_PATH}

#  Compilamos llama.cpp con los flags optimizados.
WORKDIR /app/llama.cpp
RUN /app/scripts/llama_optimized_compilation.sh

# Puerto para el servidor de inferencia
EXPOSE 8080

# Declaramos las variables de entorno necesarias para runtime
# Aquí indicamos que ids de gpu es la que queremos que vea, podemos ver el listado de gpus con rocm-smi y rocminfo (chip ID)
ENV HIP_VISIBLE_DEVICES=0
# Forzamos el uso de memoria Pinned para OCulink.
ENV GGML_HIP_ALLOC_GRAPH=1
# Para forzar la ejecución de la arquitectura RDNA4
ENV HSA_OVERRIDE_GFX_VERSION=12.0.0

# Copiamos el modelo (opcional: puedes montarlo como volumen)
RUN wget -O /app/llama.cpp/models/${LLM_FILE} ${LLM_URL}

COPY ./scripts/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

