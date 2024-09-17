import 'package:bilbao_accesible/controlller/dbConn.dart';
import 'package:flutter/material.dart';
import 'package:bilbao_accesible/view/iniciarSesion.dart';

class Resgistro extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<Resgistro> {
  GlobalKey<FormState> keyForm = new GlobalKey();
  TextEditingController  nameCtrl = new TextEditingController();
  TextEditingController  apellidoCtrl = new TextEditingController();
  TextEditingController  userNameCtrl = new TextEditingController();
  TextEditingController  passwordCtrl = new TextEditingController();
  TextEditingController  repeatPassCtrl = new TextEditingController();
  TextEditingController  movilidadCtrl = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Registrarse'),
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
                labelText: 'Contraseña',
              ),
            )
        ),
        formItemsDesign(
            Icons.lock,
            TextFormField(
              controller: repeatPassCtrl,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Repetir la contraseña',
              ),
              validator: (value) => validatePassword(value!),
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



  String? validatePassword(String value) {
    print("valorrr $value passsword ${passwordCtrl.text}");
    if (value != passwordCtrl.text) {
      return "Las contraseñas no coinciden";
    }
    if (value.length == 0) {
      return "La contraseña es necesaria";
    }
    return null;
  }

  String? validateName(String value) {
    String pattern = r'(^[a-z A-ZÀ-ÿ \s]*$)';
    RegExp regExp = new RegExp(pattern);
    if (value.length == 0) {
      return "El nombre es necesario";
    } else if (!regExp.hasMatch(value)) {
      return "El nombre debe de ser a-z y A-Z";
    }
    return null;
  }

  String? validateMovility(String value) {
    String pattern = r'(^[a-zA-ZÀ-ÿ \s]*$)';
    RegExp regExp = new RegExp(pattern);
    if (!regExp.hasMatch(value)) {
      return "La movilidad debe de ser a-z y A-Z";
    }
    return null;
  }

  String? validateApellido(String value) {
    String pattern = r'(^[a-zA-ZÀ-ÿ \s ]*$)';
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

      String name = '${nameCtrl.text}';
      String apellidos = '${apellidoCtrl.text}';
      String user = '${userNameCtrl.text}';
      String pass = '${passwordCtrl.text}';
      String movilidad = '${movilidadCtrl.text}';

      DBconn().registro(name, apellidos, user, pass,movilidad).then((insertado){
        if(insertado){
          Navigator.push(context, MaterialPageRoute(builder: (context) => IniciarSesion()));
        }
        else{
          _showAlertDialog();
        }

      });


    }
  }


  void _showAlertDialog() {
    showDialog(
        context: context,
        builder: (buildcontext) {
          return AlertDialog(
            title: Text("Nombre de usuario incorrecto"),
            content: Text("El nombre de usuario ya esta registrado, intentalo de nuevo por favor."),
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
}