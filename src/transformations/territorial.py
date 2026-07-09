import re
import unicodedata

import pandas as pd


ALIASES_REGIAO_ADMINISTRATIVA = {
    "sudoeste octogonal": "Sudoeste e Octogonal",
    "sudoeste e octogonal": "Sudoeste e Octogonal",
    "sol nascente por do sol": "Sol Nascente/Por do Sol",
    "sol nascente por-do-sol": "Sol Nascente/Por do Sol",
}


def remover_acentos(texto):
    if pd.isna(texto):
        return texto
    return "".join(
        caractere
        for caractere in unicodedata.normalize("NFKD", str(texto))
        if not unicodedata.combining(caractere)
    )


def normalizar_texto_territorial(texto) -> str:
    if pd.isna(texto):
        return texto

    normalizado = remover_acentos(texto).lower().strip()
    normalizado = re.sub(r"[^a-z0-9]+", " ", normalizado)
    normalizado = re.sub(r"\s+", " ", normalizado).strip()
    return normalizado


def normalizar_regiao_administrativa(nome):
    chave = normalizar_texto_territorial(nome)
    if pd.isna(chave):
        return pd.NA

    return ALIASES_REGIAO_ADMINISTRATIVA.get(chave, str(nome).strip())


def normalizar_chave_regiao_administrativa(nome):
    nome_canonico = normalizar_regiao_administrativa(nome)
    return normalizar_texto_territorial(nome_canonico)
