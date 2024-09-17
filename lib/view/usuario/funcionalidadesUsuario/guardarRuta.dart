
import 'package:bilbao_accesible/controlller/dbConn.dart';
import 'package:bilbao_accesible/view/usuario/menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


import 'dart:math' show cos, sqrt, asin;
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import 'package:maps_toolkit/maps_toolkit.dart' as toolkit;

import '../../components/capasDatos.dart';




class GuardarRuta extends StatefulWidget {
  @override
  _MapViewState createState() => _MapViewState();
}

class _MapViewState extends State<GuardarRuta> {
  CameraPosition _camaraBilbao = CameraPosition(target: LatLng(43.263101512963964, -2.9351218790702007),zoom:12.8);
  late GoogleMapController mapController;

  late Position _currentPosition;


  String _currentAddress = '';

  final startAddressController = TextEditingController();
  final destinationAddressController = TextEditingController();

  final startAddressFocusNode = FocusNode();
  final desrinationAddressFocusNode = FocusNode();

  String _startAddress = '';
  String _destinationAddress = '';
  String? _placeDistance;

  Set<Marker> markers = {};
  Set<Marker> markersAScensorGratuito = {};
  Set<Marker> markersAScensorPago = {};
  Set<Marker> markersEscalera = {};

  late PolylinePoints polylinePoints;
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  Set<Polygon> _polygons = Set<Polygon>();
  Set<Polygon> _polygonsLag = Set<Polygon>();
  int _polygonIdCounter = 1;
  List<List<toolkit.LatLng>> poligonos =[];
  List<List<LatLng>> poligonosLag =[];

  bool ascensoresGratuitosPuestos=false;
  bool ascensoresDePagoPuestos=false;
  bool escalerasPuestas=false;
  bool obrasPuestas=false;

  BitmapDescriptor markerAscensor=BitmapDescriptor.defaultMarker;
  BitmapDescriptor markerAscensorPago=BitmapDescriptor.defaultMarker;
  BitmapDescriptor markerObras=BitmapDescriptor.defaultMarker;
  BitmapDescriptor markerEscaleraMec=BitmapDescriptor.defaultMarker;
  BitmapDescriptor markerStart = BitmapDescriptor.defaultMarker;
  BitmapDescriptor markerDestination = BitmapDescriptor.defaultMarker;

  String _tipoTransporte='Coche';

  static const API_KEY = 'AIzaSyDQG8Z9o5vxJjJWehCS9kDxdDa_f_teSgQ';

  late CapasDatos botonesCapaDatos;

  /// Indica si la vista a recibido datos para dibujar una linea desde el
  /// principio
  late bool _recibeParametros;

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

  void addIconStart(){
    BitmapDescriptor.fromAssetImage(const ImageConfiguration(), "assets/images/markerA.png")
        .then(
            (icon){
          setState(() {
            markerStart=icon;
          });
        }
    );
  }

  void addIconDestination(){
    BitmapDescriptor.fromAssetImage(const ImageConfiguration(), "assets/images/markerB.png")
        .then(
            (icon){
          setState(() {
            markerDestination=icon;
          });
        }
    );
  }





  @override
  void initState() {
    _getCurrentLocation();

    markers.clear();
    addIconAscensor();
    addIconAscensorPago();
    addIconObras();
    addIconEscaleraMec();
    addIconStart();
    addIconDestination();
    botonesCapaDatos = CapasDatos(_tratarPulsacionBtnCapas, _tratarPulsacionBtnMyLocation);
    super.initState();
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

  // Method for calculating the distance between two places (y guardar la ruta)
  Future<bool> _calculateDistance() async {
    try {
      // Retrieving placemarks from addresses
      List<Location>? startPlacemark = await locationFromAddress(_startAddress);
      List<Location>? destinationPlacemark =
      await locationFromAddress(_destinationAddress);

      // Use the retrieved coordinates of the current position,
      // instead of the address if the start position is user's
      // current position, as it results in better accuracy.
      double startLatitude = _startAddress == _currentAddress
          ? _currentPosition.latitude
          : startPlacemark[0].latitude;

      double startLongitude = _startAddress == _currentAddress
          ? _currentPosition.longitude
          : startPlacemark[0].longitude;

      double destinationLatitude = destinationPlacemark[0].latitude;
      double destinationLongitude = destinationPlacemark[0].longitude;

      String startCoordinatesString = '($startLatitude, $startLongitude)';
      String destinationCoordinatesString =
          '($destinationLatitude, $destinationLongitude)';

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

      // Destination Location Marker
      Marker destinationMarker = Marker(
        markerId: MarkerId(destinationCoordinatesString),
        position: LatLng(destinationLatitude, destinationLongitude),
        infoWindow: InfoWindow(
          title: 'Destination $destinationCoordinatesString',
          snippet: _destinationAddress,
        ),
        icon: BitmapDescriptor.defaultMarker,
      );

      // Adding the markers to the list
      markers.add(startMarker);
      markers.add(destinationMarker);



      // Calculating to check that the position relative
      // to the frame, and pan & zoom the camera accordingly.
      double miny = (startLatitude <= destinationLatitude)
          ? startLatitude
          : destinationLatitude;
      double minx = (startLongitude <= destinationLongitude)
          ? startLongitude
          : destinationLongitude;
      double maxy = (startLatitude <= destinationLatitude)
          ? destinationLatitude
          : startLatitude;
      double maxx = (startLongitude <= destinationLongitude)
          ? destinationLongitude
          : startLongitude;

      double southWestLatitude = miny;
      double southWestLongitude = minx;

      double northEastLatitude = maxy;
      double northEastLongitude = maxx;

      // Accommodate the two locations within the
      // camera view of the map
      mapController.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            northeast: LatLng(northEastLatitude, northEastLongitude),
            southwest: LatLng(southWestLatitude, southWestLongitude),
          ),
          100.0,
        ),
      );

      // Calculating the distance between the start and the end positions
      // with a straight path, without considering any route
      // double distanceInMeters = await Geolocator().bearingBetween(
      //   startCoordinates.latitude,
      //   startCoordinates.longitude,
      //   destinationCoordinates.latitude,
      //   destinationCoordinates.longitude,
      // );


      _showAlertDialog3(_startAddress,startLatitude,startLongitude,_destinationAddress,destinationLatitude,destinationLongitude,_tipoTransporte);



      await _createPolylines(startLatitude, startLongitude, destinationLatitude,
          destinationLongitude);

      double totalDistance = 0.0;

      // Calculating the total distance by adding the distance
      // between small segments
      for (int i = 0; i < polylineCoordinates.length - 1; i++) {
        totalDistance += _coordinateDistance(
          polylineCoordinates[i].latitude,
          polylineCoordinates[i].longitude,
          polylineCoordinates[i + 1].latitude,
          polylineCoordinates[i + 1].longitude,
        );
      }

      setState(() {
        _placeDistance = totalDistance.toStringAsFixed(2);
      });

      return true;
    } catch (e) {
      print(e);
    }
    return false;
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController  nombreRutaCrtl = new TextEditingController();



  Future<void> _showAlertDialog3(String startAddress, double startLatitude, double startLongitude,String destinationAddress,double destinationLatitude,double destinationLongitude, String tipoTransporte) async {

    return await showDialog(
        context: context,
        builder: (context) {
          bool isChecked = false;
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              title: Text('Guardar ruta'),
              content: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: nombreRutaCrtl,
                        decoration: new InputDecoration(
                          labelText: 'Escribe el nombre de la ruta',
                        ),
                      ),
                    ],
                  )),
              actions: <Widget>[
                ElevatedButton(
                  child: Text("Guardar", style: TextStyle(color: Colors.blue),),
                  onPressed: () async {
                    // Do something like updating SharedPreferences or User Settings etc.
                    if(nombreRutaCrtl.text.isEmpty){
                      _showAlertDialog4();
                    }
                    else{
                      bool bien= await validate(nombreRutaCrtl.text, startAddress,  startLatitude,  startLongitude, destinationAddress, destinationLatitude, destinationLongitude, tipoTransporte);
                      if(bien){
                        _showAlertDialog2();
                      }
                    }
                  },
                ),
              ],
            );
          });
        });

  }

  Future<bool> validate(String nombreRuta,String startAddress, double startLatitude, double startLongitude,String destinationAddress,double destinationLatitude,double destinationLongitude,String tipoTransporte) async {
    bool bien=false;
    String pattern = r'(^[a-zA-Z\.\- À-ÿ0-9]*$)';
    RegExp regExp = new RegExp(pattern);
    if (regExp.hasMatch(nombreRuta)) {
      Navigator.of(context).pop();

      bool insertado= await DBconn().guardarRuta(startAddress,  startLatitude,  startLongitude, destinationAddress, destinationLatitude, destinationLongitude, tipoTransporte, nombreRuta);

      if(insertado){ //se ha valorado bien
        bien=true;
      }
      else{ //ya la tenia valorada
        _showAlertDialog4();
      }

    }
    return bien;
  }





  // Formula for calculating distance between two coordinates
  // https://stackoverflow.com/a/54138876/11910277
  double _coordinateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
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

    return MaterialApp(
        home: Scaffold(
        appBar: AppBar(
        title: Text('Guardar ruta'),
    ),
    body: Container(
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
              polylines: Set<Polyline>.of(polylines.values),
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
                  padding: const EdgeInsets.only(top: 10.0),
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
                                  _startAddress = value;
                                });
                              }),
                          SizedBox(height: 10),
                          _textField(
                              label: 'Destino',
                              hint: 'Destino',
                              prefixIcon: Icon(TablerIcons.square_letter_b),
                              controller: destinationAddressController,
                              focusNode: desrinationAddressFocusNode,
                              width: width,
                              locationCallback: (String value) {
                                setState(() {
                                  _destinationAddress = value;
                                });
                              }),
                          SizedBox(height: 10),

                          ElevatedButton(
                            onPressed: (_startAddress != '' &&
                                _destinationAddress != '')
                                ? () async {
                              startAddressFocusNode.unfocus();
                              desrinationAddressFocusNode.unfocus();
                              setState(() {
                                if (markers.isNotEmpty) markers.clear();
                                if (polylines.isNotEmpty)
                                  polylines.clear();
                                if (polylineCoordinates.isNotEmpty)
                                  polylineCoordinates.clear();
                                _placeDistance = null;
                              });

                              _calculateDistance().then((isCalculated) {
                                if (isCalculated) {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Calculando ruta...'),
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(
                                    SnackBar(
                                      content: Text(

                                          'La ruta no es correcta'),
                                    ),
                                  );
                                }
                              });
                            }
                                : null,
                            // color: Colors.red,
                            // shape: RoundedRectangleBorder(
                            //   borderRadius: BorderRadius.circular(20.0),
                            // ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(Icons.save), //se puede quitar esto y poner el texto
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
                          SizedBox(height: 10),
                          Visibility(
                            visible: _placeDistance == null ? false : true,
                            child: Text(
                              'Distancia: $_placeDistance km',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade600,
                              ),
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
            SafeArea(
              child: Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 10.0, bottom: 25.0),
                  child: ClipOval(
                    child: Material(
                      color: Colors.blue, // button color
                      child: InkWell(
                        splashColor: Colors.black, // inkwell color
                        child: SizedBox(
                          width: 56,
                          height: 56,
                          child: Icon(Icons.my_location,color: Colors.white),
                        ),
                        onTap: () async {
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
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),

            BotonCoche(_tipoTransporte, _cambiarModo),

            //Botón andando
            BotonAndando(_tipoTransporte, _cambiarModo),

            //Botón transporte público
            BotonTransportePublico(_tipoTransporte, _cambiarModo),

            //Botón bici
            BotonBici(_tipoTransporte, _cambiarModo),

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
                ),

    ),
    ),
    );
  }

  void _showAlertDialog2() {
    showDialog(
        context: context,
        builder: (buildcontext) {
          return AlertDialog(
            title: Text("Ruta guardada"),
            content: Text("La ruta se ha guardado correctamente."),
            actions: <Widget>[
              ElevatedButton(
                child: Text("Cerrar", style: TextStyle(color: Colors.blue),),
                onPressed: (){ Navigator.of(context).pop(); },
              )
            ],
          );
        }
    );
  }

  void _showAlertDialog4() {
    showDialog(
        context: context,
        builder: (buildcontext) {
          return AlertDialog(
            title: Text("Ruta no guardada"),
            content: Text("Debes escribir un nombre para la ruta."),
            actions: <Widget>[
              ElevatedButton(
                child: Text("Cerrar", style: TextStyle(color: Colors.blue),),
                onPressed: (){ Navigator.of(context).pop(); },
              )
            ],
          );
        }
    );
  }

  void _moduaAldatu(String modua){
    setState((){ //utilizamos la función "setState" para que se actualice toda la UI (interfaz)
      _tipoTransporte = modua;
    });
  }
  /// Recibe el parámetro [modua] que se utiliza para cambiar el modo de
  /// busqueda de ruta que está guardado en el parámetro [_tipoTransporte] y
  /// calcula la ruta nueva con el modo de transporte nuevo
  void _cambiarModo(String modua){
    setState((){ //utilizamos la función "setState" para que se actualice toda la UI (interfaz)
      _tipoTransporte = modua;
    });
    markers.clear();
    polylines.clear();
    polylineCoordinates.clear();
    _calculateDistance();
  }

  TravelMode _modoBusqueda(){
    switch (_tipoTransporte){
      case 'Coche': return TravelMode.driving;
      case 'Bici': return TravelMode.bicycling;
      case 'Andando': return TravelMode.walking;
      case 'Transporte': return TravelMode.transit;
      default: return TravelMode.driving; //default añadido para que no pueda devolver en ningún caso null
    }
  }

  Future<bool> dibujarRuta(String origen, String destino) async {
    try {
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

      String startCoordinatesString = '($startLatitude, $startLongitude)';
      String destinationCoordinatesString =
          '($destinationLatitude, $destinationLongitude)';

      // Start Location Marker
      Marker startMarker = Marker(
        markerId: MarkerId(startCoordinatesString),
        position: LatLng(startLatitude, startLongitude),
        infoWindow: InfoWindow(
          title: 'Start $startCoordinatesString',
          snippet: origen,
        ),
        icon: markerStart,
      );

      // Destination Location Marker
      Marker destinationMarker = Marker(
        markerId: MarkerId(destinationCoordinatesString),
        position: LatLng(destinationLatitude, destinationLongitude),
        infoWindow: InfoWindow(
          title: 'Destination $destinationCoordinatesString',
          snippet: destino,
        ),
        icon: markerDestination,
      );

      markers.clear();
      // Adding the markers to the list
      markers.add(startMarker);
      markers.add(destinationMarker);



      // Calculating to check that the position relative
      // to the frame, and pan & zoom the camera accordingly.
      double miny = (startLatitude <= destinationLatitude)
          ? startLatitude
          : destinationLatitude;
      double minx = (startLongitude <= destinationLongitude)
          ? startLongitude
          : destinationLongitude;
      double maxy = (startLatitude <= destinationLatitude)
          ? destinationLatitude
          : startLatitude;
      double maxx = (startLongitude <= destinationLongitude)
          ? destinationLongitude
          : startLongitude;

      double southWestLatitude = miny;
      double southWestLongitude = minx;

      double northEastLatitude = maxy;
      double northEastLongitude = maxx;

      // Accommodate the two locations within the
      // camera view of the map
      mapController.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            northeast: LatLng(northEastLatitude, northEastLongitude),
            southwest: LatLng(southWestLatitude, southWestLongitude),
          ),
          100.0,
        ),
      );


      await _createPolylines(startLatitude, startLongitude, destinationLatitude,
          destinationLongitude);

      double totalDistance = 0.0;

      // Calculating the total distance by adding the distance
      // between small segments
      for (int i = 0; i < polylineCoordinates.length - 1; i++) {
        totalDistance += _coordinateDistance(
          polylineCoordinates[i].latitude,
          polylineCoordinates[i].longitude,
          polylineCoordinates[i + 1].latitude,
          polylineCoordinates[i + 1].longitude,
        );
      }

      setState(() {
        _placeDistance = totalDistance.toStringAsFixed(2);
      });

      return true;
    } catch (e) {
      print(e);
    }
    return false;
  }

  /// Create the polylines for showing the route between two places
  _createPolylines(
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
      travelMode: _modoBusqueda(),
    );

    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) { //TODO aunk haya encontrado un punto sigue bucleando, salir(?)
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        bool irten=false;
        int i=0;
        while(i<poligonos.length && !irten){
          if (toolkit.PolygonUtil.containsLocation(toolkit.LatLng(point.latitude, point.longitude),poligonos[i],true)){ //conseguimos el poligono i que queremos
            irten=true;
          }
          i=i+1;
          print(i);
        }
        //buscar el poligono i en la lista poligonoLag
        if(irten){
          setState(() {
            final String polygonIdVal = 'polygon_$_polygonIdCounter';
            _polygonIdCounter++;
            _polygons.clear();
            _polygons.add(Polygon(
              polygonId: PolygonId(polygonIdVal),
              points: poligonosLag[i-1],
              strokeWidth: 2,
              fillColor: Colors.red.withOpacity(0.5),
            ));
          });
        }

      });
    }

    PolylineId id = PolylineId('poly');
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.red,
      points: polylineCoordinates,
      width: 3,
    );
    polylines[id] = polyline;
  }
}

class BotonBici extends StatelessWidget{

  late bool activado;
  late Function callback;

  BotonBici(String tipoTransporte, Function aldaketaFuntzio){
    tipoTransporte == 'Bici' ? activado = true : activado = false;
    callback = aldaketaFuntzio;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.topRight,
        child: Padding(
          padding: const EdgeInsets.only(top: 150.0, right: 95.0),
          child: ClipOval(
            child: Material(
              color: activado ? Colors.blue.shade900: Colors.blue.shade500,// button color
              child: InkWell(
                splashColor: Colors.black, // inkwell color
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: Icon(TablerIcons.bike,color: Colors.white),
                ),
                onTap: () async {
                  callback('Bici');
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class BotonCoche extends StatelessWidget{

  late bool activado;
  late Function callback;

  BotonCoche(String tipoTransporte, Function aldaketaFuntzio){
    tipoTransporte == 'Coche' ? activado = true : activado = false;
    callback = aldaketaFuntzio;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.topLeft,
        child: Padding(
          padding: const EdgeInsets.only(top: 150.0, left: 45.0),
          child: ClipOval(
            child: Material(
              color: activado ? Colors.blue.shade900: Colors.blue.shade500, // button color
              child: InkWell(
                splashColor: Colors.black, // inkwell color
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: Icon(TablerIcons.car,color: Colors.white),
                ),
                onTap:() async {
                  if(!activado){
                    callback('Coche');
                  }
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class BotonAndando extends StatelessWidget{

  late bool activado;
  late Function callback;

  BotonAndando(String tipoTransporte, Function aldaketaFuntzio){
    tipoTransporte == 'Andando' ? activado = true : activado = false;
    callback = aldaketaFuntzio;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.topLeft,
        child: Padding(
          padding: const EdgeInsets.only(top: 150.0, left: 95.0),
          child: ClipOval(
            child: Material(
              color: activado ? Colors.blue.shade900: Colors.blue.shade500, // button color
              child: InkWell(
                splashColor: Colors.black, // inkwell color
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: Icon(TablerIcons.walk,color: Colors.white),
                ),
                onTap: () async {
                  callback('Andando');
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class BotonTransportePublico extends StatelessWidget{

  late bool activado;
  late Function callback;

  BotonTransportePublico(String tipoTransporte, Function aldaketaFuntzio){
    tipoTransporte == 'Transporte' ? activado = true : activado = false;
    callback = aldaketaFuntzio;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.topRight,
        child: Padding(
          padding: const EdgeInsets.only(top: 150.0, right: 45.0),
          child: ClipOval(
            child: Material(
              color: activado ? Colors.blue.shade900: Colors.blue.shade500, // button color
              child: InkWell(
                splashColor: Colors.black, // inkwell color
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: Icon(TablerIcons.bus,color: Colors.white),
                ),
                onTap: () async {
                  callback('Transporte');
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}