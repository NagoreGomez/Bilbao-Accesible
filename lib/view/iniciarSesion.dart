import 'package:bilbao_accesible/controlller/dbConn.dart';
import 'package:bilbao_accesible/view/registro.dart';
import 'package:bilbao_accesible/model/usuario.dart';

import 'package:flutter/material.dart';

import 'package:bilbao_accesible/view/usuario/origenUsuario.dart';



class IniciarSesion extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<IniciarSesion> {
  GlobalKey<FormState> keyForm = new GlobalKey();
  TextEditingController  userNameCtrl = new TextEditingController();
  Widget formUI() {
    return  Column(
      children: <Widget>[
        formItemsDesign(
            Icons.person,
            TextFormField(
              controller: userNameCtrl,
              decoration: new InputDecoration(
                labelText: 'Nombre de usuario',
              ),
              maxLength: 20,
              validator: (value) => validateUserName(value!),
            )),
        formItemsDesign(
            Icons.lock,
            TextFormField(
              controller: passwordCtrl,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Contraseña',
              ),
              validator: (value) => validatePassword(value!),
            )),

        GestureDetector(
            onTap: () async {
              iniciarSesion();
            },
            child: Container(
              margin:  new EdgeInsets.only(top: 20.0,left: 60.0,right: 60.0),
              alignment: Alignment.center,
              decoration: ShapeDecoration(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0)
                ),
                color: Colors.blue,
              ),
              child: Text("INICIAR",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500
                )
              ),
            padding: EdgeInsets.only(top: 16, bottom: 16),
          )
        ),


        GestureDetector(
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => Resgistro()));
            },
            child: Container(
              margin: new EdgeInsets.only(top: 20.0,left: 60.0,right: 60.0),
              alignment: Alignment.center,
              decoration: ShapeDecoration(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                color: Colors.blue,
              ),
              child: Text("REGISTRARSE",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500
                )
              ),
              padding: EdgeInsets.only(top: 16, bottom: 16),
            )
        )
      ],
    );
  }
  TextEditingController  emailCtrl = new TextEditingController();
  TextEditingController  mobileCtrl = new TextEditingController();

  TextEditingController  passwordCtrl = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        canvasColor: Colors.white,
      ),
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text('Iniciar sesion'),
        ),
        body: new SingleChildScrollView(
          child: new Container(
            margin: new EdgeInsets.only(top:150.0,left: 30.0,right: 30.0),
            child: new Form(
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



  String? validatePassword(String value) {
    print("valorrr $value passsword ${passwordCtrl.text}");
    if (value.length == 0) {
      return "La contraseña es necesaria";
    }
    return null;
  }


  String? validateUserName(String value) {
    String pattern = r'(^[a-zA-Z0-9._]*$)';
    RegExp regExp = new RegExp(pattern);
    if (value.length == 0) {
      return "El nombre de usuario es necesario";
    } else if (!regExp.hasMatch(value)) {
      return "Nombre de usuario no valido";
    } else {
      return null;
    }
  }



  iniciarSesion() async{
    //hacer una consulta y:
    // if (estan bien los datos){ ... , en vez de este if
    if (keyForm.currentState!.validate()) {
      String user = '${userNameCtrl.text}';
      String pass = '${passwordCtrl.text}';


      DBconn().getUsuario(user, pass).then((existe) {
        if(existe){
          Navigator.push(context, MaterialPageRoute(builder: (context) => OrigenUsuario()));
          Usuario().setUsuario(user);
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
            title: Text("Información incorrecta"),
            content: Text("El nombre de usuario y/o contraseña no son correctos, intentalo de nuevo por favor."),
            actions: <Widget>[
              ElevatedButton(
                child: Text("CERRAR", style: TextStyle(color: Colors.blue),),
                onPressed: (){ Navigator.of(context).pop(); },
              )
            ],
          );
        }
    );
  }

}


//https://codigofacilito.com/articulos/articulo_28_10_2019_17_58_51