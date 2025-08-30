# Configuração do Projeto - Sistema TCC

**Data de criação:** 30 de agosto de 2025  
**Versão atual:** 2.0.0  
**Status:** ✅ Produção

## 📁 Estrutura do Projeto

```
projeto_tcc/
├── docs/                              # 📚 Documentação
│   ├── log-decisao-imagens.md         # Log de decisões técnicas
│   ├── README-sistema-imagens.md      # Documentação do sistema
│   ├── CHANGELOG.md                   # Histórico de mudanças
│   └── config.md                      # Este arquivo
├── lib/
│   ├── controllers/                   # 🎮 Controladores
│   ├── models/                        # 📊 Modelos de dados
│   ├── services/                      # 🔧 Serviços
│   │   ├── auth_service.dart          # Autenticação
│   │   ├── user_service.dart          # Usuários
│   │   ├── postagem_service.dart      # Postagens
│   │   ├── aula_service.dart          # Aulas
│   │   └── image_service.dart         # 🖼️ Imagens (Base64)
│   ├── views/                         # 📱 Telas
│   │   ├── professor/                 # Telas do professor
│   │   └── aluno/                     # Telas do aluno
│   ├── widgets/                       # 🧩 Componentes
│   │   └── image_manager_widget.dart  # Widget de imagens
│   └── routes/                        # 🛣️ Navegação
└── firebase/                          # ⚡ Configurações Firebase
    ├── firestore.rules                # Regras Firestore
    └── firestore.indexes.json         # Índices Firestore
```

## 🔧 Tecnologias Utilizadas

### **Frontend**

- **Flutter:** 3.35.1
- **Dart:** 3.2.3+
- **Target Platforms:** Windows, Android, iOS, Web

### **Backend & Services**

- **Firebase Auth:** 6.0.1 (Autenticação)
- **Cloud Firestore:** 6.0.0 (Banco de dados)
- **Firebase Core:** 4.0.0 (Core services)

### **Bibliotecas Específicas**

- **Provider:** 6.1.5+1 (Gerenciamento de estado)
- **Image Picker:** 1.1.2 (Seleção de imagens)
- **Permission Handler:** 11.3.1 (Permissões Android/iOS)

### **Desenvolvimento**

- **Flutter Test:** SDK (Testes unitários)
- **Flutter Lints:** Linting e qualidade de código

## ⚙️ Configurações Específicas

### **Sistema de Imagens**

```yaml
# Configurações de compressão
Image Compression:
  maxWidth: 800px
  maxHeight: 600px
  quality: 70%
  format: JPEG
  maxSize: 800KB

# Armazenamento
Storage Backend: Firestore Base64
Fallback: Nenhum
Cache: Memória local (automático)
```

### **Firebase Configuration**

```yaml
Project ID: projeto-tcc-2025
Region: us-central1
Auth Domain: projeto-tcc-2025.firebaseapp.com

# Serviços habilitados
Services:
  - Firebase Auth ✅
  - Cloud Firestore ✅
  - Firebase Storage ❌ (Removido)
  - Firebase Hosting ❌ (Não utilizado)
```

### **Firestore Collections**

```yaml
Collections:
  - usuarios/ # Dados básicos dos usuários
  - professores/ # Perfis de professores
  - alunos/ # Perfis de alunos
  - postagens/ # Postagens com imagens Base64
  - aulas/ # Agendamento de aulas
```

## 🔒 Segurança e Permissões

### **Firestore Rules**

```javascript
// Resumo das regras implementadas
- Usuários: Leitura/escrita próprios dados
- Professores: Leitura pública, escrita própria
- Alunos: Leitura professor vinculado
- Postagens: Professor cria/edita, aluno lê destinadas
- Aulas: Professor gerencia, aluno lê próprias
```

### **Permissões Mobile**

```xml
<!-- Android -->
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.INTERNET" />
```

## 📊 Limites e Quotas

### **Firebase Spark Plan (Gratuito)**

```yaml
Firestore:
  - Reads: 50K/day
  - Writes: 20K/day
  - Deletes: 20K/day
  - Storage: 1GB
  - Bandwidth: 10GB/month

Auth:
  - Users: Unlimited
  - Authentication: Unlimited
```

### **Sistema de Imagens**

```yaml
Limits:
  - Max image size: 800KB
  - Max images per post: ~10 (recomendado)
  - Total document size: 1MB (Firestore limit)
  - Compression: Automatic
```

## 🛡️ Backup e Recovery

### **Estratégia de Backup**

- **Firestore:** Backup automático pelo Firebase
- **Código:** Git repository (GitHub)
- **Configurações:** Documentadas neste arquivo
- **Imagens:** Embarcadas nos documentos Firestore

### **Recovery Procedure**

1. Restore do código via Git
2. Reconfiguração Firebase (se necessário)
3. Deploy das rules Firestore
4. Teste de funcionalidades críticas

## 🚀 Deploy e CI/CD

### **Deploy Process**

```bash
# 1. Build e teste local
flutter clean
flutter pub get
flutter analyze
flutter test
flutter build windows

# 2. Deploy Firestore rules
firebase deploy --only firestore:rules

# 3. Deploy para produção
flutter build web
# Hosting manual ou via Firebase Hosting
```

### **Ambientes**

- **Development:** Local (Windows)
- **Testing:** Firebase Test Project
- **Production:** projeto-tcc-2025

## 📞 Contatos e Suporte

### **Equipe Técnica**

- **Desenvolvimento:** Responsável pelo código
- **Firebase:** Console Firebase para monitoramento
- **Documentação:** Pasta `/docs` do projeto

### **Recursos de Suporte**

- **Logs:** Console Firebase
- **Monitoramento:** Firebase Analytics (se habilitado)
- **Debugging:** Flutter DevTools
- **Performance:** Firebase Performance (se habilitado)

## 📅 Cronograma de Manutenção

### **Atualizações Regulares**

- **Dependências:** Mensalmente
- **Firestore Rules:** Conforme necessário
- **Documentação:** A cada major release

### **Monitoramento**

- **Performance:** Semanal
- **Quotas Firebase:** Diário durante uso intenso
- **Logs de erro:** Conforme necessário

---

**Última atualização:** 30 de agosto de 2025  
**Próxima revisão:** 30 de setembro de 2025  
**Mantenedor:** Equipe TCC
