import 'package:flutter/material.dart';
import 'package:journal/blocs/authentication_bloc.dart';
import 'package:journal/blocs/authentication_bloc_provider.dart';
import 'package:journal/blocs/home_bloc.dart';
import 'package:journal/blocs/home_bloc_provider.dart';
import 'package:journal/services/authentication.dart';
import 'package:journal/services/db_firestore.dart';
import 'package:journal/pages/home.dart';
import 'package:journal/pages/login.dart';


void main() =>  runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final AuthenticationService _authenticationService = AuthenticationService();
    final AuthenticationBloc _authenticationBloc = AuthenticationBloc(_authenticationService);


    return AuthenticationBlocProvider(
      authenticationBloc: _authenticationBloc,
      child: StreamBuilder(
        initialData: null,
        stream: _authenticationBloc.user,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
          color: Colors.blueAccent,
          child: CircularProgressIndicator(),
          );
          } else if (snapshot.hasData) {
          return HomeBlocProvider(
          homeBloc: HomeBloc(DbFirestoreService(), _authenticationService),
          uid: snapshot.data,
          child: _buildMaterialApp(Home()),
          );
          } else {
          return _buildMaterialApp(Login());
          }
        },
      ),
    );
  
}

  MaterialApp _buildMaterialApp(Widget homePage) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Security Inherited',
    theme: ThemeData(
      primarySwatch: Colors.lightBlue,
      canvasColor: Colors.lightBlue.shade50,
      bottomAppBarColor: Colors.lightBlue,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    ),
    home: homePage,
  );
  }
}