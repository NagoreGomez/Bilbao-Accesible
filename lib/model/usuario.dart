class Usuario {
  static final Usuario _singleton = Usuario._internal();
  String? _username;

  factory Usuario() {
    return _singleton;
  }

  Usuario._internal();

  void setUsuario(String nombreUsuario){
    _username=nombreUsuario;
  }

  String? getUserName(){
    return _username;
  }

}