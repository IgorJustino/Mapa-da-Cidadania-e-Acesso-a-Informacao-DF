# Baseline da Camada Silver

## Estado de referência

A camada Silver está consolidada no arquivo:

`Data Layer/silver/tb_mapa_cidadania_ra_ano_silver.csv`

## Granularidade

1 linha = 1 Região Administrativa + 1 ano.

## Chave lógica

- `regiao_administrativa`
- `ano`

## Contrato atual

| Métrica | Valor |
|---|---:|
| Linhas | 99 |
| Colunas | 26 |
| Regiões Administrativas | 33 |
| Anos | 2023, 2024, 2025 |
| Ano de referência da PDAD | 2024 |
| Duplicidades RA + ano | 0 |
| Valores vazios | 0 |

## Fontes integradas

### PDAD-A 2024

Utilizada como fotografia socioeconômica territorial de referência.

### Projeções populacionais

Utilizadas no nível Região Administrativa + ano.

### Participa DF / LAI

Utilizada no nível Distrito Federal + ano, sem territorialização artificial por Região Administrativa.

## Validações

A BigTable deve manter:

- exatamente 33 RAs;
- lista nominal exata de 33 RAs, com nomes canônicos legíveis;
- exatamente 99 combinações RA + ano enquanto o período permanecer 2023–2025;
- exatamente 26 colunas enquanto o contrato atual permanecer válido;
- nenhuma duplicidade na chave lógica;
- nenhum valor vazio;
- `ano_referencia_pdad = 2024`;
- indicadores LAI constantes entre todas as RAs do mesmo ano.

## Status

Baseline aprovada para início da implementação de testes automatizados.
