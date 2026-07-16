from io import StringIO

import pandas as pd

from src.transformations.territorial import normalizar_chave_regiao_administrativa


COLUNAS_POR_PREFIXO = {
    "populacao": [
        "populacao_total",
        "populacao_masculina",
        "populacao_feminina",
        "populacao_0_14",
        "populacao_15_59",
        "populacao_60_mais",
    ],
    "pdad": [
        "renda_media_ponderada",
        "idade_media_ponderada",
        "media_moradores_por_domicilio",
        "percentual_baixa_escolaridade",
        "percentual_domicilios_com_internet",
        "percentual_domicilios_proprios",
        "percentual_domicilios_alugados",
    ],
    "lai": [
        "lai_df_qtd_pedidos_ano",
        "lai_df_qtd_recursos_ano",
        "lai_df_qtd_satisfacoes_ano",
        "lai_df_percentual_pedidos_com_recurso",
        "lai_df_tempo_medio_resposta_dias",
        "lai_df_percentual_acesso_concedido",
        "lai_df_percentual_acesso_negado",
        "lai_df_percentual_acesso_parcial",
        "lai_df_percentual_sem_resposta",
        "lai_df_qtd_orgaos_demandados",
    ],
}


def criar_dim_tempo(df_silver: pd.DataFrame) -> pd.DataFrame:
    anos = sorted(df_silver["ano"].dropna().unique())
    dim_tempo = pd.DataFrame({"ano": anos})
    dim_tempo.insert(0, "sk_tempo", range(1, len(dim_tempo) + 1))
    dim_tempo["ano_referencia_pdad"] = (
        df_silver["ano_referencia_pdad"].dropna().astype(int).unique()[0]
    )
    dim_tempo["periodo_analise"] = dim_tempo["ano"].astype(str)
    dim_tempo["is_ano_referencia_pdad"] = (
        dim_tempo["ano"] == dim_tempo["ano_referencia_pdad"]
    )
    return dim_tempo


def criar_dim_regiao_administrativa(df_silver: pd.DataFrame) -> pd.DataFrame:
    regioes = sorted(df_silver["regiao_administrativa"].dropna().unique())
    dim_regiao = pd.DataFrame({"regiao_administrativa": regioes})
    dim_regiao.insert(0, "sk_regiao_administrativa", range(1, len(dim_regiao) + 1))
    dim_regiao["chave_regiao_administrativa"] = dim_regiao[
        "regiao_administrativa"
    ].apply(normalizar_chave_regiao_administrativa)
    dim_regiao["nivel_territorial"] = "Regiao Administrativa"
    dim_regiao["uf"] = "DF"
    return dim_regiao


def criar_fato_mapa_cidadania(
    df_silver: pd.DataFrame,
    dim_tempo: pd.DataFrame,
    dim_regiao: pd.DataFrame,
) -> pd.DataFrame:
    fato = df_silver.merge(
        dim_tempo[["sk_tempo", "ano"]],
        on="ano",
        how="left",
        validate="many_to_one",
    ).merge(
        dim_regiao[["sk_regiao_administrativa", "regiao_administrativa"]],
        on="regiao_administrativa",
        how="left",
        validate="many_to_one",
    )

    colunas_metricas = (
        COLUNAS_POR_PREFIXO["populacao"]
        + COLUNAS_POR_PREFIXO["pdad"]
        + COLUNAS_POR_PREFIXO["lai"]
    )
    fato = fato[
        [
            "sk_regiao_administrativa",
            "sk_tempo",
            "ano",
            "regiao_administrativa",
            "ano_referencia_pdad",
        ]
        + colunas_metricas
    ].copy()
    fato.insert(0, "sk_fato_mapa_cidadania", range(1, len(fato) + 1))
    return fato.sort_values(
        ["regiao_administrativa", "ano"]
    ).reset_index(drop=True)


def criar_mart_indicadores_territoriais(
    fato_mapa: pd.DataFrame,
) -> pd.DataFrame:
    colunas_pdad = [
        "sk_regiao_administrativa",
        "regiao_administrativa",
        "ano_referencia_pdad",
        "renda_media_ponderada",
        "idade_media_ponderada",
        "media_moradores_por_domicilio",
        "percentual_baixa_escolaridade",
        "percentual_domicilios_com_internet",
        "percentual_domicilios_proprios",
        "percentual_domicilios_alugados",
    ]
    mart = (
        fato_mapa.sort_values("ano")
        .drop_duplicates("sk_regiao_administrativa")
        [colunas_pdad]
        .copy()
    )

    populacao = fato_mapa.pivot(
        index="sk_regiao_administrativa",
        columns="ano",
        values=[
            "populacao_total",
            "populacao_0_14",
            "populacao_15_59",
            "populacao_60_mais",
        ],
    )

    mart["populacao_2023"] = mart["sk_regiao_administrativa"].map(
        populacao["populacao_total"][2023]
    )
    mart["populacao_2025"] = mart["sk_regiao_administrativa"].map(
        populacao["populacao_total"][2025]
    )
    mart["crescimento_populacional_absoluto"] = (
        mart["populacao_2025"] - mart["populacao_2023"]
    )
    mart["crescimento_populacional_percentual"] = (
        mart["crescimento_populacional_absoluto"]
        / mart["populacao_2023"]
        * 100
    )

    populacao_2025 = mart["sk_regiao_administrativa"].map(
        populacao["populacao_total"][2025]
    )
    mart["percentual_populacao_0_14_2025"] = (
        mart["sk_regiao_administrativa"].map(populacao["populacao_0_14"][2025])
        / populacao_2025
        * 100
    )
    mart["percentual_populacao_15_59_2025"] = (
        mart["sk_regiao_administrativa"].map(populacao["populacao_15_59"][2025])
        / populacao_2025
        * 100
    )
    mart["percentual_populacao_60_mais_2025"] = (
        mart["sk_regiao_administrativa"].map(
            populacao["populacao_60_mais"][2025]
        )
        / populacao_2025
        * 100
    )

    return mart.sort_values("regiao_administrativa").reset_index(drop=True)


def criar_mart_acesso_informacao(fato_mapa: pd.DataFrame) -> pd.DataFrame:
    colunas_lai = ["ano"] + COLUNAS_POR_PREFIXO["lai"]
    mart = fato_mapa[colunas_lai].drop_duplicates().sort_values("ano")
    mart.insert(0, "sk_mart_acesso_informacao", range(1, len(mart) + 1))
    return mart.reset_index(drop=True)


def construir_gold(df_silver: pd.DataFrame) -> dict[str, pd.DataFrame]:
    dim_tempo = criar_dim_tempo(df_silver)
    dim_regiao = criar_dim_regiao_administrativa(df_silver)
    fato_mapa = criar_fato_mapa_cidadania(df_silver, dim_tempo, dim_regiao)
    mart_territorial = criar_mart_indicadores_territoriais(fato_mapa)
    mart_lai = criar_mart_acesso_informacao(fato_mapa)

    return {
        "dim_tempo": dim_tempo,
        "dim_regiao_administrativa": dim_regiao,
        "fato_mapa_cidadania": fato_mapa,
        "mart_indicadores_territoriais": mart_territorial,
        "mart_acesso_informacao": mart_lai,
    }


ORDEM_CARGA_POSTGRES = [
    "dim_tempo",
    "dim_regiao_administrativa",
    "fato_mapa_cidadania",
    "mart_indicadores_territoriais",
    "mart_acesso_informacao",
]


def carregar_gold_postgres(
    tabelas_gold: dict[str, pd.DataFrame],
    conn,
    schema: str = "gold",
) -> None:
    """Carrega DataFrames Gold diretamente no PostgreSQL via COPY em memoria."""
    nomes_tabelas = ", ".join(
        f"{schema}.{nome_tabela}" for nome_tabela in reversed(ORDEM_CARGA_POSTGRES)
    )

    with conn.cursor() as cur:
        cur.execute(f"TRUNCATE {nomes_tabelas};")

        for nome_tabela in ORDEM_CARGA_POSTGRES:
            df = tabelas_gold[nome_tabela]
            buffer = StringIO()
            df.to_csv(buffer, index=False)
            buffer.seek(0)

            colunas = ", ".join(df.columns)
            copy_sql = (
                f"COPY {schema}.{nome_tabela} ({colunas}) "
                "FROM STDIN WITH (FORMAT csv, HEADER true)"
            )
            with cur.copy(copy_sql) as copy:
                copy.write(buffer.getvalue())

    conn.commit()
