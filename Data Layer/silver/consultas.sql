-- Visualização inicial da tabela Silver

SELECT *
FROM silver.tb_mapa_cidadania_ra_ano_silver
LIMIT 10;


-- Quantidade de Regiões Administrativas por ano

SELECT
    ano,
    COUNT(*) AS qtd_regioes
FROM silver.tb_mapa_cidadania_ra_ano_silver
GROUP BY ano
ORDER BY ano;


-- Validação de duplicidades pela chave lógica

SELECT
    regiao_administrativa,
    ano,
    COUNT(*) AS qtd_linhas
FROM silver.tb_mapa_cidadania_ra_ano_silver
GROUP BY regiao_administrativa, ano
HAVING COUNT(*) > 1;


-- Ranking de Regiões Administrativas por renda média ponderada

SELECT
    regiao_administrativa,
    ano,
    populacao_total,
    renda_media_ponderada,
    percentual_baixa_escolaridade
FROM silver.tb_mapa_cidadania_ra_ano_silver
ORDER BY renda_media_ponderada ASC;


-- Média dos indicadores socioeconômicos no período 2023-2025

SELECT
    regiao_administrativa,
    AVG(renda_media_ponderada) AS renda_media_2023_2025,
    AVG(percentual_baixa_escolaridade) AS baixa_escolaridade_media,
    AVG(percentual_domicilios_com_internet) AS internet_media
FROM silver.tb_mapa_cidadania_ra_ano_silver
GROUP BY regiao_administrativa
ORDER BY renda_media_2023_2025 ASC;


-- Evolução populacional por Região Administrativa

SELECT
    regiao_administrativa,
    ano,
    populacao_total
FROM silver.tb_mapa_cidadania_ra_ano_silver
ORDER BY regiao_administrativa, ano;


-- Indicadores anuais de LAI no DF

SELECT DISTINCT
    ano,
    lai_df_qtd_pedidos_ano,
    lai_df_qtd_recursos_ano,
    lai_df_qtd_satisfacoes_ano,
    lai_df_taxa_recurso_ano,
    lai_df_tempo_medio_resposta_dias,
    lai_df_percentual_acesso_concedido,
    lai_df_percentual_acesso_negado,
    lai_df_percentual_acesso_parcial,
    lai_df_percentual_sem_resposta,
    lai_df_qtd_orgaos_demandados
FROM silver.tb_mapa_cidadania_ra_ano_silver
ORDER BY ano;


-- Validação de que os indicadores LAI são iguais para todas as RAs dentro do mesmo ano

SELECT
    ano,
    COUNT(DISTINCT lai_df_qtd_pedidos_ano) AS variacoes_pedidos,
    COUNT(DISTINCT lai_df_qtd_recursos_ano) AS variacoes_recursos,
    COUNT(DISTINCT lai_df_taxa_recurso_ano) AS variacoes_taxa_recurso,
    COUNT(DISTINCT lai_df_tempo_medio_resposta_dias) AS variacoes_tempo_resposta
FROM silver.tb_mapa_cidadania_ra_ano_silver
GROUP BY ano
ORDER BY ano;
