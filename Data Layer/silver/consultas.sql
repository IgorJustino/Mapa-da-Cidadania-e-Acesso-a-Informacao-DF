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
