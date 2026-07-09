SILVER_COLUMNS = [
    "ano",
    "regiao_administrativa",
    "ano_referencia_pdad",
    "populacao_total",
    "populacao_masculina",
    "populacao_feminina",
    "populacao_0_14",
    "populacao_15_59",
    "populacao_60_mais",
    "renda_media_ponderada",
    "idade_media_ponderada",
    "media_moradores_por_domicilio",
    "percentual_baixa_escolaridade",
    "percentual_domicilios_com_internet",
    "percentual_domicilios_proprios",
    "percentual_domicilios_alugados",
    "lai_df_qtd_pedidos_ano",
    "lai_df_qtd_recursos_ano",
    "lai_df_qtd_satisfacoes_ano",
    "lai_df_percentual_pedidos_com_recurso",
    "lai_df_tempo_medio_resposta_dias",
    "lai_df_percentual_acesso_concedido",
    "lai_df_percentual_acesso_negado",
    "lai_df_percentual_acesso_parcial",
    "lai_df_percentual_sem_resposta",
    "lai_df_qtd_orgaos_demandados",
]


SILVER_CONTRACT = {
    "quantidade_ras": 33,
    "anos_esperados": {2023, 2024, 2025},
    "quantidade_linhas_esperada": 99,
    "quantidade_colunas_esperada": 26,
    "ano_referencia_pdad": 2024,
    "chave": [
        "regiao_administrativa",
        "ano",
    ],
}


CAMPOS_CRITICOS = [
    "regiao_administrativa",
    "ano",
    "ano_referencia_pdad",
    "populacao_total",
    "renda_media_ponderada",
    "idade_media_ponderada",
    "media_moradores_por_domicilio",
    "percentual_baixa_escolaridade",
    "percentual_domicilios_com_internet",
    "percentual_domicilios_proprios",
    "percentual_domicilios_alugados",
    "lai_df_qtd_pedidos_ano",
    "lai_df_qtd_recursos_ano",
    "lai_df_percentual_pedidos_com_recurso",
]
