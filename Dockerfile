FROM python:3.8.8-slim-buster


#Diretorio padrao Lambda Container
ARG FUNCTION_DIR="/function"
WORKDIR ${FUNCTION_DIR}

#Copiando codigo e dependencias para o treinamento do nosso modelo
COPY requirements.txt ${FUNCTION_DIR}/requirements.txt
COPY train.py ${FUNCTION_DIR}/train.py

#Instalando as dependencias
RUN pip3 install \
    --target ${FUNCTION_DIR} \
    -r requirements.txt

#Treinando o modelo
RUN python3 train.py

#Instalando o Lambda RIC
RUN apt-get update && \
apt-get install -y \
g++ \
make \
cmake \
unzip \
wget \
libcurl4-openssl-dev

RUN pip3 install --target ${FUNCTION_DIR} awslambdaric

# Download Lambda RIE
RUN wget https://github.com/aws/aws-lambda-runtime-interface-emulator/releases/latest/download/aws-lambda-rie -P /usr/local/bin
RUN chmod +x /usr/local/bin/aws-lambda-rie

#Copia dos arquivos de execução
COPY app.py app.py
RUN chmod +x app.py

COPY entry.sh entry.sh
RUN chmod +x entry.sh

ENTRYPOINT ["./entry.sh"]
CMD ["app.handler"]





