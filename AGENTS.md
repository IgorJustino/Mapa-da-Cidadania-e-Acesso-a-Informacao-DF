# Instrucoes do Projeto

## Contexto obrigatorio

- Antes de modificacoes relevantes no projeto, consulte `PRD.md`.
- Use o PRD como referencia para contrato da Silver, prioridades, arquitetura alvo, testes, PostgreSQL, Gold e criterios de aceite.
- Se o PRD entrar em conflito com o estado real do codigo ou dos dados, sinalize a divergencia antes de alterar o projeto.
- Para tarefas pequenas e localizadas, consulte ao menos a secao relevante do PRD.

## Comandos

- Prefixe comandos de shell com `rtk`, conforme `/home/iggor/.codex/RTK.md`.

## Principios praticos

- Preserve a RAW como imutavel.
- Evite overengineering; extraia codigo para `src/` apenas quando proteger regra critica, reduzir duplicacao real ou melhorar testabilidade.
- Mudancas na Silver devem preservar ou atualizar conscientemente o contrato da Secao 8 do `PRD.md`.
- Ao alterar dados ou transformacoes, execute validacoes proporcionais ao risco da mudanca e reporte os resultados.
