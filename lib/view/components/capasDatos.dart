import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class CapasDatos {

  late Function _tratarPulsacion;
  late Function _tratarPulsacionCrrntLct;

  CapasDatos(Function funcionCapasClasePadre, Function funcionCrrnLct){
    _tratarPulsacion = funcionCapasClasePadre;
    _tratarPulsacionCrrntLct = funcionCrrnLct;
  }

  SafeArea getBotonAscGratis(){
    return SafeArea(
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Padding(
          padding: const EdgeInsets.only(left: 10.0, bottom: 25.0),
          child: ClipOval(
            child: Material(
              color: Colors.blue, // button color
              child: InkWell(
                splashColor: Colors.black, // inkwell color
                child: SizedBox(
                  width: 56,
                  height: 56,
                  child: Image.asset('assets/iconos_botones/ascensor_blanco.png'),
                ),
                onTap:  () async {
                  _tratarPulsacion(0);
                }
              ),
            ),
          ),
        ),
      ),
    );
  }

  SafeArea getBotonAscPago(){
    return SafeArea(
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Padding(
          padding: const EdgeInsets.only(left: 10.0, bottom: 85.0),
          child: ClipOval(
            child: Material(
              color: Colors.blue, // button color
              child: InkWell(
                splashColor: Colors.black, // inkwell color
                child: SizedBox(
                  width: 56,
                  height: 56,
                  child: Image.asset('assets/iconos_botones/ascensor_pago_blanco.png'),
                ),
                onTap:  () async {
                  _tratarPulsacion(1);
                }
              ),
            ),
          ),
        ),
      ),
    );
  }

  SafeArea getEscaleraMec(){
    return  SafeArea(
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Padding(
          padding: const EdgeInsets.only(left: 10.0, bottom: 145.0),
          child: ClipOval(
            child: Material(
              color: Colors.blue, // button color
              child: InkWell(
                splashColor: Colors.black, // inkwell color
                child: SizedBox(
                  width: 56,
                  height: 56,
                  child: Image.asset('assets/iconos_botones/escalera_mec_blanco.png', fit:BoxFit.cover),
                ),
                onTap:  () async {
                  _tratarPulsacion(2);
                }
              ),
            ),
          ),
        ),
      ),
    );
  }

  SafeArea getObras(){
    return  SafeArea(
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Padding(
          padding: const EdgeInsets.only(left: 10.0, bottom: 205.0),
          child: ClipOval(
            child: Material(
              color: Colors.blue, // button color
              child: InkWell(
                  splashColor: Colors.black, // inkwell color
                  child: SizedBox(
                    width: 56,
                    height: 56,
                    child: Image.asset('assets/iconos_botones/obras_blanco.png', fit:BoxFit.cover),
                  ),
                  onTap:  () async {
                    _tratarPulsacion(3);
                  }
              ),
            ),
          ),
        ),
      ),
    );
  }



  SafeArea getCrrntLctBtn(){
    return SafeArea(
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
                  _tratarPulsacionCrrntLct();
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}