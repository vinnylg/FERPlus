# Definir a imagem base
FROM nvidia/cuda:10.0-cudnn7-devel-ubuntu16.04

#Instalar as dependências do sistema
RUN apt-get update && \
    apt-get install -y wget openmpi-bin python-qt4 && \
    rm -rf /var/lib/apt/lists/*

# Instalar o Anaconda
RUN wget https://repo.continuum.io/archive/Anaconda3-4.1.1-Linux-x86_64.sh && \
    bash Anaconda3-4.1.1-Linux-x86_64.sh -b && \
    rm Anaconda3-4.1.1-Linux-x86_64.sh

# Adicionar o Anaconda ao PATH
ENV PATH="/root/anaconda3/bin:${PATH}"

# # Ativar ambiente
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
