import numpy as np
import pandas as pd


CODIGOS_ESPECIAIS_PDAD = {
    77777,
    88888,
    99999,
    77777.0,
    88888.0,
    99999.0,
    "77777",
    "88888",
    "99999",
}


def _serie_sem_codigos_especiais(serie):
    return pd.Series(serie).replace(list(CODIGOS_ESPECIAIS_PDAD), np.nan)


def media_ponderada(valor, peso):
    dados = pd.DataFrame(
        {
            "valor": _serie_sem_codigos_especiais(valor),
            "peso": peso,
        }
    ).dropna()
    dados = dados[dados["peso"] > 0]

    if dados.empty or dados["peso"].sum() == 0:
        return np.nan

    return np.average(dados["valor"], weights=dados["peso"])


def percentual_ponderado(condicao, peso):
    dados = pd.DataFrame(
        {
            "condicao": condicao,
            "peso": peso,
        }
    ).dropna()
    dados = dados[dados["peso"] > 0]

    if dados.empty or dados["peso"].sum() == 0:
        return np.nan

    numerador = dados.loc[
        dados["condicao"].astype(bool),
        "peso",
    ].sum()
    denominador = dados["peso"].sum()
    return 100 * numerador / denominador
