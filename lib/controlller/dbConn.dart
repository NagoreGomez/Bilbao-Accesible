import 'dart:core';

import 'package:mysql1/mysql1.dart';

import 'package:bilbao_accesible/model/usuario.dart';

class DBconn {
  String username = '';

  Future<List<List<double>>> getAscensoresGratuitos() async {
    // Open a connection (testdb should already exist)
    final conn = await MySqlConnection.connect(ConnectionSettings(
        host: '34.175.191.14',
        port: 3306,
        user: 'root',
        db: 'bilbaoaccesible_data',
        password: 'D*z}5hQ3gu-rt\$jZ'));

    String x = '0.0';
    String y = '0.0';
    List<double> coord = [];
    List<List<double>> coord2 = [];

    var results = await conn.query(
        'SELECT * FROM AscensorGratuito');

    for (var row in results) {
      x = '${row[11]}';
      double xCoord = double.parse(x);
      y = x = '${row[12]}';
      double yCoord = double.parse(y);
      coord.add(xCoord);
      coord.add(yCoord);
      coord2.add(coord);

      coord = [];
    }
    await conn.close();

    return coord2;
  }

  Future<List<List<double>>> getAscensoresDePago() async {
    // Open a connection (testdb should already exist)
    final conn = await MySqlConnection.connect(ConnectionSettings(
        host: '34.175.191.14',
        port: 3306,
        user: 'root',
        db: 'bilbaoaccesible_data',
        password: 'D*z}5hQ3gu-rt\$jZ'));

    String x = '0.0';
    String y = '0.0';
    List<double> coord = [];
    List<List<double>> coord2 = [];

    var results = await conn.query(
        'SELECT * FROM AscensorPago');

    for (var row in results) {
      x = '${row[11]}';
      double xCoord = double.parse(x);
      y = x = '${row[12]}';
      double yCoord = double.parse(y);
      coord.add(xCoord);
      coord.add(yCoord);
      coord2.add(coord);

      coord = [];
    }
    await conn.close();
    return coord2;
  }

  Future<List<List<double>>> getEscaleras() async {
    // Open a connection (testdb should already exist)
    final conn = await MySqlConnection.connect(ConnectionSettings(
        host: '34.175.191.14',
        port: 3306,
        user: 'root',
        db: 'bilbaoaccesible_data',
        password: 'D*z}5hQ3gu-rt\$jZ'));

    String x = '0.0';
    String y = '0.0';
    List<double> coord = [];
    List<List<double>> coord2 = [];

    var results = await conn.query(
        'SELECT * FROM EscaleraMec');

    for (var row in results) {
      x = '${row[11]}';
      double xCoord = double.parse(x);
      y = x = '${row[12]}';
      double yCoord = double.parse(y);
      coord.add(xCoord);
      coord.add(yCoord);
      coord2.add(coord);

      coord = [];
    }
    await conn.close();

    return coord2;
  }


  Future<bool> getUsuario(String nombreUsuario, String password) async {
    // Open a connection (testdb should already exist)
    final conn = await MySqlConnection.connect(ConnectionSettings(
        host: '34.175.191.14',
        port: 3306,
        user: 'root',
        db: 'bilbaoaccesible_data',
        password: 'D*z}5hQ3gu-rt\$jZ'));

    bool existe = false;

    var results = await conn.query(
        'SELECT nombre_usuario,contraseña FROM Usuarios WHERE nombre_usuario=? AND contraseña=? ',
        [nombreUsuario, password]);
    for (var row in results) {
      existe = true;
      //guardar el user
      username = nombreUsuario;
    }
    await conn.close();
    return existe;
  }


  Future<bool> registro(String nombre, String apellidos, String nombreUsuario,
      String password, String movilidad) async {
    // Open a connection (testdb should already exist)
    final conn = await MySqlConnection.connect(ConnectionSettings(
        host: '34.175.191.14',
        port: 3306,
        user: 'root',
        db: 'bilbaoaccesible_data',
        password: 'D*z}5hQ3gu-rt\$jZ'));

    //mirar que el user no esta ya
    bool insertado = false;
    var results = await conn.query(
        'SELECT nombre_usuario FROM Usuarios WHERE nombre_usuario=? ',
        [nombreUsuario]);
    if (results.isEmpty) {
      var results2 = await conn.query(
          'INSERT INTO Usuarios (nombre_usuario,nombre,apellidos,contraseña,tipo_mov_red) values (?,?,?,?,?)',
          [nombreUsuario, nombre, apellidos, password,movilidad]);
      insertado = true;
    }
    await conn.close();
    return insertado;
  }


  Future<bool> guardarRuta(String startAddress, double startLat,
      double startLng, String destinationAddress, double destinationLat,
      double destinationLng,String tipoTransporte,String nombreRuta ) async {
    // Open a connection (testdb should already exist)
    final conn = await MySqlConnection.connect(ConnectionSettings(
        host: '34.175.191.14',
        port: 3306,
        user: 'root',
        db: 'bilbaoaccesible_data',
        password: 'D*z}5hQ3gu-rt\$jZ'));

    //mirar que la ruta no esta
    var results = await conn.query(
        'SELECT startName FROM Rutas WHERE startName=? AND destinationName=? ',
        [startAddress, destinationAddress]);

    bool insertado = false;
    if (results.isEmpty) {
      var results2 = await conn.query(
          'INSERT INTO Rutas (startName, startLat, startLng, destinationName, destinationLat,destinationLng) VALUES (?,?,?,?,?,?) ',
          [
            startAddress,
            startLat,
            startLng,
            destinationAddress,
            destinationLat,
            destinationLng
          ]);
      insertado = true;
      String? username = Usuario().getUserName();

      //get id Ruta
      var results3 = await conn.query(
          'SELECT id FROM Rutas WHERE startName=? AND destinationName=? ',
          [startAddress, destinationAddress]);
      String idRuta = '';
      for (var row in results3) {
        idRuta = '${row[0]}';
      }
      //get id user
      var results4 = await conn.query(
          'SELECT id FROM Usuarios WHERE nombre_usuario=?', [username]);
      String idUser = '';
      for (var row in results4) {
        idUser = '${row[0]}';
      }
      //guardar en la tabla de rutas del user
      var results5 = await conn.query(
          'INSERT INTO Usuarios_Rut_Guard (id_usuario, id_ruta,tipo_transporte, nombre) VALUES (?,?,?,?) ',
          [idUser, idRuta,tipoTransporte,nombreRuta]);
    }
    await conn.close();
    return insertado;
  }


  Future<List<String>> getRutasUsuarioConId() async {
    final conn = await MySqlConnection.connect(ConnectionSettings(
        host: '34.175.191.14',
        port: 3306,
        user: 'root',
        db: 'bilbaoaccesible_data',
        password: 'D*z}5hQ3gu-rt\$jZ'));

    List<String> infoRutas = [];

    String? username = Usuario().getUserName();
    var results = await conn.query(
        'SELECT id FROM Usuarios WHERE nombre_usuario=?', [username]);
    String idUser = '';
    for (var row in results) {
      idUser = '${row[0]}';
    }

    //conseguir idRutas del usuario
    var results2 = await conn.query(
        'SELECT id_ruta FROM Usuarios_Rut_Guard WHERE id_usuario=?', [idUser]);
    String idRuta = '';
    for (var row in results2) {
      idRuta = '${row[0]}';

      //conseguir info de cada Ruta
      var results3 = await conn.query(
          'SELECT startName, destinationName,id FROM Rutas WHERE id=?',
          [idRuta]);

      for (var row in results3) {
        String start = '${row[0]}';
        String destination = '${row[1]}';
        String id = '${row[2]}';

        infoRutas.add("Id: $idRuta\nOrigen: $start\nDestino: $destination\n");
      }
    }
    print(infoRutas);
    return infoRutas;
  }

  Future<List<String>> getRutasUsuario() async {
    final conn = await MySqlConnection.connect(ConnectionSettings(
        host: '34.175.191.14',
        port: 3306,
        user: 'root',
        db: 'bilbaoaccesible_data',
        password: 'D*z}5hQ3gu-rt\$jZ'));

    List<String> infoRutas = [];

    String? username = Usuario().getUserName();
    var results = await conn.query(
        'SELECT id FROM Usuarios WHERE nombre_usuario=?', [username]);
    String idUser = '';
    for (var row in results) {
      idUser = '${row[0]}';
    }

    //conseguir idRutas del usuario
    var results2 = await conn.query(
        'SELECT nombre FROM Usuarios_Rut_Guard WHERE id_usuario=?', [idUser]);

    String nombreRuta = '';
    for (var row in results2) {
      nombreRuta='${row[0]}';

      infoRutas.add(nombreRuta);
    }

    print(infoRutas);
    return infoRutas;
  }

  Future<List<String>> verRutaGuardada(String idRuta) async {
    final conn = await MySqlConnection.connect(ConnectionSettings(
        host: '34.175.191.14',
        port: 3306,
        user: 'root',
        db: 'bilbaoaccesible_data',
        password: 'D*z}5hQ3gu-rt\$jZ'));

    List<String> ruta = [];
    var results = await conn.query(
        'SELECT startName, destinationName FROM Rutas WHERE id=?', [idRuta]);

    for (var row in results) {
      String start = '${row[0]}';
      String destination = '${row[1]}';
      ruta.add(start);
      ruta.add(destination);
    }


    var results3 = await conn.query(
        'SELECT tipo_transporte FROM Usuarios_Rut_Guard WHERE id_ruta=?', [idRuta]);

    for (var row in results3) {
      String transporte = '${row[0]}';
      ruta.add(transporte);
    }

    print(ruta);
    return ruta;
  }

  Future<List<String>> verRutaValorada(String idRuta) async {
    final conn = await MySqlConnection.connect(ConnectionSettings(
        host: '34.175.191.14',
        port: 3306,
        user: 'root',
        db: 'bilbaoaccesible_data',
        password: 'D*z}5hQ3gu-rt\$jZ'));

    List<String> ruta = [];
    var results = await conn.query(
        'SELECT startName, destinationName FROM Rutas WHERE id=?', [idRuta]);

    for (var row in results) {
      String start = '${row[0]}';
      String destination = '${row[1]}';
      ruta.add(start);
      ruta.add(destination);
    }

    var results2 = await conn.query(
        'SELECT puntuacion FROM Usuarios_Rut_Valor WHERE id_ruta=?', [idRuta]);

    for (var row in results2) {
      String puntuacion = '${row[0]}';
      ruta.add(puntuacion);
    }

    var results3 = await conn.query(
        'SELECT tipo_transporte FROM Usuarios_Rut_Valor WHERE id_ruta=?', [idRuta]);

    for (var row in results3) {
      String transporte = '${row[0]}';
      ruta.add(transporte);
    }

    String? username = Usuario().getUserName();
    var results4 = await conn.query(
        'SELECT tipo_mov_red FROM Usuarios WHERE nombre_usuario=?', [username]);

    for (var row in results4) {
      String movilidad = '${row[0]}';
      ruta.add(movilidad);
    }

    print(ruta);
    return ruta;
  }





  Future<bool> valorarRuta(String startAddress, double startLat,
      double startLng, String destinationAddress, double destinationLat,
      double destinationLng,String puntos, String descripcion,String tipoTransporte) async {
    // Open a connection (testdb should already exist)
    final conn = await MySqlConnection.connect(ConnectionSettings(
        host: '34.175.191.14',
        port: 3306,
        user: 'root',
        db: 'bilbaoaccesible_data',
        password: 'D*z}5hQ3gu-rt\$jZ'));

    //mirar que la ruta no esta en la tabla de Rutas general
    var results = await conn.query(
        'SELECT startName FROM Rutas WHERE startName=? AND destinationName=? ',
        [startAddress, destinationAddress]);


    if (results.isEmpty) { //si no esta, se inserta
      var results2 = await conn.query(
          'INSERT INTO Rutas (startName, startLat, startLng, destinationName, destinationLat,destinationLng) VALUES (?,?,?,?,?,?) ',
          [
            startAddress,
            startLat,
            startLng,
            destinationAddress,
            destinationLat,
            destinationLng
          ]);
    }
    //buscar el id del usuario
    String? username = Usuario().getUserName();
    var results4 = await conn.query(
        'SELECT id,tipo_mov_red FROM Usuarios WHERE nombre_usuario=?', [username]);
    String idUser = '';
    String movilidad = '';
    for (var row in results4) {
      idUser = '${row[0]}';
      movilidad = '${row[1]}';
    }

    //buscar id de la ruta
    var results3 = await conn.query(
        'SELECT id FROM Rutas WHERE startName=? AND destinationName=? ',
        [startAddress, destinationAddress]);
    String idRuta = '';
    for (var row in results3) {
      idRuta = '${row[0]}';
    }

    //mirar que el usuario no ha valorada ya la ruta
    var results6 = await conn.query(
        'SELECT id_ruta FROM Usuarios_Rut_Valor WHERE id_ruta=? AND id_usuario=(?)',
        [idRuta,idUser]);

    bool insertado = false;
    if (results.isEmpty) { //si no la ha valorado, guardar la valoracion
      //guardar valoracion
      int puntuacion=int.parse(puntos);
      var results5 = await conn.query(
          'INSERT INTO Usuarios_Rut_Valor VALUES (?,?,?,?,?) ',
          [idUser, idRuta, puntuacion, descripcion, tipoTransporte]);
      insertado=true;
    }
    await conn.close();
    return insertado;
  }



  Future<List<String>> getRutasValoradas() async {
    final conn = await MySqlConnection.connect(ConnectionSettings(
        host: '34.175.191.14',
        port: 3306,
        user: 'root',
        db: 'bilbaoaccesible_data',
        password: 'D*z}5hQ3gu-rt\$jZ'));


    List<String> infoRutas = [];


    //conseguir idRutas
    var results2 = await conn.query(
        'SELECT * FROM Usuarios_Rut_Valor');
    String idRuta = '';
    String idUser = '';
    String nombreUser = '';
    int puntuacion = 0;
    String puntuacion2='';
    String descripcion = '';
    String movilidad = '';
    String tipoTransporte = '';

    String start = '';
    String destination = '';
    for (var row in results2) {
      idUser = '${row[0]}';
      idRuta = '${row[1]}';
      puntuacion = row[2];
      puntuacion2=puntuacion.toString();
      descripcion = '${row[3]}';
      tipoTransporte='${row[4]}';


      var results4 = await conn.query(
          'SELECT nombre_usuario FROM Usuarios WHERE id=?',
          [idUser]);
      for (var row in results4) {
        nombreUser='${row[0]}';
      }

      //conseguir info de cada Ruta
      var results3 = await conn.query(
          'SELECT startName, destinationName FROM Rutas WHERE id=?',
          [idRuta]);

      for (var row in results3) {
        start = '${row[0]}';
        destination = '${row[1]}';
      }

      String? username = Usuario().getUserName();
      var results5 = await conn.query(
          'SELECT tipo_mov_red FROM Usuarios WHERE nombre_usuario=?', [username]);

      for (var row in results5) {
        movilidad = '${row[0]}';
      }

      infoRutas.add("Usuario: $nombreUser \nOrigen: $start \nDestino: $destination \nPuntuacion: $puntuacion2 \nDescripcion: $descripcion \nTipo de movilidad reducida: $movilidad \nTransporte: $tipoTransporte\n");

    }
    print(infoRutas);
    return infoRutas;
  }


  Future<List<String>> getRutaValoradaConId() async {
    final conn = await MySqlConnection.connect(ConnectionSettings(
        host: '34.175.191.14',
        port: 3306,
        user: 'root',
        db: 'bilbaoaccesible_data',
        password: 'D*z}5hQ3gu-rt\$jZ'));


    List<String> infoRutas = [];


    //conseguir idRutas
    var results2 = await conn.query(
        'SELECT * FROM Usuarios_Rut_Valor');
    String idRuta = '';
    String idUser = '';
    String nombreUser = '';
    int puntuacion = 0;
    String puntuacion2='';
    String descripcion = '';

    String start = '';
    String destination = '';
    for (var row in results2) {
      idUser = '${row[0]}';
      idRuta = '${row[1]}';
      puntuacion = row[2];
      puntuacion2=puntuacion.toString();
      descripcion = '${row[3]}';


      var results4 = await conn.query(
          'SELECT nombre_usuario FROM Usuarios WHERE id=?',
          [idUser]);
      for (var row in results4) {
        nombreUser='${row[0]}';
      }

      //conseguir info de cada Ruta
      var results3 = await conn.query(
          'SELECT startName, destinationName FROM Rutas WHERE id=?',
          [idRuta]);

      for (var row in results3) {
        start = '${row[0]}';
        destination = '${row[1]}';
      }

      infoRutas.add("Id: $idRuta \nUsuario: $nombreUser \nOrigen: $start \nDestino: $destination \nPuntuacion: $puntuacion2 \nDescripcion: $descripcion \n");

    }
    print(infoRutas);
    return infoRutas;
  }



  Future<String> getNombre() async {
    // Open a connection (testdb should already exist)
    final conn = await MySqlConnection.connect(ConnectionSettings(
        host: '34.175.191.14',
        port: 3306,
        user: 'root',
        db: 'bilbaoaccesible_data',
        password: 'D*z}5hQ3gu-rt\$jZ'));

    String? username = Usuario().getUserName();
    var results = await conn.query(
        'SELECT nombre FROM Usuarios WHERE nombre_usuario=?', [username]);
    String nombre = '';
    for (var row in results) {
      nombre = '${row[0]}';
    }
    await conn.close();
    return nombre;
  }

  Future<String> getApellidos() async {
    // Open a connection (testdb should already exist)
    final conn = await MySqlConnection.connect(ConnectionSettings(
        host: '34.175.191.14',
        port: 3306,
        user: 'root',
        db: 'bilbaoaccesible_data',
        password: 'D*z}5hQ3gu-rt\$jZ'));

    String? username = Usuario().getUserName();
    var results = await conn.query(
        'SELECT apellidos FROM Usuarios WHERE nombre_usuario=?', [username]);
    String apellidos = '';
    for (var row in results) {
      apellidos = '${row[0]}';
    }
    await conn.close();
    return apellidos;
  }

  Future<String> getNombreUsuario() async {
    // Open a connection (testdb should already exist)
    final conn = await MySqlConnection.connect(ConnectionSettings(
        host: '34.175.191.14',
        port: 3306,
        user: 'root',
        db: 'bilbaoaccesible_data',
        password: 'D*z}5hQ3gu-rt\$jZ'));

    String? username = Usuario().getUserName();
    //para que sea un string, y no un string?
    var results = await conn.query(
        'SELECT nombre_usuario FROM Usuarios WHERE nombre_usuario=?', [username]);
    String nombreUsuario = '';
    for (var row in results) {
      nombreUsuario= '${row[0]}';
    }
    await conn.close();
    return nombreUsuario;
  }

  Future<String> getMovilidad() async {
    // Open a connection (testdb should already exist)
    final conn = await MySqlConnection.connect(ConnectionSettings(
        host: '34.175.191.14',
        port: 3306,
        user: 'root',
        db: 'bilbaoaccesible_data',
        password: 'D*z}5hQ3gu-rt\$jZ'));

    String? username = Usuario().getUserName();
    //para que sea un string, y no un string?
    var results = await conn.query(
        'SELECT tipo_mov_red FROM Usuarios WHERE nombre_usuario=?', [username]);
    String movilidad = '';
    for (var row in results) {
      movilidad= '${row[0]}';
    }
    await conn.close();
    return movilidad;
  }

  Future<String> getPassword() async {
    // Open a connection (testdb should already exist)
    final conn = await MySqlConnection.connect(ConnectionSettings(
        host: '34.175.191.14',
        port: 3306,
        user: 'root',
        db: 'bilbaoaccesible_data',
        password: 'D*z}5hQ3gu-rt\$jZ'));

    String? username = Usuario().getUserName();
    //para que sea un string, y no un string?
    var results = await conn.query(
        'SELECT contraseña FROM Usuarios WHERE nombre_usuario=?', [username]);
    String password = '';
    for (var row in results) {
      password= '${row[0]}';
    }
    await conn.close();
    return password;
  }


  void editarPerfil(String usernameActual,String nombre, String apellidos, String nombreUsuario,
      String password, String movilidad) async {
    // Open a connection (testdb should already exist)
    final conn = await MySqlConnection.connect(ConnectionSettings(
        host: '34.175.191.14',
        port: 3306,
        user: 'root',
        db: 'bilbaoaccesible_data',
        password: 'D*z}5hQ3gu-rt\$jZ'));


    var results = await conn.query(
        'UPDATE Usuarios SET nombre_usuario=?, nombre=?, apellidos=?, contraseña=?, tipo_mov_red=? WHERE nombre_usuario=? ',
        [nombreUsuario, nombre, apellidos, password,movilidad,usernameActual]);

    await conn.close();
  }


  Future<List<String>> getPolygonObras() async{
    final conn = await MySqlConnection.connect(ConnectionSettings(
        host: '34.175.191.14',
        port: 3306,
        user: 'root',
        db: 'bilbaoaccesible_data',
        password: 'D*z}5hQ3gu-rt\$jZ')
    );

    List<String> polygonObras = [];

    var result = await conn.query(
        'SELECT FENCE FROM Obras WHERE FECHAINI>=?',
        ['2022-10-1 00:00:00']
    );

    for (var row in result){
      polygonObras.add(row[0]);
    }

    await conn.close();

    return polygonObras;
  }




}


