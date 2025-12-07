# Super promo

Um aplicativo Flutter que permite aos usuários visualizar mercados e suas promoções, e aos mercados gerenciar suas ofertas.

## Funcionalidades

### Para Usuários Comuns
- 🏪 Visualizar lista de mercados cadastrados
- 🛒 Ver promoções de cada mercado
- 🔍 Navegar pelos produtos em oferta
- 📱 Interface intuitiva e amigável

### Para Mercados
- 📝 Cadastro completo do mercado
- ➕ Criar promoções com imagens
- ✏️ Editar promoções existentes
- 🗑️ Excluir promoções
- 📊 Dashboard com estatísticas
- 📅 Definir validade das promoções

## Tecnologias Utilizadas

- **Flutter**: Framework principal
- **MobX**: Gerenciamento de estado reativo
- **Flutter Modular**: Navegação e injeção de dependências
- **Firebase Auth**: Autenticação de usuários
- **Firestore**: Banco de dados NoSQL
- **Firebase Storage**: Armazenamento de imagens

## Estrutura do Projeto

```
lib/
├── core/
│   ├── models/         # Modelos de dados
│   ├── services/       # Serviços (Firebase, etc.)
│   └── stores/         # Stores MobX
└── features/
    ├── auth/           # Telas de autenticação
    ├── mercado/        # Telas relacionadas a mercados
    ├── promocao/       # Telas de promoções
    └── splash/         # Tela inicial

```

## Configuração do Firebase

1. Crie um projeto no [Firebase Console](https://console.firebase.google.com)
2. Adicione um app Flutter ao projeto
3. Utilize o flutterfire_cli para configurar o projeto

4. Configure os serviços:
   - **Authentication**: Habilite login com email/senha
   - **Firestore**: Crie um banco de dados
   - **Storage**: Para upload de imagens

## Estrutura do Banco de Dados (Firestore)

### Collection: mercados
```json
{
  "id": "string",
  "nome": "string",
  "cnpj": "string", 
  "email": "string",
  "endereco": "string",
  "imagem": "string"
}
```

### Collection: promocoes
```json
{
  "id": "string",
  "customer_id": "string",
  "nome": "string",
  "preco": "number",
  "unidade": "string",
  "validade": "timestamp",
  "limite": "boolean",
  "promocao": "boolean",
  "imagem": "string"
}
```

### Collection: usuarios
```json
{
  "id": "string",
  "email": "string",
  "nome": "string",
  "tipo": "string",
  "mercado_id": "string",
  "data_criacao": "timestamp"
}
```

## Como Executar

1. **Clone o repositório**
```bash
git clone <url-do-repositorio>
cd mercado_promocoes_app
```

2. **Instale as dependências**
```bash
flutter pub get
```

3. **Configure o Firebase** 
```bash
firebase init

dart pub global activate flutterfire_cli

flutterfire configure
```

4. **Gere os arquivos MobX**
```bash
flutter packages pub run build_runner build
```

5. **Execute o app**
```bash
flutter run
```

## Arquitetura

O app segue os princípios de **Clean Architecture** e **SOLID**:

- **MobX**: Para gerenciamento de estado reativo
- **Modular**: Para organização modular e injeção de dependências
- **Services**: Camada de integração com APIs externas (Firebase)
- **Stores**: Lógica de negócio e estado da aplicação
- **Models**: Representação dos dados

## Dependências Principais

```yaml
dependencies:
  flutter_mobx: ^2.2.0      # Estado reativo
  flutter_modular: ^6.4.1   # Modularização
  firebase_core: ^3.6.0     # Firebase base
  firebase_auth: ^5.3.3     # Autenticação
  cloud_firestore: ^5.4.0   # Banco de dados
  firebase_storage: ^12.3.0 # Storage de imagens
  google_fonts: ^6.2.0      # Fontes
  cached_network_image: ^3.4.1 # Cache de imagens
  image_picker: ^1.1.2      # Seleção de imagens
```

## Licença

Este projeto está sob a licença MIT - veja o arquivo [LICENSE](LICENSE) para detalhes.


