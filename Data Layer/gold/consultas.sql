-- Consultas analiticas da camada Gold
-- Escopo: 7 consultas territoriais + 3 consultas de LAI.

-- 1. RAs mais populosas em 2025
SELECT
    regiao_administrativa,
    populacao_2025
FROM gold.mart_indicadores_territoriais
ORDER BY populacao_2025 DESC;


-- 2. Maior crescimento populacional absoluto 2023-2025
SELECT
    regiao_administrativa,
    populacao_2023,
    populacao_2025,
    crescimento_populacional_absoluto
FROM gold.mart_indicadores_territoriais
ORDER BY crescimento_populacional_absoluto DESC;


-- 3. Maior crescimento populacional percentual 2023-2025
SELECT
    regiao_administrativa,
    populacao_2023,
    populacao_2025,
    crescimento_populacional_percentual
FROM gold.mart_indicadores_territoriais
ORDER BY crescimento_populacional_percentual DESC;


-- 4. RAs com menor renda media ponderada
SELECT
    regiao_administrativa,
    renda_media_ponderada,
    ano_referencia_pdad
FROM gold.mart_indicadores_territoriais
ORDER BY renda_media_ponderada ASC;


-- 5. RAs com menor acesso domiciliar a internet
SELECT
    regiao_administrativa,
    percentual_domicilios_com_internet,
    ano_referencia_pdad
FROM gold.mart_indicadores_territoriais
ORDER BY percentual_domicilios_com_internet ASC;


-- 6. RAs com maior baixa escolaridade
SELECT
    regiao_administrativa,
    percentual_baixa_escolaridade,
    ano_referencia_pdad
FROM gold.mart_indicadores_territoriais
ORDER BY percentual_baixa_escolaridade DESC;


-- 7. RAs com maior proporcao de idosos em 2025
SELECT
    regiao_administrativa,
    percentual_populacao_60_mais_2025,
    percentual_populacao_15_59_2025,
    percentual_populacao_0_14_2025
FROM gold.mart_indicadores_territoriais
ORDER BY percentual_populacao_60_mais_2025 DESC;


-- 8. Evolucao dos pedidos, recursos e satisfacoes LAI
SELECT
    ano,
    lai_df_qtd_pedidos_ano,
    lai_df_qtd_recursos_ano,
    lai_df_qtd_satisfacoes_ano
FROM gold.mart_acesso_informacao
ORDER BY ano;


-- 9. Evolucao dos pedidos com recurso e tempo de resposta
SELECT
    ano,
    lai_df_percentual_pedidos_com_recurso,
    lai_df_tempo_medio_resposta_dias
FROM gold.mart_acesso_informacao
ORDER BY ano;


-- 10. Evolucao dos resultados dos pedidos LAI
SELECT
    ano,
    lai_df_percentual_acesso_concedido,
    lai_df_percentual_acesso_negado,
    lai_df_percentual_acesso_parcial,
    lai_df_percentual_sem_resposta
FROM gold.mart_acesso_informacao
ORDER BY ano;
