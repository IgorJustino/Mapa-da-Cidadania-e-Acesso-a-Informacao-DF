# Modelo da Camada Gold

## Tabelas

- `dim_tempo`: 1 linha = 1 ano do período analisado.
- `dim_regiao_administrativa`: 1 linha = 1 Região Administrativa canônica.
- `fato_mapa_cidadania`: 1 linha = 1 Região Administrativa + 1 ano.
- `mart_indicadores_territoriais`: 1 linha = 1 Região Administrativa.
- `mart_acesso_informacao`: 1 linha = Distrito Federal + 1 ano.

## Carga

O ETL Silver -> Gold constroi os DataFrames em memoria e carrega diretamente
nas tabelas `gold.*` do PostgreSQL via `COPY FROM STDIN`.

A pasta `Data Layer/gold/` deve conter apenas artefatos de definicao e consumo
SQL (`ddl.sql` e `consultas.sql`). Arquivos CSV/parquet da Gold sao artefatos
gerados e nao devem ser salvos no repositorio.

## mart_indicadores_territoriais

Granularidade: 1 linha = 1 Região Administrativa.

O mart utiliza:

- indicadores socioeconômicos da PDAD-A 2024 como fotografia territorial de referência;
- população de 2023 e 2025;
- crescimento populacional absoluto e percentual entre 2023 e 2025;
- percentuais da população por faixa etária em 2025.

Ele não calcula índice composto. A decisão evita pesos arbitrários antes de uma metodologia explícita.

## mart_acesso_informacao

Granularidade: 1 linha = Distrito Federal + ano.

Este mart transforma a repetição necessária da Silver em uma tabela analítica anual:

- 2023: 1 linha;
- 2024: 1 linha;
- 2025: 1 linha.

Não há `fato_lai_df_ano` separada porque, no escopo atual, ela apenas duplicaria os mesmos três registros do mart.
