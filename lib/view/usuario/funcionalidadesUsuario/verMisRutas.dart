import 'package:bilbao_accesible/controlller/dbConn.dart';
import 'package:bilbao_accesible/model/usuario.dart';
import 'package:bilbao_accesible/view/usuario/origenDestinoUsuario.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:maps_toolkit/maps_toolkit.dart' as toolkit;


class verMisRutas extends StatefulWidget {
  final infoRutas;
  verMisRutas({Key? key,this.infoRutas}) : super(key: key);

  @override
  _MapViewState createState() => _MapViewState();


}

class _MapViewState extends State<verMisRutas> {

  List<List<toolkit.LatLng>> poligonos =[];
  Set<Marker> markers = {};
  late GoogleMapController mapController;
  List<LatLng> polylineCoordinates = [];
  late PolylinePoints polylinePoints;
  Map<PolylineId, Polyline> polylines = {};
  static const API_KEY = 'AIzaSyDQG8Z9o5vxJjJWehCS9kDxdDa_f_teSgQ';
  List<List<LatLng>> poligonosLag =[];
  List<bool> rutasConObras=[];
  int rutasAMostrar = 1;

  String? username = Usuario().getUserName();

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _getObras();
    buscarObras();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery
        .of(context)
        .size
        .height;
    var width = MediaQuery
        .of(context)
        .size
        .width;

    return MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: Text('Rutas guardadas'),
          ),
          body: Center(
            child: Container(
              height: height,
              width: width,
              child: Scaffold(
                key: _scaffoldKey,
                body: Stack(
                  children: <Widget>[
                    SafeArea(
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(
                              bottom: 500.0, left: 100.0, right: 100.0),
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
                                    child: Icon(
                                      Icons.person_outline_outlined, size: 100.0,
                                      color: Colors.white,),
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
                          padding: const EdgeInsets.only(
                              bottom: 385.0, left: 100.0, right: 100.0),
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
                                      itemCount: rutasAMostrar,
                                      itemBuilder: (context,index){
                                        return ListTile(
                                          onTap: () async {
                                            verRuta(context, index);
                                          },
                                          title: getRutaEstilo(index),
                                          leading:getIconEstilo(index),
                                        );

                                      }
                                  )
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),


                  //username
                  SafeArea(
                    child: Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 250.0),
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
          ),
        )
    );
  }

  Text getRutaEstilo(int index){
    List<String> infoRutas=widget.infoRutas;
    if(rutasConObras.length>0){
      if(rutasConObras[index]){
        return Text(infoRutas[index], style: TextStyle(fontSize: 18.0,color: Colors.red));
      }
      else{
        return Text(infoRutas[index], style: TextStyle(fontSize: 18.0,color: Colors.black));
      }
    }
    else{
      return Text('Cargando rutas...', style: TextStyle(fontSize: 25.0,color: Colors.black));
    }
  }

  Widget getIconEstilo(int index){
    List<String> infoRutas=widget.infoRutas;
    Widget icono=Icon(Icons.route_outlined, size: 25.0, color: Colors.black);
    if(rutasConObras.length>0){
      if(rutasConObras[index]){
         icono= Image.asset('assets/iconos_botones/obras_blanco.png',color: Colors.red,width: 32, height: 32);
      }
      else{
        icono= Icon(Icons.route_outlined, size: 25.0, color: Colors.black);
      }
    }
    return icono;
  }

  void verRuta(BuildContext context,int index) async {

    List<String> infoRutasConId=await DBconn().getRutasUsuarioConId(); //el mismo metodo que getRutasUsuario, pero este tbm devuleve el id


    String infoRuta=infoRutasConId[index]; //consigues la ruta que ha clickado


    List<String> lineas = infoRuta.split("\n");
    String id = lineas[0].replaceAll("Id: ", "").replaceAll(" ", "");


    List<String> ruta = await DBconn().verRutaGuardada(id);

    //le pasas null como string, porque no tiene valoracion (no es una ruta valorada), y en DibujarRuta, si puntuacion es null lo pones invisible
    Navigator.push(
        context,
        MaterialPageRoute(builder: (context) =>
            OrigenDestinoUsuario(
                origen: ruta[0], destino: ruta[1], puntuacion: null, tipoTransporte:ruta[2])));
  }


  buscarObras() async {
    List<String> infoRutasConId=await DBconn().getRutasUsuarioConId(); //el mismo metodo que getRutasUsuario, pero este tbm devuleve el id

    for(var ruta in infoRutasConId){
      List<String> lineas = ruta.split("\n");

      String origen = lineas[1].replaceAll("Origen: ", "");

      String destino = lineas[2].replaceAll("Destino: ", "");

      bool aurkituta= await buscarObrasRuta(origen, destino);
      rutasConObras.add(aurkituta);
    }
    // cuando se acabe de buscar las obras hay que actualizar para cargar lo nombres
    setState(() {
      rutasAMostrar = infoRutasConId.length;
    });
  }

  Future<bool> buscarObrasRuta(String origen, String destino) async {
    // Retrieving placemarks from addresses
    List<Location>? startPlacemark = await locationFromAddress(origen);
    List<Location>? destinationPlacemark = await locationFromAddress(destino);

    // Use the retrieved coordinates of the current position,
    // instead of the address if the start position is user's
    // current position, as it results in better accuracy.
    double startLatitude = startPlacemark[0].latitude;
    double startLongitude = startPlacemark[0].longitude;

    double destinationLatitude = destinationPlacemark[0].latitude;
    double destinationLongitude = destinationPlacemark[0].longitude;



    bool aurkituta= await _createPolylines(startLatitude, startLongitude, destinationLatitude,
        destinationLongitude);

    return aurkituta;
  }

  Future<bool> _createPolylines(
      double startLatitude,
      double startLongitude,
      double destinationLatitude,
      double destinationLongitude,
      ) async {
    polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      API_KEY, // Google Maps API Key
      PointLatLng(startLatitude, startLongitude),
      PointLatLng(destinationLatitude, destinationLongitude),
      travelMode: TravelMode.driving,
    );

    bool irten=false;
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) { //TODO aunk haya encontrado un punto sigue bucleando, salir(?)
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        int i=0;
        while(i<poligonos.length && !irten){
          if (toolkit.PolygonUtil.containsLocation(toolkit.LatLng(point.latitude, point.longitude),poligonos[i],true)){ //conseguimos el poligono i que queremos
            irten=true;
          }
          i=i+1;
        }
      });

    }
    return irten;
  }

  void _getObras() async{
    DBconn().getPolygonObras().then((result){
      for(var row in result){
        var latslngs = row.split(',');
        List<LatLng> polygonLatLngs = <LatLng>[];
        List<toolkit.LatLng> polygonLatLngs2 = <toolkit.LatLng>[];
        for(int i = 0; i < latslngs.length-1; i+=2){
          double lat = double.parse(latslngs[i+1]);
          double lng = double.parse(latslngs[i]);
          polygonLatLngs.add(LatLng(lat,lng));
          polygonLatLngs2.add(toolkit.LatLng(lat,lng));

        }
        poligonosLag.add(polygonLatLngs);
        poligonos.add(polygonLatLngs2);
      }

    });
  }



}
