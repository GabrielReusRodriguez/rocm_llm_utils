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

: '
        Explicacion de los flags
        -DGGML_FAST_MM_F16=ON  Habilita multiplicaciones de matrices rapidas en media precisión. RDNA 3/4 es donde brillan.
        -DGGML_HIPBLAS=ON Activa el soporte para kernels AMD.

'

: ${ROCM_PATH:=/opt/rocm}
: ${LD_LIBRARY:=${ROC_PATH}/lib:${LD_LIBRARY_PATH}}


# Compilamos llama.cpp con soporte para ROCm (AMD GPU)
# Añade aquí tus flags personalizadas para el compilador
# Todo lo que vaya con -DGGML son flags para la libreria matematica que usa llama.cpp
# original
# -DGGML_VULKAN=ON \
# -DGGML_HIP_UMA=OFF
# -DGGML_HIP_VMM= SIN
cmake -S . -B build \
        -DGGML_CUDA=OFF \
        -DGGML_HIP=ON \
        -DGGML_HIPBLAS=ON \
        -DGGML_HIP_TARGETS=${AMDGPU_TARGETS} \
        -DGGML_FAST_MATH=ON \
        -DGGML_FAST_MM_F16=ON \
        -DGGML_CUDA_FORCE_MMAP=ON \
        -DGGML_HIP_UMA=OFF \
	-DGGML_HIP_VMM=ON \
        -DGGML_NATIVE=ON \
        -DGGML_AVX512=ON \
        -DGGML_AVX512_VBMI=ON \
        -DGGML_AVX512_VNNI=ON \
        -DAMDGPU_TARGETS=${AMDGPU_TARGETS}    \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_C_COMPILER=${ROCM_PATH}/llvm/bin/clang \
        -DCMAKE_CXX_COMPILER=${ROCM_PATH}/llvm/bin/clang++ \
        -DCMAKE_CXX_FLAGS="-O3 -march=native -flto  -cl-denorms-are-zero -mllvm -amdgpu-early-inline-all=true -mllvm -amdgpu-function-calls=false"


# TODO: en principio el prefix path no deberia ser necesario. probar...

cmake --build build -- -j $(nproc)
