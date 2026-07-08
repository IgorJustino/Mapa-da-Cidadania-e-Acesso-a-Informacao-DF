CREATE SCHEMA IF NOT EXISTS silver;

DROP TABLE IF EXISTS silver.tb_mapa_cidadania_ra_ano_silver;

CREATE TABLE silver.tb_mapa_cidadania_ra_ano_silver (
    ano INTEGER NOT NULL,
    regiao_administrativa TEXT NOT NULL,

    populacao_total NUMERIC,
    populacao_masculina NUMERIC,
    populacao_feminina NUMERIC,
    populacao_0_14 NUMERIC,
    populacao_15_59 NUMERIC,
    populacao_60_mais NUMERIC,

    renda_media_ponderada NUMERIC,
    idade_media_ponderada NUMERIC,
    media_moradores_por_domicilio NUMERIC,
    percentual_baixa_escolaridade NUMERIC,
    percentual_domicilios_com_internet NUMERIC,
    percentual_domicilios_proprios NUMERIC,
    percentual_domicilios_alugados NUMERIC,

    CONSTRAINT pk_tb_mapa_cidadania_ra_ano_silver
        PRIMARY KEY (regiao_administrativa, ano)
);
