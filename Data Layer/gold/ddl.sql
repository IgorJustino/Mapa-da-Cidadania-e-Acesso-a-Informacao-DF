-- Arquitetura Medalhao: Camada GOLD
-- Projeto: Mapa da Cidadania e Acesso a Informacao no DF

SET timezone = 'America/Sao_Paulo';

CREATE SCHEMA IF NOT EXISTS gold;

DROP TABLE IF EXISTS gold.mart_acesso_informacao CASCADE;
DROP TABLE IF EXISTS gold.mart_indicadores_territoriais CASCADE;
DROP TABLE IF EXISTS gold.fato_mapa_cidadania CASCADE;
DROP TABLE IF EXISTS gold.dim_regiao_administrativa CASCADE;
DROP TABLE IF EXISTS gold.dim_tempo CASCADE;

CREATE TABLE gold.dim_tempo (
    sk_tempo INTEGER PRIMARY KEY,
    ano INTEGER NOT NULL UNIQUE,
    ano_referencia_pdad INTEGER NOT NULL,
    periodo_analise VARCHAR(10) NOT NULL,
    is_ano_referencia_pdad BOOLEAN NOT NULL
);

CREATE TABLE gold.dim_regiao_administrativa (
    sk_regiao_administrativa INTEGER PRIMARY KEY,
    regiao_administrativa VARCHAR(100) NOT NULL UNIQUE,
    chave_regiao_administrativa VARCHAR(100) NOT NULL UNIQUE,
    nivel_territorial VARCHAR(50) NOT NULL,
    uf CHAR(2) NOT NULL
);

CREATE TABLE gold.fato_mapa_cidadania (
    sk_fato_mapa_cidadania INTEGER PRIMARY KEY,
    sk_regiao_administrativa INTEGER NOT NULL
        REFERENCES gold.dim_regiao_administrativa(sk_regiao_administrativa),
    sk_tempo INTEGER NOT NULL
        REFERENCES gold.dim_tempo(sk_tempo),
    ano INTEGER NOT NULL,
    regiao_administrativa VARCHAR(100) NOT NULL,
    ano_referencia_pdad INTEGER NOT NULL,
    populacao_total NUMERIC(18,2),
    populacao_masculina NUMERIC(18,2),
    populacao_feminina NUMERIC(18,2),
    populacao_0_14 NUMERIC(18,2),
    populacao_15_59 NUMERIC(18,2),
    populacao_60_mais NUMERIC(18,2),
    renda_media_ponderada NUMERIC(18,6),
    idade_media_ponderada NUMERIC(18,6),
    media_moradores_por_domicilio NUMERIC(18,6),
    percentual_baixa_escolaridade NUMERIC(10,6),
    percentual_domicilios_com_internet NUMERIC(10,6),
    percentual_domicilios_proprios NUMERIC(10,6),
    percentual_domicilios_alugados NUMERIC(10,6),
    lai_df_qtd_pedidos_ano NUMERIC(18,2),
    lai_df_qtd_recursos_ano NUMERIC(18,2),
    lai_df_qtd_satisfacoes_ano NUMERIC(18,2),
    lai_df_percentual_pedidos_com_recurso NUMERIC(10,6),
    lai_df_tempo_medio_resposta_dias NUMERIC(18,6),
    lai_df_percentual_acesso_concedido NUMERIC(10,6),
    lai_df_percentual_acesso_negado NUMERIC(10,6),
    lai_df_percentual_acesso_parcial NUMERIC(10,6),
    lai_df_percentual_sem_resposta NUMERIC(10,6),
    lai_df_qtd_orgaos_demandados NUMERIC(18,2),
    CONSTRAINT uq_fato_mapa_regiao_tempo
        UNIQUE (sk_regiao_administrativa, sk_tempo)
);

CREATE TABLE gold.mart_indicadores_territoriais (
    sk_regiao_administrativa INTEGER PRIMARY KEY
        REFERENCES gold.dim_regiao_administrativa(sk_regiao_administrativa),
    regiao_administrativa VARCHAR(100) NOT NULL,
    ano_referencia_pdad INTEGER NOT NULL,
    renda_media_ponderada NUMERIC(18,6),
    idade_media_ponderada NUMERIC(18,6),
    media_moradores_por_domicilio NUMERIC(18,6),
    percentual_baixa_escolaridade NUMERIC(10,6),
    percentual_domicilios_com_internet NUMERIC(10,6),
    percentual_domicilios_proprios NUMERIC(10,6),
    percentual_domicilios_alugados NUMERIC(10,6),
    populacao_2023 NUMERIC(18,2),
    populacao_2025 NUMERIC(18,2),
    crescimento_populacional_absoluto NUMERIC(18,6),
    crescimento_populacional_percentual NUMERIC(10,6),
    percentual_populacao_0_14_2025 NUMERIC(10,6),
    percentual_populacao_15_59_2025 NUMERIC(10,6),
    percentual_populacao_60_mais_2025 NUMERIC(10,6)
);

CREATE TABLE gold.mart_acesso_informacao (
    sk_mart_acesso_informacao INTEGER PRIMARY KEY,
    ano INTEGER NOT NULL UNIQUE,
    lai_df_qtd_pedidos_ano NUMERIC(18,2),
    lai_df_qtd_recursos_ano NUMERIC(18,2),
    lai_df_qtd_satisfacoes_ano NUMERIC(18,2),
    lai_df_percentual_pedidos_com_recurso NUMERIC(10,6),
    lai_df_tempo_medio_resposta_dias NUMERIC(18,6),
    lai_df_percentual_acesso_concedido NUMERIC(10,6),
    lai_df_percentual_acesso_negado NUMERIC(10,6),
    lai_df_percentual_acesso_parcial NUMERIC(10,6),
    lai_df_percentual_sem_resposta NUMERIC(10,6),
    lai_df_qtd_orgaos_demandados NUMERIC(18,2)
);

CREATE INDEX idx_gold_fato_tempo
    ON gold.fato_mapa_cidadania(sk_tempo);

CREATE INDEX idx_gold_fato_regiao
    ON gold.fato_mapa_cidadania(sk_regiao_administrativa);

CREATE INDEX idx_gold_mart_territorial_renda
    ON gold.mart_indicadores_territoriais(renda_media_ponderada);

DO $$
BEGIN
    RAISE NOTICE 'Schema GOLD criado com sucesso!';
    RAISE NOTICE '   - Dimensoes: dim_tempo, dim_regiao_administrativa';
    RAISE NOTICE '   - Fato: fato_mapa_cidadania';
    RAISE NOTICE '   - Marts: mart_indicadores_territoriais, mart_acesso_informacao';
END $$;
