import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'paginas/homepagina.dart'; // Asegúrate de que este archivo exista

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Método para el inicio de sesión con Google
  Future<void> signInWithGoogle() async {
    try {
      // Inicia el proceso de autenticación con Google
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        // El usuario canceló el inicio de sesión
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Crea las credenciales de Firebase a partir de las credenciales de Google
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Inicia sesión en Firebase con las credenciales de Google
      await FirebaseAuth.instance.signInWithCredential(credential);

      // Navega a la página principal después del inicio de sesión exitoso
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
        return RecentOrdersPage(); // Ahora se cargan pedidos desde la API
      }));
    } catch (e) {
      print('Error en el inicio de sesión con Google: $e');
      // Mostrar mensaje de error si el inicio de sesión falla
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error en el inicio de sesión con Google: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Espacio para el logo
                Image.network(
                  'https://firebasestorage.googleapis.com/v0/b/cajaimagnes.appspot.com/o/ecoservicios-original.png?alt=media&token=ed3ee1be-2bdf-43db-b97c-6cbbb74ec41c', // Reemplaza con tu URL del logo
                  height: 100, // Altura del logo
                ),
                const SizedBox(height: 20),
                const Text(
                  '¡Bienvenido de vuelta!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Al logearte aceptas la revisión de tus datos',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 50),

                // Botón de inicio de sesión con Google
                ElevatedButton.icon(
                  onPressed: () {
                    signInWithGoogle(); // Llamada al método para iniciar sesión con Google
                  },
                  icon: const Icon(Icons.play_arrow,
                      color: Color.fromARGB(
                          255, 255, 255, 255)), // Icono de Google
                  label: const Text(
                    'Continue con Google   ',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: const Color.fromARGB(
                        255, 10, 129, 123), // Color del botón
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
