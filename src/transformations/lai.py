import numpy as np
import pandas as pd


def calcular_percentual_pedidos_com_recurso(
    pedidos,
    recursos,
) -> float:
    pedidos_unicos = set(pd.Series(pedidos).dropna().unique())
    if not pedidos_unicos:
        return np.nan

    pedidos_com_recurso = set(pd.Series(recursos).dropna().unique())
    return 100 * len(pedidos_unicos.intersection(pedidos_com_recurso)) / len(
        pedidos_unicos
    )
