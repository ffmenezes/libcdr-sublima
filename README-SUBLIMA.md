# libcdr — fork do Sublima Editor

Este repositório é o código-fonte do **libcdr 0.1.9** (Document Liberation Project / LibreOffice,
https://github.com/LibreOffice/libcdr) com as modificações feitas pela **Ingencia Desenvolvimento** para o
**Sublima Editor** (https://www.sublimadigital.com.br), um editor de artes para sublimação que abre arquivos `.cdr`
do CorelDRAW. É publicado para cumprir a **Mozilla Public License 2.0** (seção 3.2: quem distribui o binário
disponibiliza o fonte dos arquivos cobertos, com as modificações). A licença está em `COPYING.MPL`; os cabeçalhos
originais foram mantidos em todos os arquivos.

## O que foi modificado

Toda mudança está marcada com um comentário `// Sublima:` e o diff completo contra o upstream 0.1.9 está em
`sublima/sublima-0.1.9.diff` (1.124 linhas). Em resumo, em `src/lib/`:

- `CDRParser.cpp/.h`, `CDRTypes.h`, `CDRCollector.h`, `CDRContentCollector.cpp/.h`: leitura de sombra projetada,
  transparência de objeto (X6+), máscara de transparência 8 bits, tabela de vínculos (sombra → objeto, texto → curva),
  texto em curva, canto arredondado aproximado por cúbica, PowerClip (referência ao conteúdo);
- `CDROutputElementList`, `CDRPath`, `CDRStylesCollector`, `CMXParser`: ajustes decorrentes;
- `configure.ac` e `src/fuzz/`: só o build (sem `-Werror`, fuzzers fora).

## Metodologia (interoperabilidade)

As modificações foram feitas **sem** qualquer binário, SDK, biblioteca, cabeçalho ou documentação da Corel. O que
se usou: arquivos `.cdr` criados pelos próprios autores no CorelDRAW 2020 e os PDFs/SVGs exportados por ele dos
mesmos arquivos, comparando a saída do libcdr com a saída esperada (ex.: parâmetros da sombra projetada, calibrados
contra o PDF exportado). É a mesma abordagem clean-room do projeto upstream. O Sublima Editor **não é afiliado à
Corel Corporation**; CorelDRAW é marca da Corel.

## Como o binário é gerado

O Sublima Editor compila este fork com **Emscripten 3.1.6** para JavaScript puro (`cdrjs.js`), junto com:

| componente | versão | licença | fonte usada (pinada por sha256 no CI) |
|---|---|---|---|
| librevenge | 0.0.5 (sem modificação) | MPL 2.0 / LGPL 2.1+ | `librevenge_0.0.5.orig.tar.bz2` do pool do Ubuntu noble (http://archive.ubuntu.com/ubuntu/pool/main/libr/librevenge/), sha256 `5892ca6796f7a2a93d580832e907e849b19d980b40d326a283b18877ab6de0c5`; espelho upstream: https://sourceforge.net/projects/libwpd/files/librevenge/ |
| zlib | 1.3 | zlib | `zlib_1.3.dfsg.orig.tar.xz` do pool do noble, sha256 `5eea0322c1c21c75cad3b607ac1c43ff5c71e014b8ac4a34300b5e2b80d02e70` |
| LittleCMS | 2.16 | MIT | https://github.com/mm2/Little-CMS commit `453bafeb85b4ef96498866b7a8eadcc74dff9223` |
| Boost (só headers) | do noble | BSL-1.0 | pacote `libboost-dev` |
| ICU | substituído | — | `sublima/wasm/icushim/`: reimplementação mínima da API usada pelo libcdr (conversão cp125x/UTF-16), código próprio, MPL 2.0 aqui |

`sublima/wasm/build.sh` é o script de compilação e `sublima/importador.yml` é o workflow do CI do editor que o
executa, com os pins acima. O `cdrjs.cpp` que o script cita é a cola do editor com o leitor (código do editor, não
coberto pela MPL, não incluído aqui); sem ele, `build.sh` gera os objetos de todas as bibliotecas e basta ligar
com um `main` próprio.

## Licença

MPL 2.0 (`COPYING.MPL`), como o upstream. Contribuições para o upstream são bem-vindas; este fork não pretende
divergir mais do que o necessário para o editor.
