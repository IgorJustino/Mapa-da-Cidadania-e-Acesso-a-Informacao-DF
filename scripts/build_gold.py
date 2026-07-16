from pathlib import Path
import sys
import os

import pandas as pd
import psycopg


ROOT_DIR = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT_DIR))

from src.transformations.gold import carregar_gold_postgres, construir_gold

SILVER_PATH = Path(
    os.getenv(
        "SILVER_PATH",
        str(
            ROOT_DIR
            / "Data Layer"
            / "silver"
            / "tb_mapa_cidadania_ra_ano_silver.csv"
        ),
    )
)


def get_connection():
    conn_kwargs = {
        "dbname": os.getenv("POSTGRES_DB", "mapa_cidadania"),
        "user": os.getenv("POSTGRES_USER", "mapa_cidadania_user"),
        "password": os.getenv("POSTGRES_PASSWORD", "mapa_cidadania_pass"),
    }
    if os.getenv("PGHOST"):
        conn_kwargs["host"] = os.getenv("PGHOST")
    if os.getenv("PGPORT"):
        conn_kwargs["port"] = os.getenv("PGPORT")

    return psycopg.connect(**conn_kwargs)


def main() -> None:
    df_silver = pd.read_csv(SILVER_PATH, encoding="utf-8-sig")
    tabelas_gold = construir_gold(df_silver)

    with get_connection() as conn:
        carregar_gold_postgres(tabelas_gold, conn)

    for nome_tabela, df in tabelas_gold.items():
        print(f"{nome_tabela}: {len(df)} linhas carregadas no PostgreSQL")


if __name__ == "__main__":
    main()
