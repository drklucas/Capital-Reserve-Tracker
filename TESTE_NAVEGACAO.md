# 🧪 Teste de Navegação - Goals

## ✅ Status da Implementação

### Navegação está CORRETA no código:

**Home Screen → Goals:**
```dart
// Linha 199 em home_screen.dart
onTap: () {
  Navigator.pushNamed(context, '/goals');
},
```

**Rota registrada em main.dart:**
```dart
// Linha 319 em main.dart
'/goals': (context) => const GoalsScreen(),
```

**Import correto:**
```dart
// Linha 47 em main.dart
import 'presentation/screens/goals/goals_screen.dart';
```

---

## 🎯 Como Testar

### 1. **Compile o app novamente**
```bash
cd app
flutter clean
flutter pub get
flutter run
```

### 2. **Fluxo de Teste Completo**

#### Passo 1: Login
1. Abra o app
2. Faça login com suas credenciais
3. Você deve chegar na **HomeScreen**

#### Passo 2: Navegue para Goals
1. Na HomeScreen, você verá 4 cards:
   - 🔵 **Metas** (canto superior esquerdo)
   - 🟢 **Nova Transação** (canto superior direito)
   - 🟠 **Transações** (canto inferior esquerdo)
   - 🟣 **Dashboard** (canto inferior direito)

2. **Clique no card "Metas"** (🔵 azul, ícone de bandeira)

3. Você deve ver a tela **GoalsScreen** com:
   - Título "Minhas Metas"
   - Botão "+" no AppBar
   - Resumo Geral (metas ativas, concluídas, progresso)
   - Lista de metas (ou mensagem "Nenhuma meta cadastrada")
   - Botão flutuante "+" no canto inferior direito

#### Passo 3: Criar uma Meta
1. Clique no botão "+" (AppBar ou flutuante)
2. Preencha o formulário:
   - **Título:** "Ano Sabático 2026"
   - **Descrição:** "Economizar para um ano sabático"
   - **Valor Alvo:** 50000 (R$ 50.000,00)
   - **Data de Início:** Hoje
   - **Data Alvo:** 365 dias no futuro

3. Revise o resumo:
   - Período: X dias
   - Economia diária necessária: R$ YYY,YY

4. Clique em "Criar Meta"

5. Você deve:
   - Ver mensagem de sucesso (verde)
   - Voltar para GoalsScreen
   - Ver a meta criada na lista

#### Passo 4: Visualizar Detalhes
1. Clique em uma meta na lista
2. Você deve ver **GoalDetailScreen** com:
   - Título e status da meta
   - Card de Progresso (valor atual vs. alvo)
   - Card de Estatísticas detalhadas
   - Transações associadas
   - Menu de ações (editar, alterar status, excluir)

---

## ❌ Se NÃO Funcionar

### Problema 1: Nada acontece ao clicar em "Metas"
**Possíveis causas:**
1. App não recompilado após mudanças
2. Hot reload não aplicou as mudanças

**Solução:**
```bash
# Pare o app (Ctrl+C no terminal)
cd app
flutter clean
flutter pub get
flutter run
```

### Problema 2: Erro ao navegar
**Se aparecer erro tipo "Route not found" ou similar:**

Verifique no console o erro exato e me informe.

### Problema 3: Tela de Goals aparece em branco
**Possíveis causas:**
1. Usuário não está autenticado
2. Firebase rules bloqueando
3. Erro no stream

**Como verificar:**
```bash
# No terminal onde o app está rodando
# Procure por erros como:
# - Permission denied
# - User not authenticated
# - Firebase error
```

---

## 🔍 Debug Visual

### O que você DEVE ver na HomeScreen:

```
┌─────────────────────────────┐
│  Capital Reserve Tracker    │
│  ────────────────────────   │
│                             │
│  👤 Bem-vindo, [Nome]       │
│                             │
│  💰 Saldo Atual             │
│  R$ XXX,XX                  │
│                             │
│  Ações Rápidas              │
│  ┌────────┐  ┌────────┐    │
│  │  🚩    │  │  ➕    │    │
│  │ Metas  │  │ Nova   │    │ <-- CLIQUE AQUI!
│  └────────┘  └────────┘    │
│  ┌────────┐  ┌────────┐    │
│  │  📋    │  │  📊    │    │
│  │Transaç.│  │Dashboard│   │
│  └────────┘  └────────┘    │
│                             │
│  Atividade Recente          │
│  (vazio ou transações)      │
└─────────────────────────────┘
```

### O que você DEVE ver na GoalsScreen (vazia):

```
┌─────────────────────────────┐
│ ← Minhas Metas          + │ <-- Botão adicionar
│  ────────────────────────   │
│                             │
│  ┌─────────────────────┐   │
│  │   Resumo Geral      │   │
│  │  Metas Ativas: 0    │   │
│  │  Concluídas: 0      │   │
│  │  Progresso: 0%      │   │
│  └─────────────────────┘   │
│                             │
│       🚩                    │
│                             │
│  Nenhuma meta cadastrada    │
│                             │
│  Crie sua primeira meta     │
│  financeira!                │
│                             │
│  [ Criar Meta ]             │
│                             │
└─────────────────────────────┘
              [+] <-- Botão flutuante
```

---

## 📱 Teste Rápido

Execute estes comandos e me diga o resultado:

```bash
# 1. Verificar se não há erros
cd app
flutter analyze | grep error

# 2. Limpar e reconstruir
flutter clean
flutter pub get

# 3. Rodar em modo debug
flutter run

# No app:
# - Faça login
# - Clique em "Metas" na home
# - Me diga o que acontece
```

---

## ✅ Resultado Esperado

Quando você clicar em "Metas":
1. ✅ A tela muda para GoalsScreen
2. ✅ Você vê "Minhas Metas" no AppBar
3. ✅ Você vê o resumo geral
4. ✅ Você vê mensagem "Nenhuma meta cadastrada" (se não tiver nenhuma)
5. ✅ Você pode clicar em "+" para criar uma meta

---

**Se após seguir estes passos ainda não funcionar, me envie:**
1. Screenshot da HomeScreen
2. Screenshot do que acontece ao clicar em "Metas"
3. Logs do console (se houver erro)
