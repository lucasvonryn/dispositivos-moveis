# Solicitações UTFPR

## 1. Passos para instalação, configuração e execução

### Pré-requisitos

- [Flutter SDK](https://docs.flutter.dev/get-started/install) 3.x
- Android Studio, com um emulador Android criado (API 24 ou superior)
- Um binário do PocketBase 0.40.4, correspondente ao seu sistema

### PocketBase

Na pasta `pocketbase/` já estão as migrations do banco (`pb_migrations/`). Baixe o binário e deixe-o nessa mesma pasta. Ele não entra no Git.


| Sistema             | Arquivo                                                                                                                                       |
| ------------------- | --------------------------------------------------------------------------------------------------------------------------------------------- |
| macOS Apple Silicon | [pocketbase_0.40.4_darwin_arm64.zip](https://github.com/pocketbase/pocketbase/releases/download/v0.40.4/pocketbase_0.40.4_darwin_arm64.zip)   |
| macOS Intel         | [pocketbase_0.40.4_darwin_amd64.zip](https://github.com/pocketbase/pocketbase/releases/download/v0.40.4/pocketbase_0.40.4_darwin_amd64.zip)   |
| Linux x64           | [pocketbase_0.40.4_linux_amd64.zip](https://github.com/pocketbase/pocketbase/releases/download/v0.40.4/pocketbase_0.40.4_linux_amd64.zip)     |
| Windows x64         | [pocketbase_0.40.4_windows_amd64.zip](https://github.com/pocketbase/pocketbase/releases/download/v0.40.4/pocketbase_0.40.4_windows_amd64.zip) |


```bash
cd pocketbase
unzip pocketbase_0.40.4_darwin_arm64.zip
chmod +x pocketbase

./pocketbase superuser upsert admin@utfpr.local 123456789
./pocketbase serve
```

No Windows, o executável é `pocketbase.exe` e o `chmod` não é necessário. O comando `serve` precisa ser rodado **dentro** da pasta `pocketbase`, para carregar as migrations.

Na primeira execução o PocketBase cria `pb_data/`, aplica as coleções `users`, `solicitacoes` e `comentarios` e grava os usuários de teste. Deixe esse terminal aberto.

- Saúde da API: [http://127.0.0.1:8090/api/health](http://127.0.0.1:8090/api/health)
- Painel admin: [http://127.0.0.1:8090/_/](http://127.0.0.1:8090/_/)

O emulador Android alcança o PocketBase da máquina em `http://10.0.2.2:8090`. O manifesto Android libera HTTP local (`usesCleartextTraffic`).

### Aplicativo

Em outro terminal, na raiz do projeto:

```bash
flutter pub get
flutter emulators
flutter emulators --launch <id-do-emulador>
flutter run
```

Para listar aparelhos já ligados: `flutter devices`.

### Localização e câmera no emulador

A solicitação só é salva se o app conseguir a posição atual.

1. No emulador, abra os controles estendidos (os três pontos).
2. Em **Location**, envie uma coordenada. Um ponto em Curitiba, por exemplo: latitude `-25.4284`, longitude `-49.2733`.
3. A câmera do emulador é virtual. Ao tocar em **Tirar Foto**, confirme a captura na tela da câmera emulada.

## 2. Dados e informações para o teste

Abra o app no emulador. A primeira tela é o login. Toque em uma conta de demonstração para preencher e-mail e senha, ou digite os dados abaixo.


| Nome            | E-mail                                            | Senha  |
| --------------- | ------------------------------------------------- | ------ |
| Lucas Von Ryn   | [lucas@utfpr.edu.br](mailto:lucas@utfpr.edu.br)   | 123456 |
| Ewelin Komechen | [ewelin@utfpr.edu.br](mailto:ewelin@utfpr.edu.br) | 123456 |


Há também o botão **Criar conta** para registrar outro usuário (nome, e-mail e senha de pelo menos 6 caracteres).

Painel do PocketBase, para inspecionar os registros:


| Campo  | Valor                                                |
| ------ | ---------------------------------------------------- |
| URL    | [http://127.0.0.1:8090/_/](http://127.0.0.1:8090/_/) |
| E-mail | [admin@utfpr.local](mailto:admin@utfpr.local)        |
| Senha  | 123456789                                            |


O app, no emulador, fala com `http://10.0.2.2:8090`. Não há chave de API separada: o acesso é o e-mail e a senha de cada usuário, e o superusuário acima para o painel.

Como exercitar o fluxo:

1. Entre com o Lucas. Se ninguém tiver cadastrado nada, a home mostra **Ainda não há solicitações realizadas**.
2. Toque no **+** da barra **Solicitações Públicas**, preencha título e descrição, tire uma foto e toque em **Cadastrar**. O app grava latitude, longitude, data e o nome de quem enviou, e volta para a lista. O item mais recente fica no topo.
3. Abra a solicitação. A tela mostra foto, texto, autor, data e coordenadas. Quem criou o registro vê **Editar** e **Excluir**.
4. O botão flutuante abre um alerta com o texto do comentário e os botões **Salvar** e **Cancelar**. Entre com a Ewelin e comente a solicitação do Lucas para ver o comentário de outro usuário.

## 3. Outras informações relevantes

### Estrutura

```
lib/
  main.dart
  app_state.dart
  config/pocketbase_config.dart
  models/
  pages/
  repositories/
  routes/
pocketbase/
  pb_migrations/
```

### Permissões Android

O manifesto pede internet, câmera e localização. Se a pessoa negar a câmera, o app avisa e permanece no formulário. Se negar a localização, ou se o GPS do emulador estiver desligado, o cadastro não é concluído e uma mensagem pede para ativar a localização. A foto é obrigatória.

### Regras do banco

- Só entra na lista quem está autenticado.
- Qualquer usuário logado cria solicitação e comentário.
- Só o autor edita ou exclui a própria solicitação.
- A data usada na ordenação é o campo automático `created`.

### Se o app não carregar a lista

Confirme que `./pocketbase serve` está rodando na pasta `pocketbase` e que o emulador usa o endereço `http://10.0.2.2:8090`. A home mostra o erro de conexão e o botão **Tentar de novo**.