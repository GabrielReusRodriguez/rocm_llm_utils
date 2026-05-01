#!/bin/env bash

# Con esta instrucción ejecuto el docker que servirá la API para via web.

# En que carpeta está el modelo?
#: ${HOST_MODELS_FOLDER:='/home/gabriel/Downloads'}
# Cual es el nombre del fichero del modelo?
#: ${MODEL_FILE:='Qwen3-14B-Q5_K_M.gguf'}
# Puerto que expone el docker.
#: ${DOCKER_PORT:=8080}
# Puerto que ofrecemos hacia afuera (mapea el docker_port)
#: ${HOST_PORT:=8080}
# Número de capas que ejecutará la GPU 
#: ${LLM_NUMBER_GPU_LAYERS:=99}
# Tamaño del contexto
#: ${LLM_CONTEXT_SIZE:=4096}
# Nombre de la imagen Docker que usaremos.
#: ${DOCKER_IMAGE_NAME:='llama-cpp-qwen'}

: '
    Los parámetros utilizados son:
        -it => 
                -i : le indicamos que dejamos el STDIN abierto para pasarle texto por pipe
                -t : reservamos un terminal tty
        --detach    => Ejecuta  el contenedor en background.
        --rm        => Elimina automáticament el contenedor y sus volumenes anónimos cuando sale.
        --device    => Le añadimos un dispositivo del host al docker ( en este caso la tjta gráfica)
        --group-add => Añadimos grups adiicionales del host
        --ipc=host  => La comuncación entre procesos será con memoria compartida con el host. 
        --shm-size  => Define el tamaño de memoria compartida asignada al contenedor. Por defecto docker asigna 64 MB
                            Lo que le pasamos es la memoria MAXIMA que puede pillar la gpu de la unidad /dev/shm (sistema de ficheros montado en ram)
        --publish   => puerto compartido de docker lo mapeamos al puerto del host...
        --volume    => Mapeamos la carpeta del host a la carpeta del docker.
        --env       => Definimos variables de entorno DENTRO del docker.



        probar con --gpus

'


docker run -it                  \
        --detach                \
        --rm                    \
        --name llama-cpp-qwen3  \
        --device=/dev/kfd       \
        --device=/dev/dri       \
        --group-add video       \
        --ipc=host              \
        --shm-size 8g           \
        --publish   ${DOCKER_GUEST_PORT}:${DOCKER_HOST_PORT}   \
#        --volume ${HOST_MODELS_FOLDER}/${MODEL_FILE}:/app/llama.cpp/models/${MODEL_FILE}    \
        --env  MODEL_PATH=${LLAMA_LLM_MODEL_PATH}  \
        --env  N_GPU_LAYERS=${LLAMA_GPU_CFG_NUM_GPU_LAYERS} \
        --env  CTX_SIZE=${LLAMA_LLM_CTX_SIZE}   \
        ${LLAMA_DOCKER_IMG_NAME}

# Si descargamos el modelo en la Dockerfile no hace falta montar el volumen.