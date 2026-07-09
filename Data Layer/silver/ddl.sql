-- Arquitetura Medalhão: Camada SILVER
-- Projeto: Mapa da Cidadania e Acesso à Informação no DF

-- Configurações iniciais
SET timezone = 'America/Sao_Paulo';

CREATE SCHEMA IF NOT EXISTS silver;

-- Drop da tabela se existir
DROP TABLE IF EXISTS silver.tb_mapa_cidadania_ra_ano_silver CASCADE;

-- Esta tabela integra dados tratados da PDAD-A 2024,
-- Projeções Populacionais 2020-2030 e indicadores anuais de LAI no DF.
--
-- Granularidade:
-- 1 linha = 1 Região Administrativa + 1 ano
--
-- Observação metodológica:
-- A LAI não possui campo territorial confiável de Região Administrativa.
-- Por isso, seus indicadores são agregados no nível Distrito Federal + ano
-- e identificados com o prefixo lai_df_.

CREATE TABLE silver.tb_mapa_cidadania_ra_ano_silver (

    -- IDENTIFICADORES E TEMPO
    ano INTEGER NOT NULL,
    regiao_administrativa VARCHAR(100) NOT NULL,
    ano_referencia_pdad INTEGER NOT NULL,

    -- INDICADORES POPULACIONAIS
    populacao_total NUMERIC(18,2),
    populacao_masculina NUMERIC(18,2),
    populacao_feminina NUMERIC(18,2),
    populacao_0_14 NUMERIC(18,2),
    populacao_15_59 NUMERIC(18,2),
    populacao_60_mais NUMERIC(18,2),

    -- INDICADORES SOCIOECONÔMICOS - PDAD-A 2024
    renda_media_ponderada NUMERIC(18,6),
    idade_media_ponderada NUMERIC(18,6),
    media_moradores_por_domicilio NUMERIC(18,6),
    percentual_baixa_escolaridade NUMERIC(10,6),
    percentual_domicilios_com_internet NUMERIC(10,6),
    percentual_domicilios_proprios NUMERIC(10,6),
    percentual_domicilios_alugados NUMERIC(10,6),

    -- INDICADORES ANUAIS DE LAI - DISTRITO FEDERAL
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

    -- CHAVE PRIMÁRIA
    CONSTRAINT pk_tb_mapa_cidadania_ra_ano_silver
        PRIMARY KEY (regiao_administrativa, ano)
);

-- ÍNDICES PARA PERFORMANCE

CREATE INDEX idx_silver_mapa_ano
    ON silver.tb_mapa_cidadania_ra_ano_silver(ano);

CREATE INDEX idx_silver_mapa_regiao_administrativa
    ON silver.tb_mapa_cidadania_ra_ano_silver(regiao_administrativa);

CREATE INDEX idx_silver_mapa_populacao_total
    ON silver.tb_mapa_cidadania_ra_ano_silver(populacao_total);

CREATE INDEX idx_silver_mapa_renda_media
    ON silver.tb_mapa_cidadania_ra_ano_silver(renda_media_ponderada);

CREATE INDEX idx_silver_mapa_lai_pedidos_ano
    ON silver.tb_mapa_cidadania_ra_ano_silver(lai_df_qtd_pedidos_ano);

-- MENSAGEM DE SUCESSO

DO $$
BEGIN
    RAISE NOTICE 'Schema SILVER criado com sucesso!';
    RAISE NOTICE '   - Tabela silver.tb_mapa_cidadania_ra_ano_silver';
    RAISE NOTICE '   - Granularidade: Região Administrativa + ano';
    RAISE NOTICE '   - Indicadores LAI agregados no nível DF + ano';
    RAISE NOTICE '   - Índices criados';
    RAISE NOTICE '';
    RAISE NOTICE 'PRÓXIMO PASSO: Executar ETL para popular a tabela silver';
END $$;
