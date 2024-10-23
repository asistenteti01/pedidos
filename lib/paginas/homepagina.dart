import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../api/pedidos_api.dart';
import '../modelos/pedido_modelo.dart';
import 'detallepedido.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter App',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: AuthGate(),
    );
  }
}

// Verifica si el usuario está autenticado antes de mostrar los pedidos
class AuthGate extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error en la autenticación'));
        } else if (snapshot.hasData) {
          return RecentOrdersPage();
        } else {
          return LoginPage(); // Página de login si no está autenticado
        }
      },
    );
  }
}

class RecentOrdersPage extends StatefulWidget {
  @override
  _RecentOrdersPageState createState() => _RecentOrdersPageState();
}

class _RecentOrdersPageState extends State<RecentOrdersPage> {
  late Future<List<Pedido>> futurePedidos;

  @override
  void initState() {
    super.initState();
    futurePedidos = PedidosApi().fetchPedidos(); // Llamada a la API aquí
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'PEDIDOS',
          style: TextStyle(
            color: Colors.white, // Cambiar el color del texto a blanco
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 30, 52, 99),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              FirebaseAuth.instance.signOut(); // Cerrar sesión
            },
          )
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(
                'https://firebasestorage.googleapis.com/v0/b/cajaimagnes.appspot.com/o/fondoverdeazul.jpg?alt=media&token=a38923d2-556b-4f13-8611-f69506915d32'),
            fit: BoxFit
                .cover, // Esto ajustará la imagen para cubrir todo el fondo
          ),
        ),
        child: FutureBuilder<List<Pedido>>(
          future: futurePedidos,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return const Center(
                child: Text('Error al cargar los pedidos'),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text('No hay pedidos disponibles'),
              );
            }

            var pedidos = snapshot.data!;

            return ListView.builder(
              itemCount: pedidos.length,
              itemBuilder: (context, index) {
                var pedido = pedidos[index];
                var fechaSolicitud =
                    DateTime.parse(pedido.fecha); // Fecha en formato DateTime

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OrderDetailPage(pedido: pedido),
                      ),
                    );
                  },
                  child: Card(
                    margin: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 15),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pedido.correl,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Fecha Solicitud: ${DateFormat('yyyy-MM-dd').format(fechaSolicitud)}',
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

// Página de login si no está autenticado
class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            try {
              // Implementa la autenticación con Google o cualquier otro método aquí
              await FirebaseAuth.instance.signInAnonymously();
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error en la autenticación: $e')),
              );
            }
          },
          child: const Text('Iniciar sesión'),
        ),
      ),
    );
  }
}
