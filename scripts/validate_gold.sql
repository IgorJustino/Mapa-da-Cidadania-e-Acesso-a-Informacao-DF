-- Validacoes do contrato minimo da Gold no PostgreSQL.

SET timezone = 'America/Sao_Paulo';

DO $$
DECLARE
    actual_count integer;
    actual_years integer[];
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.schemata WHERE schema_name = 'gold') THEN
        RAISE EXCEPTION 'Schema gold nao encontrado';
    END IF;

    SELECT COUNT(*) INTO actual_count FROM gold.dim_tempo;
    IF actual_count <> 3 THEN
        RAISE EXCEPTION 'gold.dim_tempo invalida: esperado 3, atual %', actual_count;
    END IF;

    SELECT array_agg(ano ORDER BY ano) INTO actual_years FROM gold.dim_tempo;
    IF actual_years IS DISTINCT FROM ARRAY[2023, 2024, 2025] THEN
        RAISE EXCEPTION 'gold.dim_tempo com anos invalidos: %', actual_years;
    END IF;

    SELECT COUNT(*) INTO actual_count
    FROM (
        SELECT ano
        FROM gold.dim_tempo
        GROUP BY ano
        HAVING COUNT(*) > 1
    ) duplicidades;

    IF actual_count <> 0 THEN
        RAISE EXCEPTION 'gold.dim_tempo possui anos duplicados: %', actual_count;
    END IF;

    SELECT COUNT(*) INTO actual_count FROM gold.dim_regiao_administrativa;
    IF actual_count <> 33 THEN
        RAISE EXCEPTION 'gold.dim_regiao_administrativa invalida: esperado 33, atual %', actual_count;
    END IF;

    SELECT COUNT(*) INTO actual_count
    FROM (
        SELECT regiao_administrativa
        FROM gold.dim_regiao_administrativa
        GROUP BY regiao_administrativa
        HAVING COUNT(*) > 1
    ) duplicidades;

    IF actual_count <> 0 THEN
        RAISE EXCEPTION 'gold.dim_regiao_administrativa possui RAs duplicadas: %', actual_count;
    END IF;

    SELECT COUNT(*) INTO actual_count FROM gold.fato_mapa_cidadania;
    IF actual_count <> 99 THEN
        RAISE EXCEPTION 'gold.fato_mapa_cidadania invalida: esperado 99, atual %', actual_count;
    END IF;

    SELECT COUNT(*) INTO actual_count FROM gold.mart_indicadores_territoriais;
    IF actual_count <> 33 THEN
        RAISE EXCEPTION 'gold.mart_indicadores_territoriais invalida: esperado 33, atual %', actual_count;
    END IF;

    SELECT COUNT(*) INTO actual_count FROM gold.mart_acesso_informacao;
    IF actual_count <> 3 THEN
        RAISE EXCEPTION 'gold.mart_acesso_informacao invalida: esperado 3, atual %', actual_count;
    END IF;

    SELECT COUNT(*) INTO actual_count
    FROM gold.fato_mapa_cidadania
    WHERE sk_tempo IS NULL
       OR sk_regiao_administrativa IS NULL;

    IF actual_count <> 0 THEN
        RAISE EXCEPTION 'Fato Gold com chaves dimensionais nulas: %', actual_count;
    END IF;

    SELECT COUNT(*) INTO actual_count
    FROM gold.fato_mapa_cidadania f
    LEFT JOIN gold.dim_regiao_administrativa d
        ON f.sk_regiao_administrativa = d.sk_regiao_administrativa
    WHERE d.sk_regiao_administrativa IS NULL;

    IF actual_count <> 0 THEN
        RAISE EXCEPTION 'Fato Gold com chaves de RA orfas: %', actual_count;
    END IF;

    SELECT COUNT(*) INTO actual_count
    FROM gold.fato_mapa_cidadania f
    LEFT JOIN gold.dim_tempo d
        ON f.sk_tempo = d.sk_tempo
    WHERE d.sk_tempo IS NULL;

    IF actual_count <> 0 THEN
        RAISE EXCEPTION 'Fato Gold com chaves de tempo orfas: %', actual_count;
    END IF;

    SELECT COUNT(*) INTO actual_count
    FROM (
        SELECT sk_regiao_administrativa, sk_tempo
        FROM gold.fato_mapa_cidadania
        GROUP BY sk_regiao_administrativa, sk_tempo
        HAVING COUNT(*) > 1
    ) duplicidades;

    IF actual_count <> 0 THEN
        RAISE EXCEPTION 'Duplicidades Gold regiao + tempo encontradas: %', actual_count;
    END IF;

    SELECT COUNT(*) INTO actual_count
    FROM (
        SELECT sk_regiao_administrativa
        FROM gold.mart_indicadores_territoriais
        GROUP BY sk_regiao_administrativa
        HAVING COUNT(*) > 1
    ) duplicidades;

    IF actual_count <> 0 THEN
        RAISE EXCEPTION 'mart_indicadores_territoriais possui RAs duplicadas: %', actual_count;
    END IF;

    SELECT COUNT(*) INTO actual_count
    FROM gold.mart_indicadores_territoriais m
    LEFT JOIN gold.dim_regiao_administrativa d
        ON m.sk_regiao_administrativa = d.sk_regiao_administrativa
    WHERE d.sk_regiao_administrativa IS NULL;

    IF actual_count <> 0 THEN
        RAISE EXCEPTION 'mart_indicadores_territoriais com chaves de RA orfas: %', actual_count;
    END IF;

    SELECT COUNT(*) INTO actual_count
    FROM gold.mart_indicadores_territoriais
    WHERE ano_referencia_pdad <> 2024
       OR populacao_2023 IS NULL
       OR populacao_2025 IS NULL
       OR crescimento_populacional_absoluto IS NULL
       OR crescimento_populacional_percentual IS NULL
       OR percentual_populacao_0_14_2025 IS NULL
       OR percentual_populacao_15_59_2025 IS NULL
       OR percentual_populacao_60_mais_2025 IS NULL;

    IF actual_count <> 0 THEN
        RAISE EXCEPTION 'mart_indicadores_territoriais com eixo temporal indefinido: %', actual_count;
    END IF;

    SELECT COUNT(*) INTO actual_count
    FROM (
        SELECT ano
        FROM gold.mart_acesso_informacao
        GROUP BY ano
        HAVING COUNT(*) > 1
    ) duplicidades;

    IF actual_count <> 0 THEN
        RAISE EXCEPTION 'mart_acesso_informacao possui anos duplicados: %', actual_count;
    END IF;

    SELECT array_agg(ano ORDER BY ano) INTO actual_years
    FROM gold.mart_acesso_informacao;

    IF actual_years IS DISTINCT FROM ARRAY[2023, 2024, 2025] THEN
        RAISE EXCEPTION 'mart_acesso_informacao com anos invalidos: %', actual_years;
    END IF;

    SELECT COUNT(*) INTO actual_count
    FROM gold.dim_regiao_administrativa
    WHERE regiao_administrativa IN (
        'Sudoeste_Octogonal',
        'Sol Nascente_Pôr do Sol',
        'Sol Nascente/Por do Sol'
    );

    IF actual_count <> 0 THEN
        RAISE EXCEPTION 'Nomes territoriais nao canonicos encontrados na Gold: %', actual_count;
    END IF;

    RAISE NOTICE 'Validacao PostgreSQL da Gold concluida com sucesso!';
    RAISE NOTICE '   - dim_tempo: 3 linhas';
    RAISE NOTICE '   - dim_regiao_administrativa: 33 linhas canonicas';
    RAISE NOTICE '   - fato_mapa_cidadania: 99 linhas';
    RAISE NOTICE '   - 0 chaves orfas';
    RAISE NOTICE '   - marts Gold carregados';
END $$;
