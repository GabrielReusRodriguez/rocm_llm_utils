#/bin/env bash

# Ejemplo de  ejecución de un modelo con los flags de optimización.
: '
    Los flags que optimizan la ejecución de llama.cpp en un sistema
        - AMD AI9 HX 370 64 GB
        - EGPU Radeon 9070 con 16 GB VRAM
    son:
        --n-gpu-layers  : Define cuantas capas del modelo se cargan en la GPU si es alto, 99 se intenta forzar todo en la GPU
        --flash-attn    : OBLIGATORIO reduce drastimante el uso de VRAM durane el procesamiento de contexto.
        --mlock         : bloquea la memoria par evitar que el sistema la mueva al disco swap.
        --chat-template : chatml => para frenar los <|im_end|> los modelso se preparan para el formato de cat especifico ChatML 
                            pueden ser  
                                    chatml => <|im_start|> como qwen Yi  o Hermes
                                    llama3
                                    mistral-v1
                                    gemma (google)
                            PAra los modelos .gguf, se sabe que modelo usa 
                                si dice Qwen , Hermes o ChatML => usamos chatml
                                si dice Llama-3 => usamos llama3
                                si dice instruct y es de Mistral => usamos mistral-v1
        Stop tokens de chatml
            --chat-template : chatml
            --stop "<|im_start|>" : Pese a incluir  el template, a veces el modelo sigue, hay que configurar los tokens de parada para que corte la generacion.
            --stop "<|im_end|>"
            --stop "<|endoftext|>"
        
        Stop tokens de llama3
            --chat-template : llama3
            --stop "<|eot_id|>"
            --stop "<|end_of_text|>"
            --stop "<|start_header_id|>"
        
        Stop tokens de mistral-v1 (Instruct)
            --chat-template : mistral-v1
            --stop "[INST]"
            --stop "[/INST]"
            --stop "</s>"
        
        Stop tokens de gemma
            --chat-template : gemma
            --stop "<end_of_turn>"
            --stop "<start_of_turn>"


        # Para cpu...
        --numa distribute : optimiza como se reparten los datos en los 64  GB de la cepu
        --prio 3        : eleva la prioridad del proceso.
        -C 4            : Context shift ayer a que la cpu gestione mejor el contexto cuando el modelo es muy grande
        --split-mode    : Controla como se divide el modelo Usamos con none o row .  Lo ideal es evitar que la CPU intervenga  si el modelo cabe en la VRAM.
        --threads       : Hilos de cpu para las capas que no quepan en la eGPU. normalmente 8 o 12.

    Ejemplos:
        Caso A: el modelo cabe en la eGPU
            ./llama-cli -m modelo.gguf \
                    --n-gpu-layers 99 \
                    --flash-attn on\
                    --mlock \
                    --threads 8
                    --ctx-size 8192 o -c
        
        Caso B: el modelo NO cabe en la eGPU
            ./llama-cli -m modelo_70b.gguf \
                    --n-gpu-layers  40 \
                    --flash-attn on\
                    --mlock \
                    --threads 12 \
                    --ctx-size 4096 o -c

    Como es una EGPU , recomiendan no usar contexto extremadamente altos ya que hay que evitar el intercambio de datos por el cable ( oculink funcionará algo mejor)
    Cuantización:
        Con una radeon 9070 xt 16 GB lo ideal serían los modelos Q5_K_M o Q6_K aunque si se quiere más contexto los Q4_K_M

    En el caso de la configuración comentada, se recomienda una ejecución:
    ./llama-cli -m llama3-70b-q4.gguf  \
        --n-gpu-layers 32 \
        --flash-attn \
        --threads 12 \
        --split-mode row \
        --mlock \
        --ctx-size 8192

'
echo 'Hola'

