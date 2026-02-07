import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const CalculadoraApp());
}

class CalculadoraApp extends StatelessWidget {
  const CalculadoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const Calculadora(),
    );
  }
}

class Calculadora extends StatefulWidget {
  const Calculadora({super.key});

  @override
  State<Calculadora> createState() => _CalculadoraState();
}

class _CalculadoraState extends State<Calculadora> {
  String _output = "0";
  double num1 = 0;
  double num2 = 0;
  String operand = "";
  bool _shouldReset = false;

  void buttonPressed(String buttonText) {
    setState(() {
      if (buttonText == "C") {
        _output = "0";
        num1 = 0;
        num2 = 0;
        operand = "";
        _shouldReset = false;
      } else if (["+", "-", "x", "/"].contains(buttonText)) {
        num1 = double.tryParse(_output) ?? 0;
        operand = buttonText;
        _shouldReset = true;
      } else if (buttonText == "=") {
        if (operand.isEmpty) return;
        num2 = double.tryParse(_output) ?? 0;
        switch (operand) {
          case "+": _output = (num1 + num2).toString(); break;
          case "-": _output = (num1 - num2).toString(); break;
          case "x": _output = (num1 * num2).toString(); break;
          case "/": _output = (num2 != 0) ? (num1 / num2).toString() : "Error"; break;
        }
        if (_output.endsWith(".0")) _output = _output.substring(0, _output.length - 2);
        if (_output.contains(".") && _output.length > 10) {
          _output = double.parse(_output).toStringAsFixed(4);
        }
        operand = "";
        _shouldReset = true;
      } else {
        if (_shouldReset) {
          _output = buttonText == "." ? "0." : buttonText;
          _shouldReset = false;
        } else {
          if (buttonText == "." && _output.contains(".")) return;
          if (_output == "0" && buttonText != ".") {
            _output = buttonText;
          } else {
            _output += buttonText;
          }
        }
      }
    });
  }

  Widget buildButton(String buttonText, Color color) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: _AnimatedButton(
          buttonText: buttonText,
          color: color,
          onPressed: () => buttonPressed(buttonText),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: Center(
        child: AspectRatio(
          aspectRatio: 9 / 18, // CAMBIO: Proporción ajustada para móviles modernos
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 450),
            child: Container(
              margin: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: <Widget>[
                  AppBar(
                    title: const Text(
                      "CALCULADORA PRO",
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                        letterSpacing: 2,
                      ),
                    ),
                    backgroundColor: Colors.grey[900],
                    elevation: 0,
                    centerTitle: true,
                  ),
                  
                  // Display flexible mejorado
                  Expanded(
                    flex: 2, // Le damos una proporción clara
                    child: Container(
                      alignment: Alignment.bottomRight,
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                      child: FittedBox( // CAMBIO: Asegura que el número siempre quepa en alto y ancho
                        fit: BoxFit.contain,
                        alignment: Alignment.bottomRight,
                        child: Text(
                          _output,
                          style: const TextStyle(
                            fontSize: 80,
                            fontWeight: FontWeight.w100,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const Divider(height: 1, color: Colors.white24),

                  // Teclado ahora es proporcional (sin height fijo)
                  Expanded(
                    flex: 5, // El teclado ocupa 5 partes frente a las 2 del display
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                      child: Column(
                        children: [
                          _buildRow(["7", "8", "9", "/"]),
                          _buildRow(["4", "5", "6", "x"]),
                          _buildRow(["1", "2", "3", "-"]),
                          _buildRow([".", "0", "C", "+"]),
                          _buildRow(["="]),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRow(List<String> buttons) {
    return Expanded(
      child: Row(
        children: buttons.map((text) {
          Color? color = Colors.grey[900];
          if (text == "C") color = const Color.fromARGB(255, 163, 11, 11);
          else if (text == "=") color = const Color.fromARGB(255, 4, 126, 8);
          else if (["/", "x", "-", "+"].contains(text)) color = const Color.fromARGB(255, 190, 115, 2);

          return buildButton(text, color!);
        }).toList(),
      ),
    );
  }
}

class _AnimatedButton extends StatefulWidget {
  final String buttonText;
  final Color color;
  final VoidCallback onPressed;
  const _AnimatedButton({required this.buttonText, required this.color, required this.onPressed});

  @override
  State<_AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<_AnimatedButton> {
  double _scale = 1.0;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.92),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      onTap: widget.onPressed,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        child: Container(
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              widget.buttonText,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}