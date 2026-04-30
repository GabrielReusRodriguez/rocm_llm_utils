#!/bin/env bash

: ' 
    Compilación de llama.cpp optimizada. 
    Aquí es donde hay que poner los flags que optimicen la configuración utilizada.
'

: '
    La configuración de este escenario es:
        AMD AI9 HX 370 + 64 GB RAM
        AMD Radeon 9070 XT + 16 GB VRAM
        Ubuntu 24.0
'

: ${LLAMA_CFG_AMDGPU_TARGETS:=gfx1200}
: ${ROCM_PATH:=/opt/rocm}
: ${LD_LIBRARY:=${ROC_PATH}/lib:${LD_LIBRARY_PATH}}


# Compilamos llama.cpp con soporte para ROCm (AMD GPU)
# Añade aquí tus flags personalizadas para el compilador
cmake -S . -B build \
        # Todo lo que vaya con -DGGML son flags para la libreria matematica que usa llama.cpp
        -DGGML_CUDA=OFF \
        -DGGML_HIP=ON \
        -DGGML_HIP_TARGETS=${LLAMA_CFG_AMDGPU_TARGETS} \
        -DGGML_FAST_MATH=ON \
        -DGGML_CUDA_FORCE_MMAP=ON \
        -DGGML_HIP_UMA=OFF \
        -DGGML_NATIVE=ON \
        -DGGML_AVX512=ON \
        -DGGML_AVX512_VBMI=ON \
        -DGGML_AVX512_VNNI=ON \
        -DAMDGPU_TARGETS=${LLAMA_CFG_AMDGPU_TARGETS}    \
#        -DLLAMA_OPENSSL=ON \
#        -DCMAKE_PREFIX_PATH=${ROCM_PATH} \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_C_COMPILER=${ROCM_PATH}/llvm/bin/clang \
        -DCMAKE_CXX_COMPILER=${ROCM_PATH}/llvm/bin/clang++ 

# TODO: en principio el prefix path no deberia ser necesario. probar...

cmake --build build -- -j $(nproc)
