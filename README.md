# GabGPT

## Introducción

Cree este proyecto  para tener centralizados todos los scripts, dockers y configuraciones que utilizar para poder implementar un servicio de hosting LLM local en casa.

Las tecnologías que soportan o para las que está optimizado son:
- CPU AMD Ryzen AI 9 HX 370 - 64 GB RAM
- EGPU Radeon 9070 Xt - 16 GB VRAM  conectada via OCulink
- Ubuntu linux 24.0

## La estructura de carpetas

La carpeta utils es donde están los scripts que instalan las dependencias necesarias para posteriormente instalar todo el tinglado.
La carpeta rocm es donde están los scripts para instalar en tu pc rocm de AMD.
La carpeta all es donde están los instaladores de los servicios de IA.
- Docker: Aqui se guardan los dockers de cada servicio 
- Rocm: Lo necesario para instalar rocm de AMD.
- GabGPT: Aquí se guarda el docker-compose.yml para desplegar la siguiente configuración
    - Llama.cpp: se crea un docker con rocm y se compila Llama.cpp optimizado para la arquitectura.
    - Openwebui: como gui.
    - nginx: como reverse proxy
    - n8n: este servicio no se instala automáticamente si no que se ha de instalar por separado. puede que no lo queramos...
    - opennotelm: Versión open code de notebooklm de google. Está pendiente
    - On-prem: carpeta donde están los scripts que instalan y compilan llama.cpp  sin usar docker.


## Estructura implementada.
### Servicio de búsqueda en la web

Este servicio puede cubrirse mediante la integración de openwebui con searxng en local. Pero se ha optado por utilizar el API de brave search y así "externalizar" este servicio. La elección de Brave es porque ofrece un mínimo de privacidad y ofrecen hasta 1000 peticions gratis al mes ( las 1000 siguientes valen 5$ ). 

Para esto hay que registrarse y solicitar una API key en https://brave.com/search/api/



## TO-DO

- Acabar de refactorizar el código y dejarlo lo más ordenado posible
- Probar la instalación e integración de n8n
- Hacer la instalación de opennotelm.
- Probar a hacer la integración de openwebui con el buscador searxng
- Siempre se puede optimizar más llama.cpp con flags de compilación o variables de entorno...

## Créditos

Autores y colaboradores:
- Gabriel Reus

Hecho con ayuda de IAs.