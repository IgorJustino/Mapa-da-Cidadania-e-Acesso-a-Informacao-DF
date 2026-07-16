#!/bin/sh
set -eu

export PYTHONPATH=/opt/mapa_cidadania
export SILVER_PATH=/opt/mapa_cidadania/silver/tb_mapa_cidadania_ra_ano_silver.csv

python3 /opt/mapa_cidadania/scripts/build_gold.py
