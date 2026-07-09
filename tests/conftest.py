from pathlib import Path

import pandas as pd
import pytest


ROOT_DIR = Path(__file__).resolve().parents[1]

SILVER_PATH = (
    ROOT_DIR
    / "Data Layer"
    / "silver"
    / "tb_mapa_cidadania_ra_ano_silver.csv"
)


@pytest.fixture(scope="session")
def df_silver() -> pd.DataFrame:
    """Carrega a BigTable Silver utilizada pelos testes de qualidade."""

    if not SILVER_PATH.exists():
        raise FileNotFoundError(
            f"Arquivo Silver não encontrado: {SILVER_PATH}"
        )

    return pd.read_csv(SILVER_PATH)
