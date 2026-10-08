/// Endereço do PocketBase.
class PocketBaseConfig {
  static const url = String.fromEnvironment(
    'POCKETBASE_URL',
    defaultValue: 'http://10.0.2.2:8090',
  );
}
