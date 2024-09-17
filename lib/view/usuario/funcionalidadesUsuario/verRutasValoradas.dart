
import 'package:bilbao_accesible/controlller/dbConn.dart';
import 'package:bilbao_accesible/model/usuario.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../origenDestinoUsuario.dart';


class VerRutasValoradas extends StatefulWidget {
  final infoRutas;
  VerRutasValoradas({Key? key,this.infoRutas}) : super(key: key);
  @override
  _MapViewState createState() => _MapViewState();


}


class _MapViewState extends State<VerRutasValoradas> {

  @override
  Widget build(BuildContext context) {
    //print(widget.infoRutas);
    List<String> infoRutas2=widget.infoRutas;
    return MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: Text('Rutas valoradas'),
          ),
          body: Center(child: RowClass(infoRutas:infoRutas2)),
        )
    );
  }
}

class RowClass extends StatelessWidget {
  final infoRutas;
  RowClass({Key? key,this.infoRutas}) : super(key: key);
  String? username=Usuario().getUserName();

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  Widget _textField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hint,
    required double width,
    required Icon prefixIcon,
    Widget? suffixIcon,
    required Function(String) locationCallback,
  }) {
    return Container(
      width: width * 0.8,
      child: TextField(
        onChanged: (value) {
          locationCallback(value);
        },
        controller: controller,
        focusNode: focusNode,
        decoration: new InputDecoration(
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(10.0),
            ),
            borderSide: BorderSide(
              color: Colors.grey.shade400,
              width: 2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(10.0),
            ),
            borderSide: BorderSide(
              color: Colors.blue,
              width: 2,
            ),
          ),
          contentPadding: EdgeInsets.all(15),
          hintText: hint,
        ),
      ),
    );
  }



  @override
  Widget build(BuildContext context) {

    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Container(
      height: height,
      width: width,
      child: InteractiveViewer(
        panEnabled: false, // Set it to false to prevent panning.
        boundaryMargin: EdgeInsets.all(100),
        minScale: 0.5,
        maxScale: 4,
        child: Scaffold(
          key: _scaffoldKey,
          body: Stack(
            children: <Widget>[
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

              //username
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
                              width: 200,
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

              SafeArea(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(top:250.0,left: 10.0,right: 10.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                            width: 900,
                            height: 400,
                            child:
                              ListView.builder(
                                itemCount: infoRutas.length,
                                itemBuilder: (context,index){
                                  return ListTile(
                                    onTap: () async {
                                      verRuta(context,index);
                                    },
                                    title: Text(infoRutas[index],
                                      style: TextStyle(fontSize: 18.0),
                                    ),
                                  );
                                })
                        ),
                      ],
                    ),
                  ),
                ),
              ),


              SafeArea(
                child: Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom:250.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Material(
                          color: Colors.white54, // button color
                          child: InkWell(
                            splashColor: Colors.black, // inkwell color
                            child: SizedBox(
                              width: 800,
                              height: 25,
                              child: Text(
                                'Pulsa en la ruta para verla en el mapa',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18.0,
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
            ],
          ),
        ),
      ),
    );
  }

  void verRuta(BuildContext context, int index) async{

    List<String> infoRutasConId=await DBconn().getRutaValoradaConId(); //el mismo metodo que getRutasValoradas, pero este tbm devuleve el id
    print(infoRutasConId);

    String infoRuta=infoRutasConId[index]; //consigues la ruta que ha clickado


    List<String> lineas = infoRuta.split("\n");
    String id = lineas[0].replaceAll("Id: ", "").replaceAll(" ", "");  //id de la ruta clickada
    print(id);

    List<String> ruta = await DBconn().verRutaValorada(id);
    print(ruta);
    String puntuacion=ruta[2].toString();

    Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => OrigenDestinoUsuario(origen:ruta[0],destino:ruta[1],puntuacion:puntuacion,tipoTransporte:ruta[3])));
   }
}