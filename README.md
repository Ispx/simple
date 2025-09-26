# simple

`simple` é uma biblioteca Dart leve e direta para injeção de dependência e localização de serviços. Ela ajuda a desacoplar a construção e o consumo de suas classes, facilitando a gerência de dependências em seus projetos Dart e Flutter.

## Instalação

Adicione o `simple` ao seu arquivo `pubspec.yaml`:

```yaml
dependencies:
  simple: ^1.0.0 # Verifique a versão mais recente
```

Em seguida, execute `pub get` ou `flutter pub get`.

## Como Usar

A utilização da biblioteca é focada na classe `Simple`, que gerencia o registro e a recuperação de suas classes (dependências).

### Uso Básico

Primeiro, obtenha a instância do `Simple`:

```dart
import 'package:simple/simple.dart';

final simple = Simple();
```

### Registrando um Singleton

Um `singleton` é uma instância única que será compartilhada em toda a aplicação. A instância é criada no momento do registro.

Use `addSingleton<T>(() => T())` para registrar:

```dart
class ApiService {
  void fetchData() => print('Dados recebidos!');
}

// Registra uma instância única de ApiService
simple.addSingleton<ApiService>(() => ApiService());
```

Para obter a instância, use `get<T>()`:

```dart
// Em qualquer lugar da sua aplicação
final api = simple.get<ApiService>();
api.fetchData(); // Saída: Dados recebidos!
```

### Registrando uma Factory

Uma `factory` cria uma nova instância da classe toda vez que `get<T>()` é chamado.

Use `addFactory<T>(() => T())` para registrar:

```dart
class ViewController {
  final int creationHash;
  ViewController() : creationHash = DateTime.now().hashCode;
}

// Registra uma factory para ViewController
simple.addFactory<ViewController>(() => ViewController());
```

Ao obter a instância, uma nova será criada a cada chamada:

```dart
final controller1 = simple.get<ViewController>();
final controller2 = simple.get<ViewController>();

print(controller1.creationHash); // Saída: 12345
print(controller2.creationHash); // Saída: 67890 (diferente)
```

### Atualizando uma Dependência

Você pode substituir uma dependência já registrada usando `update<T>()`. Isso é útil para testes (mocking) ou para alterar a implementação em tempo de execução.

```dart
// Suponha que ApiService já foi registrado
class MockApiService implements ApiService {
  @override
  void fetchData() => print('Dados de teste recebidos!');
}

// Atualiza a implementação de ApiService
simple.update<ApiService>(() => MockApiService());

final api = simple.get<ApiService>();
api.fetchData(); // Saída: Dados de teste recebidos!
```

### Limpando as Dependências

Você pode remover todas as dependências registradas com `reset()` ou `clear()`.

- `clear()`: Limpa todas as instâncias registradas.
- `reset()`: Também limpa tudo, mas executa novamente a função de `startUp`, se ela foi definida.

```dart
simple.reset(); // Limpa todas as instâncias
```

## Exemplo Completo

```dart
import 'package:simple/simple.dart';

// --- Classes de exemplo ---
class ServiceA {
  String get message => 'Olá do Serviço A!';
}

class ServiceB {
  final ServiceA serviceA;
  ServiceB(this.serviceA);

  void doSomething() {
    print('ServiceB diz: ${serviceA.message}');
  }
}

void main() {
  final simple = Simple();

  // 1. Registrar dependências
  simple.addSingleton<ServiceA>(() => ServiceA());
  simple.addFactory<ServiceB>(() => ServiceB(simple.get<ServiceA>()));

  // 2. Usar as dependências
  final serviceB = simple.get<ServiceB>();
  serviceB.doSomething(); // Saída: ServiceB diz: Olá do Serviço A!

  // 3. Atualizar uma dependência
  print('
--- Atualizando ServiceA ---');
  simple.update<ServiceA>(() => MockServiceA());

  final newServiceB = simple.get<ServiceB>();
  newServiceB.doSomething(); // Saída: ServiceB diz: Olá do MockServiceA!

  // 4. Limpar tudo
  simple.reset();
  print('
Instâncias limpas.');

  try {
    simple.get<ServiceA>();
  } catch (e) {
    print(e); // Lança uma exceção, pois a instância não existe mais
  }
}

// Classe de mock para o exemplo de atualização
class MockServiceA implements ServiceA {
  @override
  String get message => 'Olá do MockServiceA!';
}
```