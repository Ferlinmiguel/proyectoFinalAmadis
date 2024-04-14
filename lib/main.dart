import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  get id => null;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inicio',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),

      // Rutas
      routes: {
        '/': (context) => ImageSlider(
              imagePaths: [
                '../assets/img1.jpg',
                '../assets/img2.jpg',
                '../assets/img3.jpeg',
                '../assets/img4.jpg',
                '../assets/img5.jpeg',
                '../assets/img6.jpeg',
                '../assets/img7.jpg',
              ],
            ),
        '/busqueda': (context) => BusquedaAlbergue(),
        '/historia': (context) => Historia(),
        '/servicios': (context) => Servicios(),
        '/noticias': (context) => Noticias(),
        '/videos': (context) => Videos(),
      },
    );
  }
}

class ImageSlider extends StatefulWidget {
  final List<String> imagePaths;

  ImageSlider({required this.imagePaths});

  @override
  _ImageSliderState createState() => _ImageSliderState();
}

class _ImageSliderState extends State<ImageSlider> {
  int _currentIndex = 0;

  void _nextImage() {
    setState(() {
      if (_currentIndex < widget.imagePaths.length - 1) {
        _currentIndex++;
      }
    });
  }

  void _previousImage() {
    setState(() {
      if (_currentIndex > 0) {
        _currentIndex--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inicio'),
        actions: [
          // Usar un PopupMenuButton para mostrar menú desplegable
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                value: '/busqueda',
                child: Text('Busqueda Albergue'),
              ),
              PopupMenuItem(
                value: '/historia',
                child: Text('Historia'),
              ),
              PopupMenuItem(
                value: '/servicios',
                child: Text('Servicios'),
              ),
              PopupMenuItem(
                value: '/noticias',
                child: Text('Noticias'),
              ),
              PopupMenuItem(
                value: '/videos',
                child: Text('Videos'),
              )
            ],
            onSelected: (String route) {
              // Navegar a la ruta seleccionada
              Navigator.pushNamed(context, route);
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Image.asset(
                  widget.imagePaths[_currentIndex],
                  height: 200,
                ),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: _previousImage,
                ),
                SizedBox(width: 20),
                IconButton(
                  icon: Icon(Icons.arrow_forward),
                  onPressed: _nextImage,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Definir Busqueda Albergue
class BusquedaAlbergue extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Albergues App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: AlberguesScreen(),
    );
  }
}

class AlberguesScreen extends StatefulWidget {
  @override
  _AlberguesScreenState createState() => _AlberguesScreenState();
}

class _AlberguesScreenState extends State<AlberguesScreen> {
  List<Albergue> albergues = [];
  List<Albergue> filteredAlbergues = [];
  List<MedidaPreventiva> medidasPreventivas = [];
  List<Miembro> miembros = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchAlbergues();
    fetchMedidasPreventivas();
    fetchMiembros();
  }

  Future<void> fetchAlbergues() async {
    try {
      final response = await http
          .get(Uri.parse('https://adamix.net/defensa_civil/def/albergues.php'));

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        List<dynamic> alberguesList = data['datos'];

        setState(() {
          albergues =
              alberguesList.map((json) => Albergue.fromJson(json)).toList();
          filteredAlbergues = albergues;
        });
      } else {
        throw Exception('Failed to load albergues');
      }
    } catch (e) {
      print('Error: $e');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text(
                'Failed to fetch albergues. Please check your internet connection.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> fetchMedidasPreventivas() async {
    try {
      final response = await http.get(Uri.parse(
          'https://adamix.net/defensa_civil/def/medidas_preventivas.php'));

      if (response.statusCode == 200) {
        print(response.body);
        dynamic data = jsonDecode(response.body);
        if (data is Map<String, dynamic> && data.containsKey('datos')) {
          List<dynamic> medidasPreventivasList = data['datos'];

          setState(() {
            medidasPreventivas = medidasPreventivasList
                .map((json) => MedidaPreventiva.fromJson(json))
                .toList();
          });
        } else {
          throw Exception('Formato de datos erróneo para medidas preventivas');
        }
      } else {
        throw Exception('Fallo al intentar cargar las mediadas preventivas.');
      }
    } catch (e) {
      print('Error: $e');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text(
                'El fetch a medidas preventivas falló. Por favor revisa tu conexión a internet.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> fetchMiembros() async {
    try {
      final response = await http
          .get(Uri.parse('https://adamix.net/defensa_civil/def/miembros.php'));

      if (response.statusCode == 200) {
        dynamic data = jsonDecode(response.body);
        if (data is Map<String, dynamic> && data.containsKey('datos')) {
          List<dynamic> miembrosList = data['datos'];

          setState(() {
            miembros =
                miembrosList.map((json) => Miembro.fromJson(json)).toList();
          });
        } else {
          throw Exception('Formato de datos inválido para miembros');
        }
      } else {
        throw Exception('La carga de miembros falló');
      }
    } catch (e) {
      print('Error: $e');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text(
                'El fetch a miembros falló. Por favor, revisa tu conexión a internet.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  void filterAlbergues(String query) {
    setState(() {
      filteredAlbergues = albergues
          .where((albergue) =>
              albergue.ciudad.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _showVolunteerForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(20),
          child: VolunteerForm(),
        );
      },
    );
  }

  FloatingActionButton _buildVolunteerButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        _showVolunteerForm(context);
      },
      child: Icon(Icons.volunteer_activism),
    );
  }

  void _showPreventiveMeasures(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Medidas Preventivas',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: medidasPreventivas.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Título: ${medidasPreventivas[index].titulo}',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                                'Descripción: ${medidasPreventivas[index].descripcion}'),
                            SizedBox(height: 10),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  FloatingActionButton _buildPreventiveMeasuresButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        _showPreventiveMeasures(context);
      },
      child: Icon(Icons.warning),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: searchController,
          decoration: InputDecoration(
            hintText: 'Buscar albergues...',
            border: InputBorder.none,
            suffixIcon: IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                filterAlbergues(searchController.text);
              },
            ),
          ),
          onChanged: filterAlbergues,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.map),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      AlberguesMapScreen(albergues: filteredAlbergues),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.people),
            onPressed: () {
              _showMiembros(context);
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: filteredAlbergues.length,
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: ListTile(
                title: Text(
                  filteredAlbergues[index].ciudad,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  filteredAlbergues[index].edificio,
                  style: TextStyle(fontSize: 16),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AlbergueDetailScreen(
                          albergue: filteredAlbergues[index]),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _buildVolunteerButton(context),
          SizedBox(width: 16),
          _buildPreventiveMeasuresButton(context),
        ],
      ),
    );
  }

  void _showMiembros(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Miembros de la Defensa Civil',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: miembros.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(miembros[index].foto),
                        ),
                        title: Text(miembros[index].nombre),
                        subtitle: Text(miembros[index].cargo),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class Albergue {
  final String ciudad;
  final String codigo;
  final String edificio;
  final String coordinador;
  final String telefono;
  final String capacidad;
  final double lat;
  final double lng;

  Albergue({
    required this.ciudad,
    required this.codigo,
    required this.edificio,
    required this.coordinador,
    required this.telefono,
    required this.capacidad,
    required this.lat,
    required this.lng,
  });

  factory Albergue.fromJson(Map<String, dynamic> json) {
    return Albergue(
      ciudad: json['ciudad'] ?? '',
      codigo: json['codigo'] ?? '',
      edificio: json['edificio'] ?? '',
      coordinador: json['coordinador'] ?? '',
      telefono: json['telefono'] ?? '',
      capacidad: json['capacidad'] ?? '',
      lat: double.parse(json['lat'] ?? '0'),
      lng: double.parse(json['lng'] ?? '0'),
    );
  }
}

class MedidaPreventiva {
  final String id;
  final String titulo;
  final String descripcion;
  final String foto;

  MedidaPreventiva({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.foto,
  });

  factory MedidaPreventiva.fromJson(Map<String, dynamic> json) {
    return MedidaPreventiva(
      id: json['id'] ?? '',
      titulo: json['titulo'] ?? '',
      descripcion: json['descripcion'] ?? '',
      foto: json['foto'] ?? '',
    );
  }
}

class Miembro {
  final String id;
  final String foto;
  final String nombre;
  final String cargo;

  Miembro({
    required this.id,
    required this.foto,
    required this.nombre,
    required this.cargo,
  });

  factory Miembro.fromJson(Map<String, dynamic> json) {
    return Miembro(
      id: json['id'] ?? '',
      foto: json['foto'] ?? '',
      nombre: json['nombre'] ?? '',
      cargo: json['cargo'] ?? '',
    );
  }
}

class AlbergueDetailScreen extends StatelessWidget {
  final Albergue albergue;

  const AlbergueDetailScreen({Key? key, required this.albergue})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(albergue.ciudad),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Edificio: ${albergue.edificio}',
              style: TextStyle(fontSize: 18),
            ),
            Text(
              'Coordinador: ${albergue.coordinador}',
              style: TextStyle(fontSize: 18),
            ),
            Text(
              'Teléfono: ${albergue.telefono}',
              style: TextStyle(fontSize: 18),
            ),
            Text(
              'Capacidad: ${albergue.capacidad}',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}

class AlberguesMapScreen extends StatefulWidget {
  final List<Albergue> albergues;

  AlberguesMapScreen({required this.albergues});

  @override
  _AlberguesMapScreenState createState() => _AlberguesMapScreenState();
}

class _AlberguesMapScreenState extends State<AlberguesMapScreen> {
  late GoogleMapController mapController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mapa de Albergues'),
      ),
      body: GoogleMap(
        onMapCreated: (controller) {
          setState(() {
            mapController = controller;
          });
        },
        initialCameraPosition: CameraPosition(
          target: LatLng(0, 0), // Punto central inicial
          zoom: 10, // Zoom inicial
        ),
        markers: widget.albergues
            .map((albergue) => Marker(
                  markerId: MarkerId(albergue.codigo),
                  position: LatLng(albergue.lat, albergue.lng),
                  infoWindow: InfoWindow(
                    title: albergue.ciudad,
                    snippet: albergue.edificio,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AlbergueDetailScreen(albergue: albergue),
                      ),
                    );
                  },
                ))
            .toSet(),
      ),
    );
  }
}

class VolunteerForm extends StatefulWidget {
  @override
  _VolunteerFormState createState() => _VolunteerFormState();
}

class _VolunteerFormState extends State<VolunteerForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _cedulaController = TextEditingController();
  final _claveController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(labelText: 'Nombre'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingrese su nombre';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _lastNameController,
            decoration: InputDecoration(labelText: 'Apellido'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingrese su apellido';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _cedulaController,
            decoration: InputDecoration(labelText: 'Cédula'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingrese su cédula';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _claveController,
            decoration: InputDecoration(labelText: 'Clave'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingrese su clave';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(labelText: 'Correo'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingrese su correo';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _phoneController,
            decoration: InputDecoration(labelText: 'Teléfono'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingrese su teléfono';
              }
              return null;
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  // Aquí se enviaría el formulario a la API
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Enviando formulario')));
                }
              },
              child: Text('Enviar'),
            ),
          ),
        ],
      ),
    );
  }
}

// Definir otra vista
class Historia extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Historia'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Historia de la Defensa Civil de la República Dominicana',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'La Defensa Civil de la República Dominicana es una institución de servicio público y voluntario, cuyo objetivo principal es la protección y asistencia a la población en situaciones de emergencia y desastres naturales.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              Text(
                'Fue creada el 10 de abril de 1962, poco después de la tragedia ocurrida el 4 de agosto de 1960, cuando el ciclón San Zenón azotó la costa sur del país, dejando miles de víctimas y cuantiosos daños materiales. Esta tragedia motivó la creación de una entidad encargada de prevenir y enfrentar desastres naturales.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              Text(
                'Desde entonces, la Defensa Civil ha trabajado incansablemente para fortalecer su capacidad de respuesta ante diversos eventos, como huracanes, terremotos, inundaciones y deslizamientos de tierra. Su labor se ha extendido a lo largo y ancho del país, capacitando a la población, estableciendo protocolos de actuación y coordinando acciones de socorro y asistencia.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              Text(
                'A lo largo de su historia, la Defensa Civil de la República Dominicana ha demostrado su compromiso con la seguridad y el bienestar de la población, convirtiéndose en un referente en la gestión integral de riesgos y la respuesta a emergencias.',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Servicios extends StatefulWidget {
  @override
  _ServiciosState createState() => _ServiciosState();
}

class _ServiciosState extends State<Servicios> {
  late Future<List<Servicio>> servicios;

  @override
  void initState() {
    super.initState();
    servicios = fetchServicios();
  }

  Future<List<Servicio>> fetchServicios() async {
    final response = await http
        .get(Uri.parse('https://adamix.net/defensa_civil/def/servicios.php'));

    if (response.statusCode == 200) {
      final List<dynamic> parsedJson = json.decode(response.body)['datos'];
      return parsedJson.map((service) => Servicio.fromJson(service)).toList();
    } else {
      throw Exception('La carga de servicios falló');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Servicios de Defensa Civil RD'),
      ),
      body: Center(
        child: FutureBuilder<List<Servicio>>(
          future: servicios,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(snapshot.data![index].nombre),
                    subtitle: Text(snapshot.data![index].descripcion),
                    leading: Image.network(snapshot.data![index].foto),
                  );
                },
              );
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }

            return CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}

class Servicio {
  final String id;
  final String nombre;
  final String descripcion;
  final String foto;

  Servicio({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.foto,
  });

  factory Servicio.fromJson(Map<String, dynamic> json) {
    return Servicio(
      id: json['id'],
      nombre: json['nombre'],
      descripcion: json['descripcion'],
      foto: json['foto'],
    );
  }
}

// Definir otra vista - Últimas noticias relacionadas
class Noticias extends StatefulWidget {
  @override
  _NoticiasState createState() => _NoticiasState();
}

class _NoticiasState extends State<Noticias> {
  late Future<List<Noticia>> noticias;

  @override
  void initState() {
    super.initState();
    noticias = fetchNoticias();
  }

  Future<List<Noticia>> fetchNoticias() async {
    final response = await http
        .get(Uri.parse('https://adamix.net/defensa_civil/def/noticias.php'));

    if (response.statusCode == 200) {
      final List<dynamic> parsedJson = json.decode(response.body)['datos'];
      return parsedJson.map((news) => Noticia.fromJson(news)).toList();
    } else {
      throw Exception('Failed to load noticias');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Últimas Noticias Relacionadas'),
      ),
      body: Center(
        child: FutureBuilder<List<Noticia>>(
          future: noticias,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: EdgeInsets.all(10),
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            snapshot.data![index].titulo,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            snapshot.data![index].fecha,
                            style: TextStyle(
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(snapshot.data![index].contenido),
                        ],
                      ),
                    ),
                  );
                },
              );
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }

            return CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}

class Noticia {
  final String id;
  final String fecha;
  final String titulo;
  final String contenido;
  final String foto;

  Noticia({
    required this.id,
    required this.fecha,
    required this.titulo,
    required this.contenido,
    required this.foto,
  });

  factory Noticia.fromJson(Map<String, dynamic> json) {
    return Noticia(
      id: json['id'],
      fecha: json['fecha'],
      titulo: json['titulo'],
      contenido: json['contenido'],
      foto: json['foto'],
    );
  }
}

// Definir galería de videos
class Videos extends StatefulWidget {
  @override
  _VideosState createState() => _VideosState();
}

class _VideosState extends State<Videos> {
  late Future<List<Video>> videos;

  @override
  void initState() {
    super.initState();
    videos = fetchVideos();
  }

  Future<List<Video>> fetchVideos() async {
    final response = await http
        .get(Uri.parse('https://adamix.net/defensa_civil/def/videos.php'));

    if (response.statusCode == 200) {
      final List<dynamic> parsedJson = json.decode(response.body)['datos'];
      return parsedJson.map((video) => Video.fromJson(video)).toList();
    } else {
      throw Exception('La carga de videos falló');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Galería de Videos Educativos'),
      ),
      body: Center(
        child: FutureBuilder<List<Video>>(
          future: videos,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: EdgeInsets.all(10),
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            snapshot.data![index].titulo,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(snapshot.data![index].descripcion),
                          SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () {
                              _launchURL(
                                  'https://www.youtube.com/watch?v=${snapshot.data![index].link}');
                            },
                            child: Text('Ver Video'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }

            return CircularProgressIndicator();
          },
        ),
      ),
    );
  }

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'No se puede lanzar $url';
    }
  }
}

class Video {
  final String id;
  final String fecha;
  final String titulo;
  final String descripcion;
  final String link;

  Video({
    required this.id,
    required this.fecha,
    required this.titulo,
    required this.descripcion,
    required this.link,
  });

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      id: json['id'],
      fecha: json['fecha'],
      titulo: json['titulo'],
      descripcion: json['descripcion'],
      link: json['link'],
    );
  }
}
