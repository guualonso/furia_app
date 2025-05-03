# FURIA App

Aplicativo Flutter com integração ao Firebase que oferece uma experiência em tempo real para fãs da FURIA Esports, com funcionalidades de autenticação, estatísticas de partidas e diferenciação entre plataformas Web e Android.

---

## 🔍 Visão Geral do Projeto

Este app fornece:
- Login com Google e registro personalizado
- Upload de documentos e selfie (somente Android)
- Acesso às estatísticas e partidas da FURIA
- Interface adaptada para Android e Web
- Dados reais consumidos via Firebase Firestore e Storage

---

## 🚀 Tecnologias Utilizadas

- Flutter (Dart)
- Firebase Authentication
- Firebase Firestore
- Firebase Storage
- Provider / Riverpod (dependendo da versão final)
- Widgets personalizados e responsivos
- `flutter_dotenv` para gerenciamento de variáveis de ambiente

---

## ⚙️ Configuração do Projeto

### Pré-requisitos

- Flutter instalado ([instruções oficiais](https://docs.flutter.dev/get-started/install))
- Firebase CLI instalado (opcional, mas recomendado)
- Conta no Firebase configurada

### Passo a Passo

1. Clone o repositório:
```bash
git clone https://github.com/seu-usuario/furia_app.git
cd furia_app
```

2. Instale as dependências:
```bash
flutter pub get
```

3. Configure seu arquivo de variáveis de ambiente:

Crie um arquivo `.env` na raiz do projeto com o seguinte conteúdo (exemplo):

```
API_KEY=your_api_key_here
PROJECT_ID=your_project_id_here
STORAGE_BUCKET=your_bucket_url
```
**⚠️ Este arquivo não deve ser versionado (adicione ao `.gitignore`)**

4. Configure o Firebase:

Siga as instruções do Firebase para Android, Web ou ambos. Coloque os arquivos `google-services.json` (Android) e `firebase_options.dart` (Web, se necessário) nas pastas corretas.

5. Execute o projeto:
```bash
flutter run
```

---

## 🗂 Estrutura do Projeto

```
lib/
├── app/
│   ├── app.dart
│   └── router.dart
├── core/
│   ├── services/
│   │   ├── firebase_service.dart
│   │   ├── home_match_service.dart
│   │   └── match_service.dart
│   ├── shimmer/
│   │   └── match_shimmer.dart
│   ├── utils/
│   │   └── constants.dart
│   └── widgets/
│       ├── home_screen_selector.dart
│       └── match_section.dart
├── features/
│   ├── auth/
│   │   ├── controllers/
│   │   │   └── auth_controller.dart
│   │   ├── screens/
│   │   │   ├── login_screen.dart
│   │   │   └── register_screen.dart
│   │   └── widgets/
│   │       ├── auth_text_field.dart
│   │       ├── document_upload.dart
│   │       ├── google_auth_button.dart
│   │       ├── login_screen.dart
│   │       └── register_screen.dart
│   ├── home/
│   │   ├── home_mobile.dart
│   │   └── home_web.dart
│   ├── matches/
│   │   └── matches_screen.dart
│   └── statistics/
│       └── statistics_screen.dart
└── main.dart
```

---

## 🔐 Considerações de Segurança

- Nunca suba o arquivo `.env` ou credenciais do Firebase no repositório público.
- Certifique-se de usar regras de segurança no Firebase Firestore e Storage.
- Usuários Web podem registrar sem imagens; no Android, o envio de selfie e documento é obrigatório.
- Um usuário logado via Web que acessar o app Android será redirecionado para completar o cadastro com imagens.

---

## 📈 Melhorias Futuras

- Integração com APIs públicas de resultados de jogos em tempo real
- Interface de Admin (moderar usuários, estatísticas etc)
- Testes unitários e de widget
- Modo escuro
- Notificações push com Firebase Messaging
- Internacionalização (i18n)

---

## 🤝 Contribuições

Contribuições são bem-vindas! Crie uma issue ou um pull request.

## 👤 Autor

**Gustavo** — [@guualonso](https://github.com/guualonso)