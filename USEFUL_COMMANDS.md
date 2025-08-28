# 🛠️ COMANDOS ÚTEIS DO PROJETO TCC

## 🔍 **Análise e Verificação**

```bash
# Verificar código (warnings, erros, etc.)
flutter analyze

# Verificar dependências desatualizadas
flutter pub outdated

# Limpeza completa
flutter clean && flutter pub get

# Verificar informações do projeto
flutter doctor -v
```

## 🏗️ **Build e Compilação**

```bash
# Build para Android (Debug)
flutter build apk --debug

# Build para Android (Release)
flutter build apk --release

# Build para Web
flutter build web

# Build para Windows
flutter build windows

# Build com informações detalhadas
flutter build apk --verbose
```

## 🚀 **Executar Aplicação**

```bash
# Executar em modo debug
flutter run

# Executar com hot reload ativo
flutter run --hot

# Executar no dispositivo específico
flutter run -d <device-id>

# Listar dispositivos disponíveis
flutter devices
```

## 🔥 **Firebase**

```bash
# Login no Firebase
firebase login

# Inicializar projeto Firebase
firebase init

# Deploy das regras do Firestore
firebase deploy --only firestore:rules

# Deploy dos índices do Firestore
firebase deploy --only firestore:indexes

# Deploy completo
firebase deploy

# Verificar configuração atual
firebase projects:list
```

## 📦 **Gerenciamento de Dependências**

```bash
# Instalar dependências
flutter pub get

# Adicionar nova dependência
flutter pub add <package_name>

# Remover dependência
flutter pub remove <package_name>

# Verificar dependências não utilizadas
flutter pub deps
```

## 🧪 **Testes**

```bash
# Executar todos os testes
flutter test

# Executar testes com cobertura
flutter test --coverage

# Executar testes de integração
flutter drive --target=test_driver/app.dart
```

## 🔧 **Debugging e Logs**

```bash
# Executar com logs detalhados
flutter run --verbose

# Executar com DevTools
flutter run --enable-software-rendering

# Conectar ao DevTools
flutter packages pub global run devtools

# Logs do dispositivo Android
adb logcat | grep flutter
```

## 📊 **Performance e Análise**

```bash
# Análise de tamanho do app
flutter build apk --analyze-size

# Profile mode para análise de performance
flutter run --profile

# Executar com inspector
flutter run --enable-dart-profiling
```

## 🗂️ **Estrutura de Arquivos**

```bash
# Contar linhas de código
find lib -name "*.dart" | xargs wc -l

# Listar arquivos Dart
find lib -name "*.dart" -type f

# Verificar arquivos grandes
find lib -name "*.dart" -exec wc -l {} + | sort -n
```

## 🔄 **Git (Versionamento)**

```bash
# Status do repositório
git status

# Adicionar arquivos modificados
git add .

# Commit com mensagem
git commit -m "feat: descrição da funcionalidade"

# Push para o repositório
git push origin main

# Criar nova branch
git checkout -b feature/nova-funcionalidade

# Merge de branch
git checkout main && git merge feature/nova-funcionalidade
```

## 🎯 **Produção e Deploy**

```bash
# Gerar keystore para Android (Release)
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload

# Build release com obfuscação
flutter build apk --release --obfuscate --split-debug-info=build/debug-info

# Build App Bundle para Google Play
flutter build appbundle --release

# Verificar assinatura do APK
jarsigner -verify -verbose -certs app-release.apk
```

## 📱 **Dispositivos e Emuladores**

```bash
# Criar emulador Android
avdmanager create avd -n test_device -k "system-images;android-30;google_apis;x86"

# Iniciar emulador
emulator -avd test_device

# Conectar dispositivo físico (Android)
adb devices

# Instalar APK manualmente
adb install build/app/outputs/flutter-apk/app-debug.apk
```

## 🔧 **Troubleshooting**

```bash
# Limpar cache completo
flutter clean
cd ios && pod clean && cd ..
rm -rf pubspec.lock
flutter pub get

# Corrigir problemas de gradle (Android)
cd android && ./gradlew clean && cd ..

# Resetar configurações Flutter
flutter config --clear-features
flutter doctor --android-licenses

# Verificar variáveis de ambiente
echo $FLUTTER_ROOT
echo $ANDROID_HOME
```

## 📋 **Checklist de Deploy**

### Pré-Deploy

- [ ] `flutter analyze` - sem warnings
- [ ] `flutter test` - todos os testes passando
- [ ] Build debug funciona - `flutter build apk --debug`
- [ ] Firebase rules atualizadas
- [ ] Versão atualizada no pubspec.yaml

### Deploy Android

- [ ] Keystore configurado
- [ ] Build release - `flutter build apk --release`
- [ ] Testado em dispositivo físico
- [ ] Upload para Google Play Console

### Deploy Web

- [ ] Build web - `flutter build web`
- [ ] Testado em diferentes navegadores
- [ ] Deploy para hosting (Firebase, Netlify, etc.)

## 📞 **Links Úteis**

- **Flutter Docs**: https://docs.flutter.dev/
- **Firebase Console**: https://console.firebase.google.com/
- **Pub.dev**: https://pub.dev/
- **Flutter DevTools**: https://docs.flutter.dev/development/tools/devtools
- **Material Design**: https://m3.material.io/

---

_Última atualização: 27 de agosto de 2025_
