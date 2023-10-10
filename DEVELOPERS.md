informações para desenvolvedores e contribuidores do code climate cli.

## mudanças locais de testes

construir uma nova imagem utilizando as fontes locais:

```console
make image
```

se você já tem o cli instalado, o wrapper `codeclimate` irá automaticamente utilizar essa imagem:

```console
codeclimate version
```

caso contrário, invocar o comando `docker run` encontrado no readme.

## lançando uma nova versão

### pré-requisitos

1. ser dono de uma [gema codeclimate](https://rubygems.org/gems/codeclimate) e autenticar com `gem push`
1. clonar [homebrew-formulae](https://github.com/codeclimate/homebrew-formulae)

prepare e abra um pull request com a versão:

```console
bin/prep-release VERSION
```

assim que merged, lançar isso:

```console
bin/release
```
