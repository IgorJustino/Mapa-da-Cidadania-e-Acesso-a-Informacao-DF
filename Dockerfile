# Imagem base do PostgreSQL
FROM postgres:15-alpine

# Informacoes do projeto
LABEL maintainer="Igor Justino"
LABEL description="Banco de dados PostgreSQL para o Mapa da Cidadania e Acesso a Informacao DF"

# Variaveis de ambiente padrao
ENV POSTGRES_DB=mapa_cidadania
ENV POSTGRES_USER=mapa_cidadania_user
ENV POSTGRES_PASSWORD=mapa_cidadania_pass
ENV PYTHONUNBUFFERED=1

RUN apk add --no-cache python3 py3-pip py3-pandas py3-numpy \
    && pip install --no-cache-dir --break-system-packages "psycopg[binary]"

# Copiar scripts DDL para o diretorio de inicializacao do PostgreSQL.
# Scripts sao executados em ordem alfabetica pelo entrypoint oficial.
# RAW Layer: arquivos publicos preservados fora do banco.
# SILVER Layer: BigTable validada em RA + ano.
# GOLD Layer: schema analitico/dimensional preparado para evolucao.
COPY ["Data Layer/silver/ddl.sql", "/docker-entrypoint-initdb.d/01_silver_ddl.sql"]
COPY ["Data Layer/gold/ddl.sql", "/docker-entrypoint-initdb.d/02_gold_ddl.sql"]
COPY ["Data Layer/silver/tb_mapa_cidadania_ra_ano_silver.csv", "/opt/mapa_cidadania/silver/tb_mapa_cidadania_ra_ano_silver.csv"]
COPY ["Data Layer/silver/consultas.sql", "/opt/mapa_cidadania/silver/consultas.sql"]
COPY ["scripts/load_silver.sql", "/docker-entrypoint-initdb.d/03_load_silver.sql"]
COPY ["scripts/validate_silver.sql", "/docker-entrypoint-initdb.d/04_validate_silver.sql"]
COPY ["src", "/opt/mapa_cidadania/src"]
COPY ["scripts/build_gold.py", "/opt/mapa_cidadania/scripts/build_gold.py"]
COPY ["scripts/load_gold.sh", "/docker-entrypoint-initdb.d/05_load_gold.sh"]
COPY ["Data Layer/gold/consultas.sql", "/opt/mapa_cidadania/gold/consultas.sql"]
COPY ["scripts/validate_gold.sql", "/docker-entrypoint-initdb.d/06_validate_gold.sql"]

RUN chmod +x /docker-entrypoint-initdb.d/05_load_gold.sh

# Expor porta padrao do PostgreSQL
EXPOSE 5432
