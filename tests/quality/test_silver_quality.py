import pandas as pd

from src.quality.contracts import (
    CAMPOS_CRITICOS,
    REGIOES_ADMINISTRATIVAS_ESPERADAS,
    SILVER_COLUMNS,
    SILVER_CONTRACT,
)


def test_silver_tem_99_linhas(df_silver):
    assert len(df_silver) == SILVER_CONTRACT[
        "quantidade_linhas_esperada"
    ]


def test_silver_tem_26_colunas(df_silver):
    assert df_silver.shape[1] == SILVER_CONTRACT[
        "quantidade_colunas_esperada"
    ]


def test_silver_schema_exato(df_silver):
    assert list(df_silver.columns) == SILVER_COLUMNS


def test_silver_tem_33_ras(df_silver):
    quantidade_ras = df_silver[
        "regiao_administrativa"
    ].nunique()

    assert quantidade_ras == SILVER_CONTRACT[
        "quantidade_ras"
    ]


def test_silver_tem_lista_nominal_exata_de_ras(df_silver):
    ras = set(df_silver["regiao_administrativa"].unique())

    assert ras == REGIOES_ADMINISTRATIVAS_ESPERADAS


def test_silver_tem_anos_esperados(df_silver):
    anos = set(df_silver["ano"].unique())

    assert anos == SILVER_CONTRACT[
        "anos_esperados"
    ]


def test_ano_referencia_pdad_igual_2024(df_silver):
    valores = set(
        df_silver["ano_referencia_pdad"].unique()
    )

    assert valores == {
        SILVER_CONTRACT["ano_referencia_pdad"]
    }


def test_silver_sem_duplicidades_ra_ano(df_silver):
    duplicidades = df_silver.duplicated(
        subset=SILVER_CONTRACT["chave"]
    ).sum()

    assert duplicidades == 0


def test_silver_sem_nulos_criticos(df_silver):
    nulos = (
        df_silver[CAMPOS_CRITICOS]
        .isna()
        .sum()
        .sum()
    )

    assert nulos == 0


def test_silver_sem_valores_vazios(df_silver):
    assert df_silver.isna().sum().sum() == 0


def test_populacao_por_sexo_consistente(df_silver):
    soma_sexo = (
        df_silver["populacao_masculina"]
        + df_silver["populacao_feminina"]
    )

    pd.testing.assert_series_equal(
        soma_sexo,
        df_silver["populacao_total"],
        check_names=False,
        rtol=1e-9,
        atol=1e-6,
    )


def test_populacao_por_faixa_etaria_consistente(
    df_silver,
):
    soma_faixas = (
        df_silver["populacao_0_14"]
        + df_silver["populacao_15_59"]
        + df_silver["populacao_60_mais"]
    )

    pd.testing.assert_series_equal(
        soma_faixas,
        df_silver["populacao_total"],
        check_names=False,
        rtol=1e-9,
        atol=1e-6,
    )


def test_percentuais_entre_zero_e_cem(df_silver):
    colunas_percentuais = [
        coluna
        for coluna in df_silver.columns
        if "percentual" in coluna
    ]

    for coluna in colunas_percentuais:
        assert df_silver[coluna].between(
            0,
            100,
        ).all(), f"Valores inválidos em {coluna}"


def test_indicadores_lai_constantes_por_ano(
    df_silver,
):
    colunas_lai = [
        coluna
        for coluna in df_silver.columns
        if coluna.startswith("lai_df_")
    ]

    variacoes = (
        df_silver
        .groupby("ano")[colunas_lai]
        .nunique()
    )

    assert (variacoes <= 1).all().all()
