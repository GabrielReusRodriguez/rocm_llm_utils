# https://rocm.docs.amd.com/projects/install-on-linux/en/latest/how-to/docker.html

# Usamos una imagen base con ROCm (para AMD GPU)
FROM rocm/dev-ubuntu-24.04:latest
# TODO: Probar con rocm/rocm-terminal:latest e instalando las librerias hipblas-dev y rocblas-dev

USER root

ARG URL_LLM
ARG FILE_LLM

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
WORKDIR /app/llama.cpp

# Declaramos unas variables de entorno para la compilacion
ENV ROCM_PATH=/opt/rocm
ENV LD_LIBRARY_PATH=${ROCM_PATH}/lib:${LD_LIBRARY_PATH}

# Compilamos llama.cpp con soporte para ROCm (AMD GPU)
# Añade aquí tus flags personalizadas para el compilador
RUN cmake -S . -B build \
        # Todo lo que vaya con -DGGML son flags para la libreria matematica que usa llama.cpp
        -DGGML_CUDA=OFF \
        -DGGML_HIP=ON \
        -DGGML_HIP_TARGETS=gfx1200 \
        -DGGML_FAST_MATH=ON \
        -DGGML_CUDA_FORCE_MMAP=ON \
        -DGGML_HIP_UMA=OFF \
        -DGGML_NATIVE=ON \
        -DGGML_AVX512=ON \
        -DGGML_AVX512_VBMI=ON \
        -DGGML_AVX512_VNNI=ON \
        -DAMDGPU_TARGETS=gfx1200    \
#        -DLLAMA_OPENSSL=ON \
#        -DCMAKE_PREFIX_PATH=${ROCM_PATH} \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_C_COMPILER=${ROCM_PATH}/llvm/bin/clang \
        -DCMAKE_CXX_COMPILER=${ROCM_PATH}/llvm/bin/clang++ 

# TODO: en principio el prefix path no deberia ser necesario. probar...

RUN cmake --build build -- -j $(nproc)

# Copiamos el modelo (opcional: puedes montarlo como volumen)
RUN wget -O /app/llama.cpp/models/${FILE_LLM} ${URL_LLM}

# Puerto para el servidor de inferencia
EXPOSE 8080

# Declaramos las variables de entorno necesarias para runtime
# Aquí indicamos que ids de gpu es la que queremos que vea, podemos ver el listado de gpus con rocm-smi y rocminfo (chip ID)
ENV HIP_VISIBLE_DEVICES=0
# Forzamos el uso de memoria Pinned para OCulink.
ENV GGML_HIP_ALLOC_GRAPH=1
# Para forzar la ejecución de la arquitectura RDNA4
ENV HSA_OVERRIDE_GFX_VERSION=12.0.0

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
