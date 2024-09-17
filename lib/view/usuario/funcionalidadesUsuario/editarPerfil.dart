
import 'package:bilbao_accesible/controlller/dbConn.dart';
import 'package:bilbao_accesible/view/usuario/origenUsuario.dart';
import 'package:flutter/material.dart';

import '../menu.dart';
import 'package:bilbao_accesible/model/usuario.dart';


class EditarPerfil extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<EditarPerfil> {
  GlobalKey<FormState> keyForm = new GlobalKey();
  TextEditingController  nameCtrl = new TextEditingController();
  TextEditingController  apellidoCtrl = new TextEditingController();
  TextEditingController  userNameCtrl = new TextEditingController();
  TextEditingController  passwordCtrl = new TextEditingController();
  TextEditingController  newPassCtrl = new TextEditingController();
  TextEditingController  movilidadCtrl = new TextEditingController();


  @override
  initState() {
    super.initState();
    getInfo();

  }

  getInfo() async {

    nameCtrl.text = await DBconn().getNombre();
    apellidoCtrl.text = await DBconn().getApellidos();
    userNameCtrl.text = await DBconn().getNombreUsuario();
    String movilidad=await DBconn().getMovilidad();
    if(movilidad!='null'){
      movilidadCtrl.text = movilidad;
    }
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Editar perfil'),
        ),
        body: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.only(top:30.0,left: 30.0,right: 30.0),
            child: Form(
              key: keyForm,
              child: formUI(),
            ),
          ),
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

  //String gender = 'hombre';

  Widget formUI() {
    return  Column(
      children: <Widget>[
        formItemsDesign(
            Icons.person,
            TextFormField(
              controller: nameCtrl,
              decoration: new InputDecoration(
                labelText: 'Nombre',
              ),
              validator: (value) => validateName(value!),
              //initialValue: 'a',
            )),
        formItemsDesign(
            Icons.person,
            TextFormField(
              controller: apellidoCtrl,
              decoration: new InputDecoration(
                labelText: 'Apellidos',
              ),
              validator: (value) => validateApellido(value!),
            )
        ),
        formItemsDesign(
            Icons.email,
            TextFormField(
              controller: userNameCtrl,
              decoration: new InputDecoration(
                labelText: 'Nombre de usuario',
              ),
              maxLength: 20,
              validator: (value) => validateUserName(value!),
            )
        ),
        formItemsDesign(
            Icons.accessible,
            TextFormField(
              controller: movilidadCtrl,
              decoration: InputDecoration(
                labelText: 'Tipo de movilidad reducida (opcional)',
              ),
              maxLength: 45,
              validator: (value) => validateMovility(value!),
            )
        ),
        formItemsDesign(
            Icons.lock,
            TextFormField(
              controller: passwordCtrl,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Contraseña actual',
              ),
              validator: (value) => validatePassword(value!),
            )
        ),
        formItemsDesign(
            Icons.lock,
            TextFormField(
              controller: newPassCtrl,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Nueva contraseña',
              ),
            )
        ),

        GestureDetector(
            onTap: (){
              save();
            },
            child: Container(
              margin: new EdgeInsets.all(30.0),
              alignment: Alignment.center,
              decoration: ShapeDecoration(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0)
                ),
                color: Colors.blue,
              ),
              child: Text("GUARDAR",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500
                  )
              ),
              padding: EdgeInsets.only(top: 16, bottom: 16),
            )
        ),
      ],
    );
  }




  String? validatePassword(String value)  {


    if(passwordCtrl.text.isEmpty && newPassCtrl.text.isNotEmpty) {
      return "Debes escribir la contraseña actual";
    }
    return null;
  }

  String? validateName(String value) {
    String pattern = r'(^[a-z A-ZÀ-ÿ ]*$)';
    RegExp regExp = new RegExp(pattern);
    if (value.length == 0) {
      return "El nombre es necesario";
    } else if (!regExp.hasMatch(value)) {
      return "El nombre debe de ser a-z y A-Z";
    }
    return null;
  }

  String? validateMovility(String value) {
    String pattern = r'(^[a-zA-ZÀ-ÿ ]*$)';
    RegExp regExp = new RegExp(pattern);
    if (!regExp.hasMatch(value)) {
      return "La movilidad debe de ser a-z y A-Z";
    }
    return null;
  }

  String? validateApellido(String value) {
    String pattern = r'(^[a-zA-ZÀ-ÿ ]*$)';
    RegExp regExp = new RegExp(pattern);
    if (value.length == 0) {
      return "Los apellidos son necesarios";
    } else if (!regExp.hasMatch(value)) {
      return "El apellido debe de ser a-z y A-Z";
    }
    return null;
  }


  String? validateUserName(String value) {
    String pattern = r'(^[a-zA-ZÀ-ÿ0-9._]*$)';
    RegExp regExp = new RegExp(pattern);
    if (value.length == 0) {
      return "El nombre de usuario es necesario";
    } else if (!regExp.hasMatch(value)) {
      return "Nombre de usuario no valido";
    } else {
      return null;
    }
  }

  save() async{
    if (keyForm.currentState!.validate()) {

      String passwordActual= await DBconn().getPassword();


      String name = '';
      String apellidos = '';
      String user = '';
      String pass = '';
      String movilidad = '';

      bool passwordBien=true;

      if(nameCtrl.text.isEmpty){
         name= await DBconn().getNombre();
      }
      else{
        name = '${nameCtrl.text}';
      }
      if(apellidoCtrl.text.isEmpty){
        apellidos= await DBconn().getApellidos();
      }
      else{
        apellidos = '${apellidoCtrl.text}';
      }

      if(userNameCtrl.text.isEmpty){
        user= await DBconn().getNombreUsuario();
      }
      else{
        user = '${userNameCtrl.text}';
      }

      if(passwordCtrl.text.isNotEmpty && passwordActual==passwordCtrl.text && newPassCtrl.text.isNotEmpty){
        pass = '${newPassCtrl.text}'; //contraseña nueva
      }
      else{
        pass= passwordActual;
      }
      if(passwordCtrl.text.isNotEmpty && passwordActual!=passwordCtrl.text){
        passwordBien=false;
        print("hola22");
      }
      if(movilidadCtrl.text.isEmpty){
        String movilidadActual=await DBconn().getMovilidad();
        if(movilidadActual!='null'){ //si habia algo escrito y lo ha quitado, se le quita
          movilidad = 'null';
          //avisar??
        }
        else{
          movilidad= await DBconn().getMovilidad();
        }
      }
      else{
        movilidad = '${movilidadCtrl.text}';
      }

      if(!passwordBien){
          _showAlertDialog();
      }
      else{
        print(name);
        print(apellidos);
        print(user);
        print(pass);
        print(movilidad);
        String? usernameActual = Usuario().getUserName();

        DBconn().editarPerfil(usernameActual!,name, apellidos, user,pass,movilidad);
        Usuario().setUsuario(user);
        Navigator.push(context, MaterialPageRoute(builder: (context) => MenuUsuario()));

      }



    }
  }


  void _showAlertDialog() {
    showDialog(
        context: context,
        builder: (buildcontext) {
          return AlertDialog(
            title: Text("La contraseña es incorrecta"),
            content: Text("La contraseña actual no es correcta, intentalo de nuevo."),
            actions: <Widget>[
              ElevatedButton(
                child: Text("CERRAR", style: TextStyle(color: Colors.white),),
                onPressed: (){ Navigator.of(context).pop(); },
              )
            ],
          );
        }
    );
  }
}