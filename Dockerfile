# Definir a imagem base
FROM nvidia/cuda:10.0-cudnn7-devel-ubuntu16.04

SHELL ["/bin/bash", "-c"]

EXPOSE 8888

#Instalar as dependências do sistema
RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install -y tmux
RUN apt-get install -y vim
RUN apt-get install -y git
RUN apt-get install -y wget
RUN apt-get install -y openmpi-bin
# python-qt4 pode dar erro (coisa de pacote velho), tente novamente ou use --fix-missing flag
RUN apt-get install -y python-qt4
RUN rm -rf /var/lib/apt/lists/*

# Instalar o Anaconda
RUN wget https://repo.continuum.io/archive/Anaconda3-4.1.1-Linux-x86_64.sh
RUN bash Anaconda3-4.1.1-Linux-x86_64.sh -b
RUN rm Anaconda3-4.1.1-Linux-x86_64.sh

# Adicionar o Anaconda ao PATH
ENV PATH="/root/anaconda3/bin:${PATH}"

# # Ativar ambiente, não faz diferença (no fim, tem que ativar no bash que inicia)
# RUN source activate root

# Evitar a reconstrução do cache de fontes
ENV MPLCONFIGDIR=/tmp/matplotlib

# # Instalar as bibliotecas necessárias
RUN pip install cntk-gpu

# Definir o diretório de trabalho
WORKDIR /ferplus

# # Copiar os arquivos do diretório atual para o diretório /app no container
COPY . /ferplus

# # Executar os comandos necessários para gerar os dados
# # Também será modificado para gerar/organizar os dados do EmotiNet, AffectNet, KDEF/AKDEF
RUN python3 src/generate_training_data.py -d data/ -fer fer2013.csv -ferplus fer2013new.csv

# # Definir o comando padrão para treinar o modelo
# # Estava dando erro, e também é necessário executar mais do que esse código, sem remover ou reiniciar o container.
# CMD ["python", "src/train.py", "-d", "data/", "-m", "${MODE:-majority}"]

# bash ao final dos comandos pode ser omitido por herança da nvidia

# # Para gerar a imagem
# docker build -t ferplus .

# # Para executar container:
# docker run --name ferplus -it --gpus all -p 8888:8888 -v ~/.ssh:/root/.ssh ferplus

# Rodar jupyter
# jupyter notebook --ip 0.0.0.0 --port 8888

# # Para reexecutar o container
# docker start -p 8888:8888 -v ~/.ssh:/root/.ssh ferplus
# docker exec -it ferplus
