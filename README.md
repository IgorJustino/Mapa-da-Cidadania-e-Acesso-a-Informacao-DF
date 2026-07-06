# Mapa da Cidadania e Acesso a Informacao DF

Projeto em arquitetura medalhao para exploracao e transformacao de dados de PDAD, LAI/Participa DF e projecoes populacionais.

## Como rodar o analytics

Crie e ative o ambiente virtual:

```bash
python3 -m venv .venv
source .venv/bin/activate
python -m pip install -r requirements.txt
python -m ipykernel install --prefix .venv --name mapa-cidadania --display-name "Mapa Cidadania (.venv)"
```

Abra o JupyterLab usando diretorios locais do projeto:

```bash
JUPYTER_CONFIG_DIR="$(pwd)/.jupyter" \
JUPYTER_DATA_DIR="$(pwd)/.jupyter/data" \
JUPYTER_RUNTIME_DIR="$(pwd)/.jupyter/runtime" \
IPYTHONDIR="$(pwd)/.ipython" \
.venv/bin/jupyter lab --no-browser
```

Depois abra `Data Layer/raw/analytics.ipynb` e selecione o kernel `Mapa Cidadania (.venv)`.

## Validacao por linha de comando

Para executar todas as celulas e gerar uma copia executada:

```bash
JUPYTER_CONFIG_DIR="$(pwd)/.jupyter" \
JUPYTER_DATA_DIR="$(pwd)/.jupyter/data" \
JUPYTER_RUNTIME_DIR="$(pwd)/.jupyter/runtime" \
IPYTHONDIR="$(pwd)/.ipython" \
.venv/bin/jupyter nbconvert --to notebook --execute "Data Layer/raw/analytics.ipynb" --output "analytics.executed.ipynb" --ExecutePreprocessor.kernel_name=mapa-cidadania --ExecutePreprocessor.timeout=300
```
