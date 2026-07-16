-- Validacoes do contrato da Silver no PostgreSQL.
-- Este script falha a inicializacao se o banco carregado divergir do PRD.

SET timezone = 'America/Sao_Paulo';

DO $$
DECLARE
    expected_columns text[] := ARRAY[
        'ano',
        'regiao_administrativa',
        'ano_referencia_pdad',
        'populacao_total',
        'populacao_masculina',
        'populacao_feminina',
        'populacao_0_14',
        'populacao_15_59',
        'populacao_60_mais',
        'renda_media_ponderada',
        'idade_media_ponderada',
        'media_moradores_por_domicilio',
        'percentual_baixa_escolaridade',
        'percentual_domicilios_com_internet',
        'percentual_domicilios_proprios',
        'percentual_domicilios_alugados',
        'lai_df_qtd_pedidos_ano',
        'lai_df_qtd_recursos_ano',
        'lai_df_qtd_satisfacoes_ano',
        'lai_df_percentual_pedidos_com_recurso',
        'lai_df_tempo_medio_resposta_dias',
        'lai_df_percentual_acesso_concedido',
        'lai_df_percentual_acesso_negado',
        'lai_df_percentual_acesso_parcial',
        'lai_df_percentual_sem_resposta',
        'lai_df_qtd_orgaos_demandados'
    ];
    expected_ras text[] := ARRAY[
        'Arniqueira',
        'Brazlândia',
        'Candangolândia',
        'Ceilândia',
        'Cruzeiro',
        'Fercal',
        'Gama',
        'Guará',
        'Itapoã',
        'Jardim Botânico',
        'Lago Norte',
        'Lago Sul',
        'Núcleo Bandeirante',
        'Paranoá',
        'Park Way',
        'Planaltina',
        'Plano Piloto',
        'Recanto das Emas',
        'Riacho Fundo',
        'Riacho Fundo II',
        'SCIA',
        'SIA',
        'Samambaia',
        'Santa Maria',
        'Sobradinho',
        'Sobradinho II',
        'Sol Nascente/Pôr do Sol',
        'Sudoeste e Octogonal',
        'São Sebastião',
        'Taguatinga',
        'Varjão',
        'Vicente Pires',
        'Águas Claras'
    ];
    actual_columns text[];
    actual_count integer;
    actual_years integer[];
BEGIN
    IF current_database() <> 'mapa_cidadania' THEN
        RAISE EXCEPTION 'Banco invalido: esperado mapa_cidadania, atual %', current_database();
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.schemata WHERE schema_name = 'silver') THEN
        RAISE EXCEPTION 'Schema silver nao encontrado';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.schemata WHERE schema_name = 'gold') THEN
        RAISE EXCEPTION 'Schema gold nao encontrado';
    END IF;

    IF to_regclass('silver.tb_mapa_cidadania_ra_ano_silver') IS NULL THEN
        RAISE EXCEPTION 'Tabela silver.tb_mapa_cidadania_ra_ano_silver nao encontrada';
    END IF;

    SELECT array_agg(column_name::text ORDER BY ordinal_position)
    INTO actual_columns
    FROM information_schema.columns
    WHERE table_schema = 'silver'
      AND table_name = 'tb_mapa_cidadania_ra_ano_silver';

    IF actual_columns IS DISTINCT FROM expected_columns THEN
        RAISE EXCEPTION 'Colunas da Silver divergem do contrato. Esperado: %, Atual: %', expected_columns, actual_columns;
    END IF;

    SELECT COUNT(*) INTO actual_count
    FROM silver.tb_mapa_cidadania_ra_ano_silver;

    IF actual_count <> 99 THEN
        RAISE EXCEPTION 'Quantidade de registros invalida: esperado 99, atual %', actual_count;
    END IF;

    SELECT COUNT(DISTINCT regiao_administrativa) INTO actual_count
    FROM silver.tb_mapa_cidadania_ra_ano_silver;

    IF actual_count <> 33 THEN
        RAISE EXCEPTION 'Quantidade de RAs invalida: esperado 33, atual %', actual_count;
    END IF;

    SELECT COUNT(*) INTO actual_count
    FROM (
        SELECT unnest(expected_ras)
        EXCEPT
        SELECT DISTINCT regiao_administrativa
        FROM silver.tb_mapa_cidadania_ra_ano_silver
    ) ras_ausentes;

    IF actual_count <> 0 THEN
        RAISE EXCEPTION 'RAs esperadas ausentes: %', actual_count;
    END IF;

    SELECT COUNT(*) INTO actual_count
    FROM (
        SELECT DISTINCT regiao_administrativa
        FROM silver.tb_mapa_cidadania_ra_ano_silver
        EXCEPT
        SELECT unnest(expected_ras)
    ) ras_inesperadas;

    IF actual_count <> 0 THEN
        RAISE EXCEPTION 'RAs inesperadas encontradas: %', actual_count;
    END IF;

    SELECT array_agg(DISTINCT ano ORDER BY ano) INTO actual_years
    FROM silver.tb_mapa_cidadania_ra_ano_silver
    WHERE ano IS NOT NULL;

    IF actual_years IS DISTINCT FROM ARRAY[2023, 2024, 2025] THEN
        RAISE EXCEPTION 'Anos invalidos: esperado [2023, 2024, 2025], atual %', actual_years;
    END IF;

    SELECT COUNT(*) INTO actual_count
    FROM silver.tb_mapa_cidadania_ra_ano_silver
    WHERE ano_referencia_pdad <> 2024;

    IF actual_count <> 0 THEN
        RAISE EXCEPTION 'ano_referencia_pdad invalido em % registros', actual_count;
    END IF;

    SELECT COUNT(*) INTO actual_count
    FROM (
        SELECT regiao_administrativa, ano
        FROM silver.tb_mapa_cidadania_ra_ano_silver
        GROUP BY regiao_administrativa, ano
        HAVING COUNT(*) > 1
    ) duplicidades;

    IF actual_count <> 0 THEN
        RAISE EXCEPTION 'Duplicidades RA + ano encontradas: %', actual_count;
    END IF;

    SELECT COUNT(*) INTO actual_count
    FROM silver.tb_mapa_cidadania_ra_ano_silver
    WHERE regiao_administrativa IS NULL
       OR ano IS NULL
       OR ano_referencia_pdad IS NULL
       OR populacao_total IS NULL
       OR lai_df_qtd_pedidos_ano IS NULL;

    IF actual_count <> 0 THEN
        RAISE EXCEPTION 'Nulos criticos encontrados: %', actual_count;
    END IF;

    RAISE NOTICE 'Validacao PostgreSQL da Silver concluida com sucesso!';
    RAISE NOTICE '   - Banco: %', current_database();
    RAISE NOTICE '   - Schemas silver e gold existem';
    RAISE NOTICE '   - Tabela Silver existe';
    RAISE NOTICE '   - 26 colunas corretas';
    RAISE NOTICE '   - 99 registros carregados';
    RAISE NOTICE '   - 33 RAs canonicas';
    RAISE NOTICE '   - Anos 2023, 2024 e 2025';
    RAISE NOTICE '   - 0 duplicidades RA + ano';
END $$;
