# PRD — Evolução do Mapa da Cidadania e Acesso à Informação DF

## Engenharia de Software, Qualidade de Dados, PostgreSQL e Evolução para a Camada Gold

| Campo | Valor |
|---|---|
| Versão do documento | 2.0 |
| Data | 2026-07-09 |
| Autor | Igor Justino |
| Status | Ativo — reflete o estado real do projeto |
| Repositório | https://github.com/IgorJustino/Mapa-da-Cidadania-e-Acesso-a-Informacao-DF |

> **Nota de versão:** esta versão consolida referências repetidas do documento anterior (o contrato da Silver passa a ser citado, não reafirmado, em cada seção), adiciona a lista explícita das 26 colunas, os campos críticos de nulidade, uma nota de conformidade LGPD, estimativas de duração dos sprints e um requisito de observabilidade. Nenhuma decisão de arquitetura ou prioridade foi alterada.

---

## 1. Público-Alvo deste Documento

Este PRD serve três públicos:

- **Você mesmo**, como guia de decisão durante o desenvolvimento (evita retrabalho e decisões ad-hoc).
- **Avaliadores/recrutadores**, como evidência de maturidade em Engenharia de Dados e Software.
- **Colaboradores futuros**, caso o projeto seja aberto a contribuições.

Por isso o documento é técnico e denso — não é um PRD voltado a stakeholders de negócio não-técnicos.

---

## 2. Visão Geral

### Estado atual do projeto

Pipeline funcional em arquitetura:

```text
RAW → SILVER → GOLD
```

**RAW** contém três famílias de fontes públicas:

1. **PDAD-A 2024** — base de moradores, base de domicílios, dicionário de variáveis.
2. **Participa DF / LAI** — pedidos de acesso à informação, recursos, avaliações de satisfação, recursos auxiliares.
3. **Projeções Populacionais por RA** — 2020–2030, por RA, sexo e faixa etária.

**SILVER** já está implementada e consolidada em uma única BigTable:

```text
Data Layer/silver/tb_mapa_cidadania_ra_ano_silver.csv
```

Granularidade: `1 linha = 1 Região Administrativa + 1 ano`. O contrato completo está na **Seção 8** — todas as demais seções deste documento fazem referência a ele em vez de repeti-lo.

---

## 3. Contexto e Motivação

O projeto deixou de ser uma análise exploratória de arquivos públicos. Já possui: múltiplas fontes heterogêneas, tratamento de CSV/XLSX, padronização territorial, cálculos ponderados da PDAD, agregações populacionais, indicadores de LAI, BigTable consolidada, validações, DDL e consultas SQL.

Porém, parte relevante das regras de transformação ainda está concentrada em notebooks. Notebooks são adequados para exploração, narrativa e apresentação — mas manter regras críticas apenas neles, à medida que o projeto avança para PostgreSQL, Gold e dashboards, aumenta o risco de regressões silenciosas, duplicação de lógica, dificuldade de teste e alterações acidentais em regras já validadas.

---

## 4. Problema

### 4.1 Problema de negócio e dados

Dados sobre condições socioeconômicas, população, território e acesso à informação pública estão distribuídos em fontes com schemas, nomenclaturas, granularidades e formatos distintos — dificultando uma visão territorial única e confiável das RAs do DF.

### 4.2 Problema técnico

Sem uma camada mínima de código modular e testes automatizados, mudanças futuras podem causar: perda ou duplicação de RA+ano, alteração incorreta de aliases territoriais, nulos críticos, distorção de pesos da PDAD, erro em percentuais ponderados, mudança silenciosa de schema, população inconsistente ou quebra da BigTable. Várias dessas condições já são verificadas manualmente no ETL — o objetivo aqui é transformar isso em **contratos e testes automatizados**.

---

## 5. Problema Central

> Como evoluir o pipeline atual para uma solução mais confiável, testável, modular e preparada para PostgreSQL, Gold e consumo analítico, **sem** introduzir complexidade artificial ou atrasar excessivamente a entrega do produto final?

---

## 6. Objetivo Geral

Evoluir o projeto combinando Engenharia de Dados + Engenharia de Software + Qualidade de Dados + PostgreSQL + Modelagem Analítica + Automação — protegendo as regras já corretas da Silver, modularizando apenas a lógica crítica, e preparando o terreno para PostgreSQL, Gold, dashboard e CI.

---

## 7. Solução Proposta

O projeto **não** será reescrito do zero. Fluxo:

```text
Pipeline Silver funcional → Baseline documentada → Testes das regras críticas
→ Contrato da Silver → Modularização seletiva → Carga no PostgreSQL
→ Camada Gold → Testes de integração → GitHub Actions → Dashboard/Produto Analítico
```

**Decisão arquitetural central:** não transformar a refatoração em um fim em si mesma. A Silver já funciona e tem boa qualidade; a prioridade é proteger seus comportamentos críticos e seguir para PostgreSQL e Gold, evitando gastar sprints demais reorganizando código que já funciona.

**Por que é mais eficiente:** em vez de refatorar tudo → criar dezenas de abstrações → criar muitos testes → só então começar a Gold, o fluxo é identificar regra crítica → criar teste → extrair lógica reutilizável quando necessário → preservar o pipeline funcionando → avançar. Isso reduz risco de quebra, encurta o caminho até a Gold, foca testes no que importa e evita overengineering.

---

## 8. Contrato Atual da Silver (fonte única de verdade)

```python
SILVER_CONTRACT = {
    "granularidade": "regiao_administrativa + ano",
    "chave": ["regiao_administrativa", "ano"],
    "quantidade_ras": 33,
    "anos_esperados": [2023, 2024, 2025],
    "quantidade_linhas_esperada": 99,      # 33 RAs x 3 anos
    "quantidade_colunas_esperada": 26,
    "ano_referencia_pdad": 2024,
    "duplicidades_ra_ano": 0,
    "nulos_criticos": 0,
}
```

Todas as demais seções deste documento (requisitos, testes, roadmap, critérios de aceite) referenciam este contrato em vez de repetir os números.

### 8.1 As 26 colunas (especificação explícita)

> Lista reconstruída a partir das regras descritas nas seções de transformação (RF-04/05/06 e 10.2). **Valide contra o cabeçalho real do CSV antes de codificar o contrato** — se houver divergência, atualize esta tabela primeiro.

| # | Coluna | Origem |
|---|---|---|
| 1 | `regiao_administrativa` | Chave |
| 2 | `ano` | Chave |
| 3 | `ano_referencia_pdad` | PDAD |
| 4 | `renda_media_ponderada` | PDAD |
| 5 | `idade_media_ponderada` | PDAD |
| 6 | `media_moradores_por_domicilio` | PDAD |
| 7 | `percentual_baixa_escolaridade` | PDAD |
| 8 | `percentual_domicilios_com_internet` | PDAD |
| 9 | `percentual_domicilios_proprios` | PDAD |
| 10 | `percentual_domicilios_alugados` | PDAD |
| 11 | `populacao_total` | Projeções |
| 12 | `populacao_masculina` | Projeções |
| 13 | `populacao_feminina` | Projeções |
| 14 | `populacao_0_14` | Projeções |
| 15 | `populacao_15_59` | Projeções |
| 16 | `populacao_60_mais` | Projeções |
| 17 | `lai_df_qtd_pedidos_ano` | LAI (DF+ano) |
| 18 | `lai_df_qtd_recursos_ano` | LAI (DF+ano) |
| 19 | `lai_df_qtd_satisfacoes_ano` | LAI (DF+ano) |
| 20 | `lai_df_percentual_pedidos_com_recurso` | LAI (DF+ano) |
| 21 | `lai_df_tempo_medio_resposta_dias` | LAI (DF+ano) |
| 22 | `lai_df_percentual_acesso_concedido` | LAI (DF+ano) |
| 23 | `lai_df_percentual_acesso_negado` | LAI (DF+ano) |
| 24 | `lai_df_percentual_acesso_parcial` | LAI (DF+ano) |
| 25 | `lai_df_percentual_sem_resposta` | LAI (DF+ano) |
| 26 | `lai_df_qtd_orgaos_demandados` | LAI (DF+ano) |

### 8.2 Campos críticos para DQ-07 (nulos não permitidos)

```text
regiao_administrativa
ano
ano_referencia_pdad
populacao_total
lai_df_qtd_pedidos_ano
```

Demais colunas podem tolerar nulo apenas se a ausência for uma condição de negócio legítima (ex.: RA sem satisfações registradas no ano) — nesse caso, documentar a exceção em `src/quality/contracts.py`, não silenciá-la.

---

## 9. Decisões Metodológicas Consolidadas

### 9.1 PDAD
A PDAD-A 2024 é a fotografia socioeconômica de referência (`ano_referencia_pdad = 2024`). Os mesmos indicadores aparecem em 2023/2024/2025, mas a coluna explícita deixa clara a origem.

### 9.2 Participa DF / LAI
LAI não tem RA confiável → **não** cruzar LAI × RA. Indicadores agregados em `DF + ano`, prefixo `lai_df_` (ver lista completa na Seção 8.1). Valores podem se repetir entre as 33 RAs de um mesmo ano porque representam contexto anual do DF, não medida territorial da RA.

### 9.3 Alias territorial
`Sudoeste_Octogonal` (projeções) ↔ `Sudoeste e Octogonal` (PDAD) resolvido por alias explícito centralizado — sem algoritmos de resolução de entidades.

### 9.4 Percentuais ponderados da PDAD
Valores ausentes são excluídos do denominador antes do cálculo. Protege: `percentual_baixa_escolaridade`, `percentual_domicilios_com_internet`, `percentual_domicilios_proprios`, `percentual_domicilios_alugados`.

### 9.5 Recursos da LAI
Métrica correta: **percentual de pedidos únicos com pelo menos um recurso** — não `total_recursos / total_pedidos`. Requer teste automatizado dedicado.

---

## 10. Conformidade com a LGPD

A PDAD-A coleta dados socioeconômicos de moradores. Ainda que a Silver já opere em granularidade agregada (RA + ano, sem microdados individuais), o projeto deve documentar explicitamente:

- Nenhum dado pessoal identificável (nome, CPF, endereço exato) entra na RAW deste projeto — apenas microdados já anonimizados/agregados pela fonte pública (CODEPLAN).
- A camada RAW deve ser tratada como dado público, mas isso não dispensa checar, ao incorporar novas fontes, se algum campo permite reidentificação por combinação de atributos (ex.: RA pequena + faixa etária rara + renda específica).
- Caso o produto final (dashboard) seja publicado, reforçar que nenhuma granularidade abaixo de RA + ano é exposta.

Isso não altera o roadmap técnico, mas deve constar como item de checklist antes da publicação do produto analítico (Seção 22, novo item).

---

## 11. Estado Atual da Arquitetura

```text
Mapa-da-Cidadania-e-Acesso-a-Informacao-DF/
├── Data Layer/
│   ├── raw/{pdad, participa_lai, projecoes_populacionais, analytics.ipynb}
│   ├── silver/{analytics.ipynb, consultas.sql, ddl.sql, tb_mapa_cidadania_ra_ano_silver.csv}
│   └── gold/
├── Transformer/
│   ├── analytics_raw.ipynb
│   ├── etl_raw_to_silver.ipynb
│   └── etl_silver_to_gold.ipynb
├── Dockerfile
├── docker-compose.yml
├── requirements.txt
├── .gitignore
└── README.md
```

## 12. Arquitetura Alvo Imediata

```text
Mapa-da-Cidadania-e-Acesso-a-Informacao-DF/
├── Data Layer/{raw, silver, gold}
├── src/
│   ├── io/readers.py
│   ├── transformations/{territorial.py, pdad.py, populacao.py, lai.py}
│   └── quality/{contracts.py, validators.py}
├── tests/
│   ├── unit/{test_territorial.py, test_pdad.py, test_lai.py}
│   ├── quality/test_silver_quality.py
│   └── integration/test_raw_to_silver.py
├── Transformer/ (mantém os notebooks)
├── .github/workflows/tests.yml
├── pytest.ini
├── requirements.txt
├── Dockerfile
├── docker-compose.yml
└── README.md
```

---

## 13. Princípios de Desenvolvimento

1. **Não fazer overengineering** — sem classes/Design Patterns/Union-Find/microserviços sem necessidade concreta.
2. **Funções antes de classes** — `normalizar_regiao_administrativa(nome)`, não `RegiaoAdministrativaNormalizerFactoryManager`.
3. **Notebooks permanecem** para análise, narrativa e demonstração; lógica crítica é progressivamente extraída para `src/`.
4. **Não extrair funções artificiais** — só extrair o que tiver regra de negócio, risco de regressão, cálculo crítico ou necessidade real de teste unitário.
5. **RAW é imutável** — transformações só ocorrem nas etapas posteriores.

---

## 14. Requisitos Funcionais

| ID | Requisito |
|---|---|
| RF-01 | Carregar CSV/XLSX (múltiplas abas quando necessário); tratar arquivo inexistente, vazio, extensão não suportada, schema inesperado. |
| RF-02 | Normalizar nomes de coluna (acentos, minúsculas, espaços → underscore, sem underscores duplicados). |
| RF-03 | Normalizar territorial via aliases centralizados (ex.: Sudoeste_Octogonal). |
| RF-04 | Transformar PDAD preservando os cálculos ponderados críticos (Seção 9.4); pesos inválidos/códigos especiais não podem distorcer resultado. |
| RF-05 | Transformar população por RA+ano (total, masculina, feminina, faixas etárias). |
| RF-06 | Transformar LAI mantendo granularidade DF+ano — não territorializar por RA. |
| RF-07 | Construir a BigTable Silver respeitando o contrato da Seção 8 enquanto ele for válido. |
| RF-08 | Tornar a BigTable carregável em PostgreSQL via `Data Layer/silver/ddl.sql`, com schema compatível com o CSV do ETL. |

---

## 15. Requisitos de Qualidade de Dados

Todos referenciam o `SILVER_CONTRACT` (Seção 8).

| ID | Regra |
|---|---|
| DQ-01 | `regiao_administrativa.nunique() == quantidade_ras` |
| DQ-02 | `linhas == quantidade_ras * quantidade_anos` |
| DQ-03 | Colunas == `quantidade_colunas_esperada` (atualizar conscientemente se o contrato evoluir) |
| DQ-04 | Sem duplicidade em `regiao_administrativa + ano` |
| DQ-05 | Anos == `anos_esperados` |
| DQ-06 | `ano_referencia_pdad.unique() == {2024}` |
| DQ-07 | Campos críticos (Seção 8.2) sem nulos |
| DQ-08 | Colunas de população `>= 0` |
| DQ-09 | Percentuais entre 0 e 100 |
| DQ-10 | Indicadores `lai_df_*` constantes dentro de cada ano (`nunique() == 1` por grupo `ano`) |
| DQ-11 | Toda RA presente pertence ao conjunto oficial de 33 RAs do contrato |

---

## 16. Testes Prioritários Obrigatórios

**Territoriais:** `test_normalizar_sudoeste_octogonal`, `test_alias_conhecido_retorna_nome_canonico`, `test_nome_valido_nao_e_alterado_incorretamente`

**PDAD:** `test_percentual_ponderado_ignora_nulos_no_denominador`, `test_media_ponderada_com_pesos_validos`, `test_codigo_especial_nao_entra_como_valor_real`

**LAI:** `test_percentual_pedidos_com_recurso_usa_pedidos_unicos`, `test_indicadores_lai_possuem_prefixo_lai_df`, `test_lai_permanece_no_nivel_df_ano`

**Qualidade da Silver:** um teste por regra DQ-01 a DQ-11 (Seção 15).

---

## 17. Estratégia de Testes

- **Unitários**: uma função isolada (ex.: `test_normalizar_sudoeste_octogonal`).
- **Parametrizados**: múltiplos casos de alias/normalização em uma função `pytest.mark.parametrize`.
- **Exceção**: arquivo inexistente, coluna obrigatória ausente, arquivo vazio, schema inválido.
- **Qualidade**: executados diretamente sobre a BigTable Silver atual — representam o contrato do dado.
- **Integração**: usar RAW reduzida controlada, não o dataset completo em todo teste.
- **Regressão**: proteger comportamentos já validados (33 RAs, alias Sudoeste/Octogonal, percentual ponderado, período 2023–2025, referência PDAD 2024, chave RA/ano, LAI DF+ano).

---

## 18. TDD

Aplicado preferencialmente a **novas regras e correções futuras** — não é necessário reescrever retroativamente o projeto todo em TDD.

```text
RED (teste falha) → GREEN (implementação mínima) → REFACTOR (mantendo testes verdes)
```

---

## 19. Cobertura de Testes

```bash
pytest --cov=src --cov-report=term-missing
```

Cobertura é indicador, não objetivo isolado. Prioridade: **100% das regras críticas protegidas** antes de perseguir percentual global. Meta orientativa inicial ≥70%, subindo para ≥80% após estabilização. Não criar testes sem valor só para inflar número.

---

## 20. PostgreSQL

```text
Silver validada → DDL → Carga PostgreSQL → Consultas SQL → Gold
```

A Silver já possui `ddl.sql`, `consultas.sql` e o CSV — etapa de baixo custo adicional e alto valor para portfólio.

---

## 21. Camada Gold

Desenhada somente após o contrato mínimo da Silver estar protegido e o PostgreSQL operacional (ou claramente preparado). Pode conter: `dim_tempo`, `dim_regiao_administrativa`, `fato_mapa_cidadania`, `mart_indicadores_territoriais`, `mart_acesso_informacao`.

Um índice composto (ex. `ITAC-DF`) só deve ser criado com metodologia justificável, respondendo: o que mede, por que cada variável participa, como são normalizadas, por que os pesos, como interpretar valores altos/baixos. Sem resposta sólida a essas perguntas, priorizar indicadores separados ou clusterização de RAs.

---

## 22. Produto Analítico Final

```text
Dados públicos → RAW → Silver validada → PostgreSQL → Gold → Dashboard → Insights territoriais
```

Opções: dashboard Power BI ou Streamlit, mapa por RA, ranking de indicadores, comparação entre RAs, evolução populacional, perfil socioeconômico, indicadores anuais de LAI, agrupamento de RAs semelhantes.

**Checklist de publicação (novo, decorrente da Seção 10):**
- [ ] Nenhuma granularidade abaixo de RA+ano é exposta no produto final.
- [ ] Fonte de cada dado (CODEPLAN/PDAD, Participa DF, projeções) está creditada visivelmente.

---

## 23. Requisitos Não Funcionais

| ID | Requisito |
|---|---|
| RNF-01 | Reprodutibilidade: `git clone` → `pip install -r requirements.txt` → `pytest` funciona sem passos ocultos. |
| RNF-02 | Legibilidade: nomes claros, funções pequenas quando apropriado, pouca duplicação. |
| RNF-03 | Testabilidade: regras críticas não dependem de ordem manual de células de notebook nem de estado oculto do kernel. |
| RNF-04 | Manutenibilidade: novo alias territorial exige mudança concentrada no módulo territorial e seus testes. |
| RNF-05 | Rastreabilidade: falha de qualidade informa regra violada, coluna, registros envolvidos e comportamento esperado. |
| RNF-06 *(novo)* | Observabilidade: cada execução do pipeline (ETL raw→silver→gold) registra log estruturado com etapa, linhas processadas, linhas rejeitadas e duração — mínimo viável antes de qualquer ferramenta de orquestração dedicada. |

---

## 24. Definition of Done

Uma transformação crítica está concluída quando: (1) implementada; (2) possui teste quando aplicável; (3) testes existentes seguem verdes; (4) não introduz regressão conhecida; (5) está no módulo adequado quando a extração se justifica; (6) entradas inválidas relevantes são tratadas; (7) documentação/contrato atualizados quando necessário.

---

## 25. Roadmap Atualizado

| Sprint | Objetivo | Duração estimada* |
|---|---|---|
| 0 | Baseline da Silver documentada (`docs/SILVER_BASELINE.md`, referenciando o contrato da Seção 8) | 2–3 dias |
| 1 | Pytest + testes das regras críticas (alias, percentual ponderado, pedidos únicos com recurso) | 1 semana |
| 2 | Contrato e Data Quality automatizados (Seção 15 completa) | 1 semana |
| 3 | Modularização seletiva (`src/transformations/*`, `src/quality/*`) | 1 semana |
| 4 | PostgreSQL: carga e consultas reproduzíveis | 3–5 dias |
| 5 | Camada Gold (modelagem dimensional) | 1–2 semanas |
| 6 | Testes de integração RAW→Silver→Gold | 3–5 dias |
| 7 | GitHub Actions (push/PR executam pytest + cobertura) | 1–2 dias |
| 8 | Dashboard / produto analítico final | 1–2 semanas |

\* Estimativas para dedicação parcial (projeto pessoal/portfólio); ajuste conforme disponibilidade real.

---

## 26. Critérios Gerais de Aceitação

- [ ] Baseline da Silver documentada
- [ ] `src/` e `tests/` existem; `pytest` executa corretamente
- [ ] Regras territoriais, cálculos ponderados e cálculo de recurso testados
- [ ] Contrato da Silver (Seção 8) automatizado, incluindo campos críticos (8.2)
- [ ] Checklist de conformidade LGPD (Seção 10) revisado antes de publicar o produto
- [ ] PostgreSQL operacional; Gold implementada
- [ ] Testes de integração existem; GitHub Actions executa os testes
- [ ] Produto analítico final disponível

---

## 27. Métricas de Sucesso

**Dados:** contrato da Seção 8 satisfeito; schema validado; pipeline reproduzível.
**Software:** pytest funcionando; regras críticas testadas; contrato automatizado; CI ativa.
**Banco:** Silver carregada no PostgreSQL; DDL versionado; consultas reproduzíveis.
**Produto:** Gold disponível; dashboard disponível; insights documentados.

---

## 28. Riscos e Mitigações

| Risco | Mitigação |
|---|---|
| Refatorar demais antes da Gold | Limitar refatoração pré-Gold a testes críticos + contrato + modularização seletiva; depois avançar. |
| Overengineering | Antes de cada abstração perguntar: reduz duplicação, protege regra crítica, melhora teste ou facilita manutenção? Se não, não criar. |
| Testes acoplados a detalhes internos | Testar comportamento ("dada entrada X, quando Y, então Z"), não implementação. |
| Cobertura como objetivo isolado | Priorizar 100% das regras críticas antes de percentual global arbitrário. |
| Testes lentos com arquivos reais | Usar DataFrames pequenos, fixtures e arquivos mínimos controlados. |
| Índice composto arbitrário (ex. ITAC-DF) | Não criar sem justificar variáveis, normalização, pesos e interpretação; usar indicadores separados/clusterização como alternativa. |
| *(novo)* Reidentificação por combinação de atributos ao incorporar nova fonte | Checar, a cada nova fonte, se granularidade + atributos raros permitem reidentificar indivíduos (Seção 10). |

---

## 29. Resultado Esperado para Portfólio

> Desenvolvimento de uma plataforma de Engenharia de Dados em arquitetura Medalhão para integração de dados públicos da PDAD-A 2024, Participa DF/LAI e projeções populacionais, consolidando indicadores das 33 Regiões Administrativas do DF em uma BigTable Silver com granularidade RA/ano. A solução incorpora cálculos ponderados, padronização territorial, contratos de dados, testes automatizados com pytest, PostgreSQL, modelagem Gold, integração contínua com GitHub Actions e produto analítico para exploração dos indicadores territoriais.

> Versão orientada a resultados: Construí um pipeline de Engenharia de Dados que integra três famílias de fontes públicas e consolida 99 combinações de RA e ano em uma BigTable Silver de 26 atributos, com regras de qualidade automatizadas para unicidade de chave, ausência de nulos críticos, consistência territorial, validade de percentuais, integridade populacional e correta representação temporal da PDAD e da LAI.

---

## 30. Prioridade de Execução

```text
1. Baseline da Silver → 2. pytest + testes críticos → 3. Contrato e Data Quality
→ 4. Modularização seletiva → 5. PostgreSQL → 6. Gold → 7. Testes de integração
→ 8. GitHub Actions → 9. Dashboard / produto analítico
```

Marcos de valor:
1. `pytest` comprova automaticamente que a Silver respeita o contrato da Seção 8.
2. Silver carregada no PostgreSQL com consultas reproduzíveis.
3. Camada Gold transformada em produto analítico consumível.

---

## 31. Conclusão

O objetivo não é tornar o projeto artificialmente complexo, e sim transformar um pipeline que já funciona em uma solução confiável, testável, modular, reproduzível, consultável e pronta para gerar produtos analíticos.

Priorizados: qualidade real, testes de regras críticas, contratos de dados, modularização seletiva, PostgreSQL, Gold, automação, produto final, e — nesta revisão — conformidade básica com LGPD e observabilidade mínima do pipeline.

Não priorizados sem justificativa concreta: classes artificiais, Design Patterns desnecessários, Union-Find, microserviços, arquitetura distribuída, Spark sem necessidade de escala, Airflow sem necessidade de orquestração, complexidade apenas para portfólio.

> **A Engenharia de Software deve aumentar a qualidade do projeto, não impedir que ele chegue à Gold, ao PostgreSQL e ao produto final.**