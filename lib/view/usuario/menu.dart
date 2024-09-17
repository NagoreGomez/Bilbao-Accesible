import 'package:flutter/material.dart';

import 'package:bilbao_accesible/controlller/dbConn.dart';
import 'package:bilbao_accesible/view/usuario/funcionalidadesUsuario/guardarRuta.dart';
import 'package:bilbao_accesible/view/usuario/funcionalidadesUsuario/valorarRuta.dart';
import 'package:bilbao_accesible/view/usuario/funcionalidadesUsuario/verMisRutas.dart';
import 'package:bilbao_accesible/view/usuario/funcionalidadesUsuario/verRutasValoradas.dart';
import 'package:bilbao_accesible/model/usuario.dart';

import 'funcionalidadesUsuario/editarPerfil.dart';


class MenuUsuario extends StatefulWidget {
  @override
  _MapViewState createState() => _MapViewState();
}

class _MapViewState extends State<MenuUsuario> {

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    String? username=Usuario().getUserName();
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Container(
      height: height,
      width: width,
      child: Scaffold(
        key: _scaffoldKey,
        body: Stack(
          children: <Widget>[
            /// Caja azul con icono persona
            SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom:500.0,left: 100.0,right: 100.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                        Material(
                          color: Colors.blue, // button color
                          child: InkWell(
                            splashColor: Colors.black, // inkwell color
                            child: SizedBox(
                              width: 230,
                              height: 170,
                              child: Icon(Icons.person_outline_outlined,size: 100.0,color: Colors.white,),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            /// Username
            SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom:385.0,left: 100.0,right: 100.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Material(
                        color: Colors.blue, // button color
                        child: InkWell(
                          splashColor: Colors.black, // inkwell color
                          child: SizedBox(
                            width: 230,
                            height: 30,
                            child: Text(
                              '$username',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            ///BOTONES
            SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: 100.0,left: 10.0,right: 10.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[

                      /// BOTON EDITAR PERFIL
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) =>
                                EditarPerfil()
                              )
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          fixedSize: Size(300, 50),
                        ),
                        child: Text(
                          'EDITAR PERFIL',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.0,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),

                      /// GUARDAR RUTA
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => GuardarRuta()));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          fixedSize: Size(300, 50),
                        ),
                        child: Text(
                          'GUARDAR RUTA',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.0,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),


                      /// RUTAS GUARDADAS
                      ElevatedButton(
                        onPressed: () {
                          getMisRutas();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          fixedSize: Size(300, 50),
                        ),
                        child: Text(
                          'RUTAS GURDADAS',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.0,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),


                      /// VALORAR RUTA
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => ValorarRuta()));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          fixedSize: Size(300, 50),
                        ),
                        child: Text(
                          'VALORAR RUTA',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.0,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),


                      /// BOTON VALORAR RUTA
                      ElevatedButton(
                        onPressed: () {
                          getRutasValoradas();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          fixedSize: Size(300, 50),
                        ),
                        child: Text(
                          'VER RUTAS VALORADAS',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  late List<String> infoRutas=[];
  void getMisRutas() async{
    var list= await DBconn().getRutasUsuario();
    infoRutas=list;
    Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => verMisRutas(infoRutas:infoRutas)));
  }

  late List<String> infoRutasvaloradas=[];
  void getRutasValoradas() async{
    var list= await DBconn().getRutasValoradas();
    infoRutasvaloradas=list;
    Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => VerRutasValoradas(infoRutas:infoRutasvaloradas)));
  }
}