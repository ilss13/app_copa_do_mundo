sealed class ApiException implements Exception {
  const ApiException(this.message);
  final String message;
}

final class NetworkException extends ApiException {
  const NetworkException() : super('Sem conexão com a internet. Verifique sua rede.');
}

final class ServerException extends ApiException {
  const ServerException(super.message, this.statusCode);
  final int statusCode;
}

final class TimeoutException extends ApiException {
  const TimeoutException() : super('A requisição demorou muito. Tente novamente.');
}

final class UnauthorizedException extends ApiException {
  const UnauthorizedException() : super('Chave de API inválida ou expirada.');
}

final class NotFoundException extends ApiException {
  const NotFoundException() : super('Recurso não encontrado.');
}

final class ParseException extends ApiException {
  const ParseException(super.message);
}
