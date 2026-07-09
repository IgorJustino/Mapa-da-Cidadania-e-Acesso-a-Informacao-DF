import math

import numpy as np
import pandas as pd

from src.transformations.pdad import (
    media_ponderada,
    percentual_ponderado,
)


def test_percentual_ponderado_ignora_nulos_no_denominador():
    condicao = pd.Series([True, False, np.nan])
    pesos = pd.Series([50, 30, 100])

    assert percentual_ponderado(condicao, pesos) == 62.5


def test_media_ponderada_calcula_corretamente():
    valores = pd.Series([10, 20, 30])
    pesos = pd.Series([1, 2, 3])

    assert media_ponderada(valores, pesos) == (10 + 40 + 90) / 6


def test_peso_zero_e_ignorado():
    valores = pd.Series([10, 999])
    pesos = pd.Series([2, 0])

    assert media_ponderada(valores, pesos) == 10


def test_peso_negativo_e_ignorado():
    valores = pd.Series([10, 999])
    pesos = pd.Series([2, -1])

    assert media_ponderada(valores, pesos) == 10


def test_entrada_sem_dados_validos_retorna_nan():
    valores = pd.Series([np.nan])
    pesos = pd.Series([10])

    assert math.isnan(media_ponderada(valores, pesos))


def test_percentual_ponderado_sem_dados_validos_retorna_nan():
    condicao = pd.Series([np.nan])
    pesos = pd.Series([10])

    assert math.isnan(percentual_ponderado(condicao, pesos))


def test_codigo_especial_nao_entra_como_valor_real():
    valores = pd.Series([10, 99999])
    pesos = pd.Series([1, 100])

    assert media_ponderada(valores, pesos) == 10
