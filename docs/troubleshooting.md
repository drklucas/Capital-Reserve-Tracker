# Troubleshooting Guide

## Build Issues

### Error: "No file or variants found for asset: .env"

**Causa**: O arquivo `.env` não existe.

**Solução**:
```bash
cd app
cp .env.example .env
# Editar .env com suas credenciais do Firebase
```

### Error: "Cannot access output property 'blameLogOutputFolder'"

**Causa**: Cache do Gradle corrompido.

**Solução**:
```bash
cd app/android
./gradlew clean
cd ..
flutter clean
rm -rf build .dart_tool
flutter pub get
flutter run
```

### Error: "Compilation failed; see the compiler output" (flutter_local_notifications)

**Causa**: Versão antiga do `flutter_local_notifications` incompatível com Android SDK recente.

**Solução**: Atualizar para versão 17+:
```yaml
flutter_local_notifications: ^17.2.3
```

### Error: "Dependency requires core library desugaring"

**Causa**: Core library desugaring não habilitado no Android.

**Solução**: Adicionar em `android/app/build.gradle.kts`:
```kotlin
compileOptions {
    sourceCompatibility = JavaVersion.VERSION_11
    targetCompatibility = JavaVersion.VERSION_11
    isCoreLibraryDesugaringEnabled = true
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}
```

### Error: "The name 'AuthProvider' is defined in the libraries..."

**Causa**: Conflito de nomes entre Firebase Auth e provider customizado.

**Solução**: A classe foi renomeada para `AppAuthProvider` para evitar conflito.

## Firebase Issues

### Firebase não inicializa

**Verificar**:
1. `.env` existe e tem valores corretos
2. `firebase_options.dart` foi gerado
3. Apps registrados no Firebase Console

**Solução**:
```bash
cd app
flutterfire configure --project=mygoals-19463
```

### "Firebase project not found"

**Verificar**: Você está logado no Firebase CLI
```bash
firebase login
firebase projects:list
```

## Dependency Issues

### "Version solving failed"

**Solução**:
```bash
cd app
flutter pub upgrade --major-versions
flutter pub get
```

### Packages desatualizados

```bash
cd app
flutter pub outdated
flutter pub upgrade
```

## Runtime Issues

### App crasha ao iniciar

**Verificar**:
1. Firebase está configurado corretamente
2. Permissões no AndroidManifest.xml
3. Logs com `flutter logs`

**Debug**:
```bash
flutter run --verbose
flutter logs
```

### "PlatformException"

**Causa comum**: Permissões não concedidas ou configuração Firebase incorreta.

**Solução**: Verificar logs e documentação do plugin específico.

## Development

### Hot reload não funciona

```bash
# Na terminal do Flutter em execução
r  # hot reload
R  # hot restart
q  # quit
```

### Mudanças não aparecem

```bash
flutter clean
flutter pub get
flutter run
```

## Performance

### Build lento

**Melhorias**:
1. Usar `--release` mode para testes de performance
2. Limpar cache do Gradle regularmente
3. Aumentar memória do Gradle em `gradle.properties`:
```properties
org.gradle.jvmargs=-Xmx4096m
```

### App lento em debug

**Normal**: Debug mode tem overhead. Testar em release mode:
```bash
flutter run --release
```

## Security

### Commitei credenciais por acidente

**URGENTE**:
1. Remover do Git history:
```bash
git filter-branch --force --index-filter \
  "git rm --cached --ignore-unmatch app/.env" \
  --prune-empty --tag-name-filter cat -- --all
```

2. Regenerar todas as credenciais no Firebase Console
3. Atualizar `.env` local
4. Verificar que `.gitignore` está correto

### Verificar se arquivos sensíveis estão no staging

```bash
git status
git diff --cached
```

Sempre verificar antes de commit!

## Common Commands

### Limpar completamente o projeto
```bash
cd app
flutter clean
rm -rf build .dart_tool
cd android
./gradlew clean
cd ..
flutter pub get
```

### Verificar dispositivos conectados
```bash
flutter devices
```

### Analisar código
```bash
cd app
flutter analyze
```

### Formatar código
```bash
cd app
flutter format lib/
```

### Executar testes
```bash
cd app
flutter test
flutter test --coverage
```

## Links Úteis

- [Flutter Documentation](https://docs.flutter.dev/)
- [Firebase Documentation](https://firebase.google.com/docs)
- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Stack Overflow - Flutter](https://stackoverflow.com/questions/tagged/flutter)

## Reporting Issues

Ao reportar problemas, incluir:
1. Comando executado
2. Output completo do erro
3. Versão do Flutter (`flutter --version`)
4. Versão do Dart (`dart --version`)
5. Sistema operacional
6. Passos para reproduzir

```bash
flutter doctor -v  # informações do ambiente
```
