#!/bin/env bash

# Script para compilar e instalar llama.cpp optimizado para ROCm
: '  
    Se optimizan los flags para:
        cpu AMD A9AI HX 370, 64 GB RAM
        eGPU  AMD Radeon 9070 XT 16 GB VRAM
'

# Aquí indicamos que ids de gpu es la que queremos que vea, podemos ver el listado de gpus con rocm-smi y rocminfo (chip ID), la radeon es la 0
AMD_GPU_NUM_DEVICE=0

# Exportamos las variables de entorno necesarias. SI y solo SI no existen.
if [ -z "${HIP_VISIBLE_DEVICES+x}" ]; then
    HIP_VISIBLE_DEVICES=$AMD_GPU_NUM_DEVICE
fi
# Forzamos el uso de memoria Pinned para OCulink.
if [ -z "${GGML_HIP_ALLOC_GRAPH+x}" ]; then
    GGML_HIP_ALLOC_GRAPH=1
fi
# Para forzar la ejecución de la arquitectura RDNA4
if [ -z "${HSA_OVERRIDE_GFX_VERSION+x}" ]; then
    echo 'export HSA_OVERRIDE_GFX_VERSION=12.0.0' >> ~/.bashrc
fi
if [ -z "${ROCM_PATH+x}" ]; then
    echo 'export ROCM_PATH=/opt/rocm' >> ~/.bashrc
    echo 'export LD_LIBRARY_PATH=$ROCM_PATH/lib:$LD_LIBRARY_PATH' >> ~/.bashrc
fi

source ~/.bashrc

# Instalamos las dependencias.
    # Para poder descargar las llms desde consola.
sudo apt -y install libssl-dev

# Clonamos el código de llama.cpp solo la ultima version
git clone --depth 1 https://github.com/ggml-org/llama.cpp.git

cd llama.cpp
: '
    Explicación de los FLAGS:
        -DGGML_CUDA=OFF                 => Le indicamos al compilador que NO usaremos CUDA (redundante al elegir HIP=ON pero porsiacaso) 
        -DGGML_HIP=ON                   => Usaremos HIP ROCm
        -DGGML_HIP_TARGETS=gx1200       => Indicamos la arquitectura que usará la targeta RDNA4  es gx1200 , RDNA3 es gx1100
        -DGGML_HIP_UMA=OFF              => El valor ON es para sistemas que gpu y cpu comparten la memoria. No es el caso.
        -DGGML_FAST_MATH=ON             => Relaja ligeramente la precisión  numérica en favor de una velocidad mucho mayor. En LLMs, la diferencia de calidad es baja
        -DGGML_CUDA_FORCE_MMAP=ON       => Como la conexión es oculink de baja latencia, el mapeo de memoria directo funciona mucho mejor para cargar modelos gigantes rapidamente.
        -DGGML_NATIVE=ON                => activa el parámetro -march=native del compilador genérico (ver mas abajo)
        -DGGML_AVX512=ON                => En aqruitectura Zen 5, acelera las operaciones de inferencia desde la CPU
        -DGGML_AVX512_VBMI=ON           =>
        -DGGML_AVX512_VNNI=ON           => En Zen5 , acelera las inferencias por hardware.
        -DLLAMA_OPENSSL=ON              => Permite indicarle al ejecutable los flags -hf que fuerzan la descarga desde hugginface (Requieren las librerias libssl-dev)
        -DCMAKE_BUILD_TYPE=Release      => Compila en modo Release "Producción" sin simbolos de depuracion y con optimizaciones de nivel -03

    Para optimizar el procesador AMD A9AI HX 370, ( nuestro objetivo es que las capas que no quepan en la GPU vayan más rapidas en la RAM )
    Usamos los siguientes flags:
        
        -DCMAKE_C_FLAGS="-march=native -mtune=native"       => El compilador gcc 13 de ubuntu 24 , detecta automaticamente tu arquitectura Zen 5 y activa las optimizaciones de bajo nivel para el procesador
        -DCMAKE_CXX_FLAGS="-march=native -mtune=native"     => El compilador gxx 13 de ubuntu 24 , detecta automaticamente tu arquitectura Zen 5 y activa las optimizaciones de bajo nivel para el procesador
    Estos dos flags deberian activarse al incluir -DGGML_NATIVE=ON

'

: ' 
    Al ser oculink, recomiendan entrar en la BIOS del pc  y buscar "Resizable BAR" o "Above 4G Decoding" y activarlas.
    El motivo es que OCulink permite que la CPU vea tod laVRAM de la tgta como un solo bloque direccionable . Esto acelera mucho la carga de capas -ngl
'

: '

DUDAS 

'
cmake -S . -B build \
        -DGGML_CUDA=OFF \
        -DGGML_HIP=ON \
        -DGGML_HIP_TARGETS=gx1200 \
        -DGGML_FAST_MATH=ON \
        -DGGML_CUDA_FORCE_MMAP=ON \
        -DGGML_HIP_UMA=OFF \
        -DGGML_NATIVE=ON \
        -DGGML_AVX512=ON \
        -DGGML_AVX512_VBMI=ON \
        -DGGML_AVX512_VNNI=ON \
        -DLLAMA_OPENSSL=ON \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_C_COMPILER=${ROCM_PATH}/llvm/bin/clang \
        -DCMAKE_CXX_COMPILER=${ROCM_PATH}/llvm/bin/clang++ 
        

cmake --build build -- -j $(nproc)
