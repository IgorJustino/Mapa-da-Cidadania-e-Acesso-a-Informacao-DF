import math

import pandas as pd

from src.transformations.lai import (
    calcular_percentual_pedidos_com_recurso,
)


def test_percentual_pedidos_com_recurso_usa_pedidos_unicos():
    pedidos = pd.Series(["A", "B", "C"])
    recursos = pd.Series(["A", "A", "C"])

    assert (
        calcular_percentual_pedidos_com_recurso(pedidos, recursos)
        == 100 * 2 / 3
    )


def test_multiplos_recursos_mesmo_pedido_nao_duplicam_contagem():
    pedidos = pd.Series(["A", "B", "C"])
    recursos = pd.Series(["A", "A", "A"])

    assert calcular_percentual_pedidos_com_recurso(pedidos, recursos) == 100 / 3


def test_sem_recursos_retorna_zero():
    pedidos = pd.Series(["A", "B", "C"])
    recursos = pd.Series([], dtype=object)

    assert calcular_percentual_pedidos_com_recurso(pedidos, recursos) == 0


def test_sem_pedidos_trata_divisao_por_zero():
    pedidos = pd.Series([], dtype=object)
    recursos = pd.Series(["A"], dtype=object)

    assert math.isnan(
        calcular_percentual_pedidos_com_recurso(pedidos, recursos)
    )


def test_recurso_fora_do_universo_de_pedidos_nao_entra_no_percentual():
    pedidos = pd.Series(["A", "B", "C"])
    recursos = pd.Series(["A", "D"])

    assert calcular_percentual_pedidos_com_recurso(pedidos, recursos) == 100 / 3
