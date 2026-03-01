import 'package:flutter/material.dart';

class Ventana1 extends StatefulWidget {
  const Ventana1({super.key});

  @override
  State<Ventana1> createState() => _Ventana1State();
}

const Color colorPrincipal = Color(0xFF8B2E24);

class _Ventana1State extends State<Ventana1> {
  int _indice = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "MARIE-ART",
              style: TextStyle(
                fontSize: 20,
                color: colorPrincipal,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 20),
            Image.asset('assets/logo.png', height: 30),
          ],
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: contenido(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _indice,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.work_history),
            label: "MAIN",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: "FORO"),
          BottomNavigationBarItem(icon: Icon(Icons.sell), label: "?"),
        ],
        onTap: (pos) {
          setState(() {
            _indice = pos;
          });
        },
        selectedFontSize: 15,
        selectedItemColor: Colors.purple,
        unselectedItemColor: Colors.black,
        backgroundColor: Colors.blue.shade200,
      ),
    );
  }

  Widget contenido() {
    switch (_indice) {
      case 1:
        return ListView(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
              child: Column(
                children: [
                  TextField(
                    decoration: InputDecoration(
                      hintText: "Búsqueda...",
                      prefixIcon: const Icon(Icons.search, color: Colors.black),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: const BorderSide(
                          color: colorPrincipal,
                          width: 3,
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.pink.shade50,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "¿Qué estás pensando?",
                  suffixIcon: IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.send, color: Colors.blue),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(
                      color: Colors.blue,
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(
                      color: Colors.blueAccent,
                      width: 2.5,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Card(
                child: Column(
                  children: [
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Divider(),
                        SizedBox(height: 10, width: 5),
                        Image.asset('assets/user.png', width: 35),
                        SizedBox(height: 10, width: 20),
                        Text(
                          "Mi nueva pintura.",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Image.asset('assets/frida.png', width: 250),
                    //SizedBox(height: 5),
                    Row(
                      children: [
                        SizedBox(width: 10),
                        IconButton(
                          onPressed: () {},
                          icon: Icon(Icons.thumb_up),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: Icon(Icons.thumb_down),
                        ),
                        SizedBox(width: 260),
                        IconButton(onPressed: () {}, icon: Icon(Icons.comment)),
                        IconButton(onPressed: () {}, icon: Icon(Icons.share)),
                      ],
                    ),
                  ],
                ),
                color: Colors.blue.shade100,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Card(
                child: Column(
                  children: [
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Divider(),
                        SizedBox(height: 10, width: 5),
                        Image.asset('assets/user.png', width: 35),
                        SizedBox(height: 10, width: 20),
                        Text(
                          "Me falta motivación.",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Text(
                      "He perdido la motivación en mi vida. "
                          "Algunos consejos para recuperarla??",
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 5),
                    Row(
                      children: [
                        SizedBox(width: 10),
                        IconButton(
                          onPressed: () {},
                          icon: Icon(Icons.thumb_up),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: Icon(Icons.thumb_down),
                        ),
                        SizedBox(width: 260),
                        IconButton(onPressed: () {}, icon: Icon(Icons.comment)),
                        IconButton(onPressed: () {}, icon: Icon(Icons.share)),
                      ],
                    ),
                  ],
                ),
                color: Colors.blue.shade100,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Card(
                child: Column(
                  children: [
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Divider(),
                        SizedBox(height: 10, width: 5),
                        Image.asset('assets/user.png', width: 35),
                        SizedBox(height: 10, width: 20),
                        Text(
                          "MARIE es la mejor artista.",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Soy un gran fan de MARIE. Ya conozco todas sus obras, "
                          "no puedo esperar a que haga una nueva <3.",
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 5),
                    Row(
                      children: [
                        SizedBox(width: 10),
                        IconButton(
                          onPressed: () {},
                          icon: Icon(Icons.thumb_up),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: Icon(Icons.thumb_down),
                        ),
                        SizedBox(width: 260),
                        IconButton(onPressed: () {}, icon: Icon(Icons.comment)),
                        IconButton(onPressed: () {}, icon: Icon(Icons.share)),
                      ],
                    ),
                  ],
                ),
                color: Colors.blue.shade100,
              ),
            ),
          ],
        );
      case 2:
        return Text("¿?");
    }
    return Text("GALERIA");
  }
}
