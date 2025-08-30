# **CAPÍTULO 4 - DESENVOLVIMENTO DO SISTEMA - PARTE 6**

---

## **4.6 Configuração e implantação**

### **4.6.1 Configuração do Firebase**

A configuração do Firebase envolve múltiplos serviços integrados para fornecer backend completo.

#### **Configuração de autenticação**

```dart
// lib/firebase_options.dart
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.windows:
        return windows;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions não configurado para plataforma $defaultTargetPlatform'
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyC8j9XzQfVbNx3jKlM4pRtS7Wq2EuYvHgI',
    authDomain: 'tcc-educacional.firebaseapp.com',
    projectId: 'tcc-educacional',
    storageBucket: 'tcc-educacional.appspot.com',
    messagingSenderId: '123456789012',
    appId: '1:123456789012:web:abc123def456ghi789',
    measurementId: 'G-ABCD123456',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD9J8XzQfVbNx3jKlM4pRtS7Wq2EuYvHgJ',
    authDomain: 'tcc-educacional.firebaseapp.com',
    projectId: 'tcc-educacional',
    storageBucket: 'tcc-educacional.appspot.com',
    messagingSenderId: '123456789012',
    appId: '1:123456789012:android:xyz789abc123def456',
  );
}
```

#### **Regras de segurança Firestore**

```javascript
// firestore.rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Regras para usuários
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      allow read: if request.auth != null &&
        resource.data.tipo == 'professor' &&
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.tipo == 'professor';
    }

    // Regras para alunos
    match /alunos/{alunoId} {
      allow read, write: if request.auth != null && request.auth.uid == alunoId;
      allow read, write: if request.auth != null &&
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.tipo == 'professor';
    }

    // Regras para professores
    match /professores/{professorId} {
      allow read, write: if request.auth != null && request.auth.uid == professorId;
      allow read: if request.auth != null &&
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.tipo == 'aluno';
    }

    // Regras para postagens
    match /postagens/{postagemId} {
      allow read: if request.auth != null && (
        request.auth.uid == resource.data.professorId ||
        request.auth.uid in resource.data.alunosDestino
      );
      allow write: if request.auth != null &&
        request.auth.uid == resource.data.professorId;
    }

    // Regras para aulas
    match /aulas/{aulaId} {
      allow read, write: if request.auth != null && (
        request.auth.uid == resource.data.professorId ||
        request.auth.uid == resource.data.alunoId
      );
    }
  }
}
```

### **4.6.2 Configuração de build**

#### **Android (build.gradle)**

```gradle
// android/app/build.gradle
android {
    namespace "com.tcc.educacional"
    compileSdkVersion flutter.compileSdkVersion
    ndkVersion flutter.ndkVersion

    compileOptions {
        sourceCompatibility JavaVersion.VERSION_1_8
        targetCompatibility JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = '1.8'
    }

    sourceSets {
        main.java.srcDirs += 'src/main/kotlin'
    }

    defaultConfig {
        applicationId "com.tcc.educacional"
        minSdkVersion 21
        targetSdkVersion flutter.targetSdkVersion
        versionCode flutterVersionCode.toInteger()
        versionName flutterVersionName
        multiDexEnabled true
    }

    buildTypes {
        release {
            signingConfig signingConfigs.debug
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
        debug {
            applicationIdSuffix ".debug"
            versionNameSuffix "-debug"
        }
    }
}

dependencies {
    implementation "org.jetbrains.kotlin:kotlin-stdlib-jdk7:$kotlin_version"
    implementation 'com.android.support:multidex:1.0.3'
    implementation platform('com.google.firebase:firebase-bom:32.3.1')
    implementation 'com.google.firebase:firebase-analytics'
    implementation 'com.google.firebase:firebase-auth'
    implementation 'com.google.firebase:firebase-firestore'
}
```

#### **iOS (Info.plist)**

```xml
<!-- ios/Runner/Info.plist -->
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>$(DEVELOPMENT_LANGUAGE)</string>
    <key>CFBundleDisplayName</key>
    <string>TCC Educacional</string>
    <key>CFBundleExecutable</key>
    <string>$(EXECUTABLE_NAME)</string>
    <key>CFBundleIdentifier</key>
    <string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>tcc_educacional</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>$(FLUTTER_BUILD_NAME)</string>
    <key>CFBundleSignature</key>
    <string>????</string>
    <key>CFBundleVersion</key>
    <string>$(FLUTTER_BUILD_NUMBER)</string>
    <key>LSRequiresIPhoneOS</key>
    <true/>
    <key>UILaunchStoryboardName</key>
    <string>LaunchScreen</string>
    <key>UIMainStoryboardFile</key>
    <string>Main</string>
    <key>UISupportedInterfaceOrientations</key>
    <array>
        <string>UIInterfaceOrientationPortrait</string>
        <string>UIInterfaceOrientationLandscapeLeft</string>
        <string>UIInterfaceOrientationLandscapeRight</string>
    </array>
    <key>NSCameraUsageDescription</key>
    <string>Este app precisa acessar a câmera para adicionar fotos às postagens</string>
    <key>NSPhotoLibraryUsageDescription</key>
    <string>Este app precisa acessar a galeria para adicionar fotos às postagens</string>
</dict>
</plist>
```

### **4.6.3 CI/CD com GitHub Actions**

```yaml
# .github/workflows/build_and_deploy.yml
name: Build and Deploy

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: "3.13.0"

      - name: Install dependencies
        run: flutter pub get

      - name: Run analyzer
        run: flutter analyze

      - name: Run tests
        run: flutter test --coverage

      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          file: coverage/lcov.info

  build_android:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'

    steps:
      - uses: actions/checkout@v3

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: "3.13.0"

      - name: Setup Java
        uses: actions/setup-java@v3
        with:
          distribution: "zulu"
          java-version: "11"

      - name: Install dependencies
        run: flutter pub get

      - name: Build APK
        run: flutter build apk --release

      - name: Build App Bundle
        run: flutter build appbundle --release

      - name: Upload artifacts
        uses: actions/upload-artifact@v3
        with:
          name: android-builds
          path: |
            build/app/outputs/flutter-apk/app-release.apk
            build/app/outputs/bundle/release/app-release.aab

  build_ios:
    needs: test
    runs-on: macos-latest
    if: github.ref == 'refs/heads/main'

    steps:
      - uses: actions/checkout@v3

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: "3.13.0"

      - name: Install dependencies
        run: flutter pub get

      - name: Build iOS
        run: |
          flutter build ios --release --no-codesign

      - name: Upload artifacts
        uses: actions/upload-artifact@v3
        with:
          name: ios-build
          path: build/ios/iphoneos/Runner.app
```

### **4.6.4 Monitoramento e analytics**

#### **Configuração do Firebase Analytics**

```dart
// lib/services/analytics_service.dart
class AnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  static final FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: _analytics);

  // Eventos de autenticação
  static Future<void> logLogin(String method) async {
    await _analytics.logLogin(loginMethod: method);
  }

  static Future<void> logSignUp(String method) async {
    await _analytics.logSignUp(signUpMethod: method);
  }

  // Eventos de navegação
  static Future<void> logScreenView(String screenName) async {
    await _analytics.logScreenView(screenName: screenName);
  }

  // Eventos de postagem
  static Future<void> logPostCreated(String materia) async {
    await _analytics.logEvent(
      name: 'post_created',
      parameters: {
        'materia': materia,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  static Future<void> logPostViewed(String postagemId, String materia) async {
    await _analytics.logEvent(
      name: 'post_viewed',
      parameters: {
        'postagem_id': postagemId,
        'materia': materia,
      },
    );
  }

  // Eventos de erro
  static Future<void> logError(String error, String context) async {
    await _analytics.logEvent(
      name: 'app_error',
      parameters: {
        'error_message': error,
        'error_context': context,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  // Configurar propriedades do usuário
  static Future<void> setUserProperties({
    required String userId,
    required String userType,
  }) async {
    await _analytics.setUserId(id: userId);
    await _analytics.setUserProperty(name: 'user_type', value: userType);
  }
}
```

### **4.7 Documentação técnica**

#### **4.7.1 README do projeto**

````markdown
# TCC Educacional - Sistema de Gestão Escolar

## Descrição

Sistema Flutter para gestão de atividades educacionais entre professores e alunos.

## Tecnologias Utilizadas

- **Frontend**: Flutter 3.13.0
- **Backend**: Firebase (Firestore, Auth, Analytics)
- **Arquitetura**: Clean Architecture + Provider
- **Testes**: flutter_test, integration_test
- **CI/CD**: GitHub Actions

## Instalação

### Pré-requisitos

- Flutter SDK 3.13.0+
- Android Studio / VS Code
- Firebase CLI
- Git

### Passos de instalação

```bash
# 1. Clonar repositório
git clone https://github.com/usuario/tcc-educacional.git
cd tcc-educacional

# 2. Instalar dependências
flutter pub get

# 3. Configurar Firebase
flutterfire configure

# 4. Executar app
flutter run
```
````

### Estrutura do Projeto

```
lib/
├── controllers/     # Lógica de negócio
├── models/         # Modelos de dados
├── services/       # Comunicação externa
├── views/          # Interfaces de usuário
├── widgets/        # Componentes reutilizáveis
└── routes/         # Navegação
```

### Scripts Úteis

```bash
# Testes
flutter test
flutter test integration_test/

# Build
flutter build apk --release
flutter build appbundle --release

# Análise de código
flutter analyze
```

```

---

### 📊 **MÉTRICAS DA PARTE 6**

| **Seção** | **Funcionalidades** | **Palavras** |
|-----------|---------------------|-------------|
| **4.6.1 Config Firebase** | Autenticação + regras | 286 palavras |
| **4.6.2 Config Build** | Android + iOS | 187 palavras |
| **4.6.3 CI/CD** | GitHub Actions | 152 palavras |
| **4.6.4 Analytics** | Monitoramento | 198 palavras |
| **4.7 Documentação** | README técnico | 127 palavras |
| **TOTAL PARTE 6** | **Deploy e configuração** | **950 palavras** |

---

### 📊 **RESUMO COMPLETO DO CAPÍTULO 4**

| **Parte** | **Seções** | **Palavras** | **Páginas** |
|-----------|------------|-------------|-------------|
| **Parte 1** | Requisitos + Modelagem | 897 | 3,0 |
| **Parte 2** | Models + Rotas | 934 | 3,1 |
| **Parte 3** | Auth + User Controllers | 945 | 3,2 |
| **Parte 4** | Postagens + Cronograma | 854 | 2,9 |
| **Parte 5** | Anexos + Testes + Performance | 944 | 3,2 |
| **Parte 6** | Deploy + Configuração | 950 | 3,2 |
| **TOTAL CAP. 4** | **Sistema completo** | **5.524 palavras** | **18,6 páginas** |

**📄 Próximo: Capítulo 5 - Resultados e Discussão**
```
