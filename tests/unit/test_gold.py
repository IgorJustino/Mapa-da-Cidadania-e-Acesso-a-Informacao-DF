from src.quality.contracts import REGIOES_ADMINISTRATIVAS_ESPERADAS
from src.transformations.gold import construir_gold


def test_gold_dimensoes_e_fato_respeitam_granularidade_silver(df_silver):
    gold = construir_gold(df_silver)

    assert len(gold["dim_tempo"]) == 3
    assert set(gold["dim_tempo"]["ano"]) == {2023, 2024, 2025}
    assert len(gold["dim_regiao_administrativa"]) == 33
    assert len(gold["fato_mapa_cidadania"]) == 99


def test_gold_dimensoes_nao_tem_duplicidade(df_silver):
    gold = construir_gold(df_silver)

    assert gold["dim_tempo"]["ano"].duplicated().sum() == 0
    assert (
        gold["dim_regiao_administrativa"]["regiao_administrativa"]
        .duplicated()
        .sum()
        == 0
    )


def test_gold_dim_regiao_usa_lista_nominal_canonica(df_silver):
    gold = construir_gold(df_silver)
    ras = set(
        gold["dim_regiao_administrativa"]["regiao_administrativa"]
    )

    assert ras == REGIOES_ADMINISTRATIVAS_ESPERADAS
    assert "Sudoeste_Octogonal" not in ras
    assert "Sol Nascente_Pôr do Sol" not in ras
    assert "Sol Nascente/Pôr do Sol" in ras


def test_gold_fato_tem_integridade_referencial(df_silver):
    gold = construir_gold(df_silver)
    fato = gold["fato_mapa_cidadania"]
    sk_tempo = set(gold["dim_tempo"]["sk_tempo"])
    sk_regiao = set(
        gold["dim_regiao_administrativa"]["sk_regiao_administrativa"]
    )

    assert fato["sk_tempo"].notna().all()
    assert fato["sk_regiao_administrativa"].notna().all()
    assert set(fato["sk_tempo"]).issubset(sk_tempo)
    assert set(fato["sk_regiao_administrativa"]).issubset(sk_regiao)
    assert fato.duplicated(
        ["sk_regiao_administrativa", "sk_tempo"]
    ).sum() == 0


def test_gold_marts_tem_granularidade_esperada(df_silver):
    gold = construir_gold(df_silver)

    assert len(gold["mart_indicadores_territoriais"]) == 33
    assert len(gold["mart_acesso_informacao"]) == 3
    assert (
        gold["mart_indicadores_territoriais"][
            "sk_regiao_administrativa"
        ].duplicated().sum()
        == 0
    )
    assert gold["mart_acesso_informacao"]["ano"].duplicated().sum() == 0
    assert set(gold["mart_acesso_informacao"]["ano"]) == {2023, 2024, 2025}

    sk_regiao = set(
        gold["dim_regiao_administrativa"]["sk_regiao_administrativa"]
    )
    assert set(
        gold["mart_indicadores_territoriais"][
            "sk_regiao_administrativa"
        ]
    ).issubset(sk_regiao)


def test_gold_mart_territorial_explica_eixo_temporal(df_silver):
    gold = construir_gold(df_silver)
    mart = gold["mart_indicadores_territoriais"]

    colunas_esperadas = {
        "ano_referencia_pdad",
        "populacao_2023",
        "populacao_2025",
        "crescimento_populacional_absoluto",
        "crescimento_populacional_percentual",
        "percentual_populacao_0_14_2025",
        "percentual_populacao_15_59_2025",
        "percentual_populacao_60_mais_2025",
    }

    assert colunas_esperadas.issubset(set(mart.columns))
    assert set(mart["ano_referencia_pdad"]) == {2024}
    assert (
        mart["crescimento_populacional_absoluto"]
        == mart["populacao_2025"] - mart["populacao_2023"]
    ).all()
