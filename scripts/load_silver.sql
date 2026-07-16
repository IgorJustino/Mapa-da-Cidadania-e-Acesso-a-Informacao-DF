-- Carga reproduzivel da camada Silver.
-- Executado automaticamente pelo entrypoint oficial do PostgreSQL
-- apos a criacao dos schemas e da tabela.

SET timezone = 'America/Sao_Paulo';

\copy silver.tb_mapa_cidadania_ra_ano_silver FROM '/opt/mapa_cidadania/silver/tb_mapa_cidadania_ra_ano_silver.csv' WITH (FORMAT csv, HEADER true);

DO $$
BEGIN
    RAISE NOTICE 'Carga SILVER concluida com sucesso!';
    RAISE NOTICE '   - Tabela: silver.tb_mapa_cidadania_ra_ano_silver';
    RAISE NOTICE '   - Origem: /opt/mapa_cidadania/silver/tb_mapa_cidadania_ra_ano_silver.csv';
END $$;
