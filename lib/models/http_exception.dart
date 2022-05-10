class HttpException implements Exception {
  //implements uses a class, when we need to implement a class, we are signing a contract,
  //we're forced to implement all fuctions this class has.

  //we want to instead print the error message because exceptions typically store a
  final String message;
  HttpException(this.message);

  @override
  String toString() {
    return message; //Instance of HttpException
  }
}
