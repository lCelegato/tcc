# **CAPÍTULO 3 - METODOLOGIA - PARTE 3**

---

## **3.2.4 Backend - Firebase Ecosystem**

**Firebase** foi adotado como backend principal devido à integração nativa com Flutter, escalabilidade automática e redução significativa da complexidade de infraestrutura.

### **Firebase Authentication 6.0.1**

Serviço de autenticação que fornece backend completo para gerenciamento de usuários, incluindo registro, login, recuperação de senha e gerenciamento de sessões seguras.

**Características Técnicas:**

- Suporte a múltiplos provedores de autenticação (email/password, Google, Facebook)
- Tokens JWT para sessões seguras com renovação automática
- SDK nativo para Flutter com integração transparente
- Conformidade com padrões de segurança OWASP

**Justificativa de Escolha:** Eliminação da necessidade de implementar sistema de autenticação customizado, reduzindo riscos de segurança e tempo de desenvolvimento (FIREBASE TEAM, 2023).

### **Cloud Firestore 6.0.0**

Banco de dados NoSQL document-oriented com sincronização em tempo real e capacidades offline robustas.

**Vantagens Técnicas:**

- Sincronização automática entre dispositivos em tempo real
- Queries expressivos com indexação automática
- Offline persistence com sincronização quando conectividade é restaurada
- Escalabilidade automática sem necessidade de configuração manual
- Transações ACID para operações críticas

**Modelo de Dados:** Estrutura baseada em collections e documents, proporcionando flexibilidade para evolução do esquema de dados sem migrações complexas.

### **Firebase Security Rules**

Sistema de autorização que opera diretamente no banco de dados, garantindo segurança granular sem necessidade de middleware adicional.

**Implementação das Regras:**

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Função auxiliar para verificar autenticação
    function isAuthenticated() {
      return request.auth != null;
    }

    // Função auxiliar para verificar propriedade
    function isOwner(userId) {
      return request.auth.uid == userId;
    }

    // Regras para coleção de professores
    match /professores/{userId} {
      allow read, write: if isAuthenticated() && isOwner(userId);
    }

    // Regras para coleção de alunos
    match /alunos/{userId} {
      allow create, read: if isAuthenticated() && isOwner(userId);
      allow read, list: if isAuthenticated() &&
        resource.data.professorId == request.auth.uid;
      allow update, delete: if isAuthenticated() &&
        resource.data.professorId == request.auth.uid;
    }
  }
}
```

### **3.2.5 Inovação: Sistema Base64 Proprietário**

Desenvolveu-se sistema inovador para armazenamento de arquivos utilizando codificação Base64 diretamente no Firestore, eliminando necessidade de Firebase Storage.

**Motivação Técnica:** Redução de custos operacionais e simplificação da arquitetura, mantendo funcionalidade completa de upload, armazenamento e download de arquivos.

**Implementação:**

```dart
class Base64FileProcessor {
  // Conversão de arquivo para Base64
  Future<String> encodeFileToBase64(File file) async {
    final bytes = await file.readAsBytes();
    return base64Encode(bytes);
  }

  // Recuperação de arquivo a partir de Base64
  Future<File> decodeBase64ToFile(String base64String, String fileName) async {
    final bytes = base64Decode(base64String);
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName');
    await file.writeAsBytes(bytes);
    return file;
  }
}
```

**Vantagens da Abordagem:**

- Custo zero para armazenamento de arquivos
- Integração direta com Firestore security rules
- Backup automático incluído no Firestore
- Simplicidade de implementação e manutenção

**Limitações Gerenciadas:**

- Limite de 1MB por document do Firestore requer validação de tamanho
- Processamento Base64 adiciona overhead computacional
- Aumento no tráfego de rede para downloads

---

### 📊 **MÉTRICAS DA PARTE 3**

| **Seção**               | **Palavras**     | **Conteúdo**     |
| ----------------------- | ---------------- | ---------------- |
| **3.2.4 Firebase**      | 298 palavras     | Backend services |
| **3.2.5 Base64 System** | 187 palavras     | Inovação técnica |
| **TOTAL PARTE 3**       | **485 palavras** | **≈2 páginas**   |

---

**📄 Continua na Parte 4: Arquitetura do Sistema**
