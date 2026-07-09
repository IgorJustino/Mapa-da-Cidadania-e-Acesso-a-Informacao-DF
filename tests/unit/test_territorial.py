import pandas as pd
import pytest

from src.transformations.territorial import (
    normalizar_chave_regiao_administrativa,
    normalizar_regiao_administrativa,
    remover_acentos,
)


@pytest.mark.parametrize(
    "entrada, esperado",
    [
        ("Sudoeste_Octogonal", "Sudoeste e Octogonal"),
        ("Sudoeste e Octogonal", "Sudoeste e Octogonal"),
        ("sudoeste_octogonal", "Sudoeste e Octogonal"),
        ("SUDOESTE E OCTOGONAL", "Sudoeste e Octogonal"),
    ],
)
def test_normalizar_sudoeste_octogonal(entrada, esperado):
    assert normalizar_regiao_administrativa(entrada) == esperado


@pytest.mark.parametrize(
    "entrada, esperado",
    [
        ("Sol Nascente_Pôr do Sol", "Sol Nascente/Por do Sol"),
        ("sol nascente por do sol", "Sol Nascente/Por do Sol"),
    ],
)
def test_alias_conhecido_retorna_nome_canonico(entrada, esperado):
    assert normalizar_regiao_administrativa(entrada) == esperado


def test_nome_canonico_permanece_estavel():
    assert (
        normalizar_regiao_administrativa("Ceilândia")
        == "Ceilândia"
    )


def test_normalizacao_ignora_diferencas_de_caixa():
    assert (
        normalizar_regiao_administrativa("sUdOeStE_oCtOgOnAl")
        == "Sudoeste e Octogonal"
    )


def test_normalizacao_ignora_acentos_quando_aplicavel():
    assert (
        normalizar_regiao_administrativa("Sol Nascente_Por do Sol")
        == "Sol Nascente/Por do Sol"
    )


def test_chave_regiao_administrativa_remove_acentos_e_alias():
    assert (
        normalizar_chave_regiao_administrativa("Sudoeste_Octogonal")
        == "sudoeste e octogonal"
    )


def test_nome_nulo_retorna_na():
    assert pd.isna(normalizar_regiao_administrativa(pd.NA))


def test_remover_acentos_preserva_nulo():
    assert pd.isna(remover_acentos(pd.NA))
