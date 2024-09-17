

import 'dart:convert';

import 'package:bilbao_accesible/controlller/dbConn.dart';
import 'package:bilbao_accesible/view/usuario/origenDestinoUsuario.dart';
import 'package:bilbao_accesible/view/usuario/menu.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';


import '../components/capasDatos.dart';



class OrigenUsuario extends StatefulWidget {
  @override
  _MapViewState createState() => _MapViewState();
}

class _MapViewState extends State<OrigenUsuario> {




  CameraPosition _camaraBilbao = CameraPosition(target: LatLng(43.263101512963964, -2.9351218790702007),zoom:12.8);
  late GoogleMapController mapController;

  late Position _currentPosition;


  String _currentAddress = '';

  final startAddressController = TextEditingController();

  final startAddressFocusNode = FocusNode();

  String _startAddress = '';

  Set<Marker> markers = {};
  Set<Marker> markersAScensorGratuito = {};
  Set<Marker> markersAScensorPago = {};
  Set<Marker> markersEscalera = {};


  Set<Polygon> _polygons = Set<Polygon>();
  int _polygonIdCounter = 1;


  final _scaffoldKey = GlobalKey<ScaffoldState>();

  bool ascensoresGratuitosPuestos=false;
  bool ascensoresDePagoPuestos=false;
  bool escalerasPuestas=false;
  bool obrasPuestas=false;

  late BitmapDescriptor markerAscensor;
  late BitmapDescriptor markerAscensorPago;
  late BitmapDescriptor markerObras;
  late BitmapDescriptor markerEscaleraMec;


  BitmapDescriptor markerIcon=BitmapDescriptor.defaultMarker;


  late CapasDatos botonesCapaDatos;

  int currentPageIndex = 0;

  void _getObras() async{
    DBconn().getPolygonObras().then((result){
      for(var row in result){
        var latslngs = row.split(',');
        List<LatLng> polygonLatLngs = <LatLng>[];
        for(int i = 0; i < latslngs.length-1; i+=2){
          double lat = double.parse(latslngs[i+1]);
          double lng = double.parse(latslngs[i]);
          polygonLatLngs.add(LatLng(lat,lng));
        }

        _setPolygon(polygonLatLngs);
      }
      mapController.animateCamera(CameraUpdate.newCameraPosition(_camaraBilbao));
    });
  }

  /// Método para crear, guardar y mostrar 1 polígono
  void _setPolygon(List<LatLng> latlngs){
    final String polygonIdVal = 'polygon_$_polygonIdCounter';
    _polygonIdCounter++;

    setState(() {
      _polygons.add(Polygon(
        polygonId: PolygonId(polygonIdVal),
        points: latlngs,
        strokeWidth: 2,
        fillColor: Colors.red.withOpacity(0.5),
      ));
    });
  }

  void _tratarPulsacionBtnCapas(int capa){
    if(capa == 0){
      if (!ascensoresGratuitosPuestos){
        ascensoresGratuitosPuestos=true;
        _getAscensoresGratuitos();
      }
      else{
        ascensoresGratuitosPuestos=false;
        setState((){
          markers.removeAll(markersAScensorGratuito);
        });
      }
    }
    else if(capa == 1){
      if (!ascensoresDePagoPuestos){
        ascensoresDePagoPuestos=true;
        _getAscensoresDePago();
      }
      else{
        ascensoresDePagoPuestos=false;
        setState((){
          markers.removeAll(markersAScensorPago);

        });
      }
    }
    else if(capa == 2){
      if (!escalerasPuestas){
        escalerasPuestas=true;
        _getEscaleras();
      }
      else{
        escalerasPuestas=false;

        setState((){
          markers.removeAll(markersEscalera);
        });
      }
    }
    else {
      if(!obrasPuestas){
        obrasPuestas=true;
        _getObras();
      }
      else{
        obrasPuestas=false;
        setState((){
          _polygons.clear();
        });
      }
    }
  }

  void _tratarPulsacionBtnMyLocation() async{
    LocationPermission permission;
    permission = await Geolocator.requestPermission();
    mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(
            _currentPosition.latitude,
            _currentPosition.longitude,
          ),
          zoom: 16.0,
        ),
      ),
    );
  }



  void addIconAscensor(){
    BitmapDescriptor.fromAssetImage(const ImageConfiguration(), "assets/images/ascensor.png")
        .then(
            (icon){
          setState(() {
            markerAscensor=icon;
          });
        }
    );
  }

  void addIconAscensorPago(){
    BitmapDescriptor.fromAssetImage(const ImageConfiguration(), "assets/images/ascensorPago.png")
        .then(
            (icon){
          setState(() {
            markerAscensorPago=icon;
          });
        }
    );
  }

  void addIconObras(){
    BitmapDescriptor.fromAssetImage(const ImageConfiguration(), "assets/images/ascensor.png")
        .then(
            (icon){
          setState(() {
            markerObras=icon;
          });
        }
    );
  }

  void addIconEscaleraMec(){
    BitmapDescriptor.fromAssetImage(const ImageConfiguration(), "assets/images/Marcador_escaleraMec_txiki.png")
        .then(
            (icon){
          setState(() {
            markerEscaleraMec=icon;
          });
        }
    );
  }


  @override
  void initState() {
    _getCurrentLocation();
    super.initState();
    markers.clear();
    addIconAscensor();
    addIconAscensorPago();
    addIconObras();
    addIconEscaleraMec();
    botonesCapaDatos = CapasDatos(_tratarPulsacionBtnCapas, _tratarPulsacionBtnMyLocation);

  }




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

  // Method for retrieving the current location
  _getCurrentLocation() async {
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) async {
      setState(() {
        _currentPosition = position;
        mapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(position.latitude, position.longitude),
              zoom: 16.0,
            ),
          ),
        );
      });
      await _getAddress();
    }).catchError((e) {
      print(e);
    });
  }

  // Method for retrieving the address
  _getAddress() async {
    try {
      List<Placemark> p = await placemarkFromCoordinates(
          _currentPosition.latitude, _currentPosition.longitude);

      Placemark place = p[0];

      setState(() {
        _currentAddress =
        "${place.name}, ${place.locality}, ${place.postalCode}, ${place.country}";
        //startAddressController.text = _currentAddress;
        //_startAddress = _currentAddress;
      });
    } catch (e) {
      print(e);
    }
  }

  // Method for calculating the distance between two places
  _buscar() async {

    //if (markers.isNotEmpty) markers.clear();
    // Retrieving placemarks from addresses
    List<Location>? startPlacemark = await locationFromAddress(_startAddress);

    // Use the retrieved coordinates of the current position,
    // instead of the address if the start position is user's
    // current position, as it results in better accuracy.
    double startLatitude = _startAddress == _currentAddress
        ? _currentPosition.latitude
        : startPlacemark[0].latitude;

    double startLongitude = _startAddress == _currentAddress
        ? _currentPosition.longitude
        : startPlacemark[0].longitude;


    String startCoordinatesString = '($startLatitude, $startLongitude)';


    // Start Location Marker
    Marker startMarker = Marker(
      markerId: MarkerId(startCoordinatesString),
      position: LatLng(startLatitude, startLongitude),
      infoWindow: InfoWindow(
        title: 'Start $startCoordinatesString',
        snippet: _startAddress,
      ),
      icon: BitmapDescriptor.defaultMarker,
    );


    markers.clear();

    // Adding the markers to the list
    //markers.add(startMarker);


    // Accommodate the two locations within the
    // camera view of the map
    mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target:LatLng(startLatitude, startLongitude),zoom:16),
      ),
    );
    setState(() {
      markers.add(startMarker);
    });
  }


  _getAscensoresGratuitos() async {
    List<List<double>> coord=[];
    String x='0.0';
    String y='0.0';

    DBconn().getAscensoresGratuitos().then((value) {
      coord=value;
      for (var row in coord){
        x='${row[0]}';
        y='${row[1]}';
        double lng=double.parse(x);
        double lat=double.parse(y);
        String startCoordinatesString = '($lat, $lng)';
        // Start Location Marker
        Marker startMarker = Marker(
          markerId: MarkerId(startCoordinatesString),
          position: LatLng(lat,lng),
          icon: markerAscensor
          ,// marcador nuestro markerIcon,
        );

        markersAScensorGratuito.add(startMarker);
        setState(() {
          markers.add(startMarker);
        });
      }
    });
    mapController.animateCamera(CameraUpdate.newCameraPosition(_camaraBilbao));
  }



  _getAscensoresDePago() async {
    List<List<double>> coord=[];
    String x='0.0';
    String y='0.0';

    DBconn().getAscensoresDePago().then((value) {
      coord=value;
      for (var row in coord){
        x='${row[0]}';
        y='${row[1]}';
        double lng=double.parse(x);
        double lat=double.parse(y);
        String startCoordinatesString = '($lat, $lng)';
        // Start Location Marker
        Marker startMarker = Marker(
          markerId: MarkerId(startCoordinatesString),
          position: LatLng(lat,lng),
          icon: markerAscensorPago,// marcador nuestro markerIcon,
        );

        markersAScensorPago.add(startMarker);
        setState(() {
          markers.add(startMarker);
        });
      }
    });
    mapController.animateCamera(CameraUpdate.newCameraPosition(_camaraBilbao));
  }


  _getEscaleras() async {
    List<List<double>> coord=[];
    String x='0.0';
    String y='0.0';

    DBconn().getEscaleras().then((value) {
      coord=value;
      for (var row in coord){
        x='${row[0]}';
        y='${row[1]}';
        double lng=double.parse(x);
        double lat=double.parse(y);
        String startCoordinatesString = '($lat, $lng)';
        // Start Location Marker
        Marker startMarker = Marker(
          markerId: MarkerId(startCoordinatesString),
          position: LatLng(lat,lng),
          icon: markerEscaleraMec, // marcador nuestro markerIcon
        );


        markersEscalera.add(startMarker);
        setState(() {
          markers.add(startMarker);
        });
      }
    });
    mapController.animateCamera(CameraUpdate.newCameraPosition(_camaraBilbao));
  }




  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    bool autocompletado=false;

    return Container(
      height: height,
      width: width,
      child: Scaffold(
        key: _scaffoldKey,
        body: Stack(
          children: <Widget>[
            // Map View
            GoogleMap(
              markers: Set<Marker>.from(markers),
              polygons: _polygons, //indicamos de donde pinta polígonos
              initialCameraPosition: _camaraBilbao,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              mapType: MapType.hybrid,
              zoomGesturesEnabled: true,
              zoomControlsEnabled: false,
              onMapCreated: (GoogleMapController controller) {
                mapController = controller;
              },
            ),
            // Show zoom buttons

            // Show the place input fields & button for
            // showing the route
            SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: 0.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white60,
                      borderRadius: BorderRadius.all(
                        Radius.circular(20.0),
                      ),
                    ),
                    width: width * 0.9,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[

                          SizedBox(height: 10),
                          _textField(
                              label: 'Origen',
                              hint: 'Origen',
                              prefixIcon: Icon(TablerIcons.square_letter_a),
                              suffixIcon: IconButton(
                                icon: Icon(Icons.my_location),
                                onPressed: () {
                                  startAddressController.text = _currentAddress;
                                  _startAddress = _currentAddress;
                                },
                              ),
                              controller: startAddressController,
                              focusNode: startAddressFocusNode,
                              width: width,
                              locationCallback: (String value) {
                                setState(() {

                                  height=50.0;
                                  autocompletado=true;
                                  _startAddress = value;
                                });
                              }),

                          SizedBox(height: 5),
                          ElevatedButton(
                            onPressed: (_startAddress != '')
                                ? () async {
                              startAddressFocusNode.unfocus();
                              _buscar();

                            }
                                : null,
                            // color: Colors.red,
                            // shape: RoundedRectangleBorder(
                            //   borderRadius: BorderRadius.circular(20.0),
                            // ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(Icons.search), //se puede quitar esto y poner el texto
                              /*Text(
                                'Buscar ruta'.toUpperCase(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20.0,
                                ),
                              ),
                               */
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Show current location button
            botonesCapaDatos.getCrrntLctBtn(),

            //Boton ascensores gratis
            botonesCapaDatos.getBotonAscGratis(),

            //Botón ascensores de pago
            botonesCapaDatos.getBotonAscPago(),

            //Botón escaleras mecánicas
            botonesCapaDatos.getEscaleraMec(),

            // Boton obras
            botonesCapaDatos.getObras(),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          onDestinationSelected: (int index) {
            if(index == 1){
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>
                      OrigenDestinoUsuario(
                          origen: ' ',
                          destino: ' ',
                          puntuacion: 'null',
                          tipoTransporte: ' '
                      )));
              setState(() {
                currentPageIndex = index;
              });
            }
            else if(index == 2){
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MenuUsuario()));
            }
          },
          selectedIndex: currentPageIndex,
          height: 60,
          backgroundColor: Colors.grey.shade100,
          surfaceTintColor: Colors.blue.shade800,
          destinations: const <Widget>[
            NavigationDestination(
              icon: Icon(Icons.location_on),
              label: 'Sitios',
            ),
            NavigationDestination(
              icon: Icon(Icons.route),
              label: 'Ruta',
            ),
            NavigationDestination(
              icon: Icon(Icons.menu),
              label: 'Menu',
            ),
          ],
        ),
      ),
    );
  }

  formItemsDesign(icon, item) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 7),
      child: Card(child: ListTile(leading: Icon(icon), title: item)),
    );
  }





}


// VIDEO AUTOCOMPLETADO: