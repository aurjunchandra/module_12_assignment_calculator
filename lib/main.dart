import 'package:flutter/material.dart';

void main() {
  runApp(CalculatorApp());
}

class CalculatorApp extends StatefulWidget {
  @override
  _CalculatorAppState createState() => _CalculatorAppState();
}

class _CalculatorAppState extends State<CalculatorApp> {
  bool isDark = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Calculator',
      theme: isDark ? ThemeData.dark() : ThemeData.light(),
      home: CalculatorScreen(
        toggleTheme: () {
          setState(() {
            isDark = !isDark;
          });
        },
        isDark: isDark,
      ),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  final VoidCallback toggleTheme;
  final bool isDark;

  CalculatorScreen({required this.toggleTheme, required this.isDark});

  @override
  _CalculatorScreenState createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String input = '';
  String result = '0';

  final List<String> buttons = [
    'AC', '÷', '×', '⌫',
    '7', '8', '9', '−',
    '4', '5', '6', '+',
    '1', '2', '3', '=',
    '0', '.',
  ];

  void buttonPressed(String value) {
    setState(() {
      if (value == 'AC') {
        input = '';
        result = '0';
      } else if (value == '⌫') {
        if (input.isNotEmpty) input = input.substring(0, input.length - 1);
      } else if (value == '=') {
        try {
          String finalInput = input
              .replaceAll('×', '*')
              .replaceAll('÷', '/')
              .replaceAll('−', '-');
          if (finalInput.isNotEmpty) {
            double eval = _evaluate(finalInput);
            result = eval.toStringAsFixed(eval.truncateToDouble() == eval ? 0 : 2);
          }
        } catch (e) {
          result = 'Error';
        }
      } else {
        // Prevent multiple operators in a row
        if (input.isEmpty && "+−×÷.".contains(value)) return;
        if (input.isNotEmpty &&
            "+−×÷.".contains(value) &&
            "+−×÷.".contains(input[input.length - 1])) return;

        input += value;
      }
    });
  }

  double _evaluate(String expression) {
    // Very simple parser using Dart's expression evaluation
    // Use double.tryParse and manual ops for safety
    try {
      final exp = expression.replaceAll('--', '+');
      return _parseExpression(exp);
    } catch (_) {
      return double.nan;
    }
  }

  double _parseExpression(String exp) {
    // Simple evaluator using Dart's built-in parser
    try {
      return double.parse(_evaluateWithOrder(exp));
    } catch (_) {
      return 0.0;
    }
  }

  String _evaluateWithOrder(String exp) {
    // Evaluate × and ÷ first, then + and −
    List<String> tokens = exp.split(RegExp(r'([+\-*/])')).map((e) => e.trim()).toList();
    List<String> ops = exp.split(RegExp(r'[0-9.]+')).where((e) => e.isNotEmpty).toList();

    // Handle × ÷
    for (int i = 0; i < ops.length; i++) {
      if (ops[i] == '*' || ops[i] == '/') {
        double left = double.parse(tokens[i]);
        double right = double.parse(tokens[i + 1]);
        double val = (ops[i] == '*') ? left * right : left / right;
        tokens[i] = val.toString();
        tokens.removeAt(i + 1);
        ops.removeAt(i);
        i--;
      }
    }

    // Handle + −
    double total = double.parse(tokens[0]);
    for (int i = 0; i < ops.length; i++) {
      double next = double.parse(tokens[i + 1]);
      if (ops[i] == '+') total += next;
      if (ops[i] == '-') total -= next;
    }
    return total.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calculator'),
        actions: [
          IconButton(
            icon: Icon(widget.isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: widget.toggleTheme,
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,

        children: [
          // Display
          Expanded(
            child: Container(
              padding: EdgeInsets.all(20),
              alignment: Alignment.bottomRight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    input,
                    style: TextStyle(fontSize: 30, color: Colors.grey),
                  ),
                  SizedBox(height: 10),
                  Text(
                    result,
                    style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),

          // Buttons Grid
          SingleChildScrollView(
            child: Container(
              color: Theme.of(context).colorScheme.surfaceVariant,
              child: GridView.builder(
                shrinkWrap: true,
                itemCount: buttons.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 1.2,
                ),
                itemBuilder: (context, index) {
                  final buttonText = buttons[index];
                  return Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: ElevatedButton(
                      onPressed: () => buttonPressed(buttonText),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _getButtonColor(buttonText, context),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        buttonText,
                        style: TextStyle(
                          fontSize: 24,
                          color: _getTextColor(buttonText, context),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getButtonColor(String text, BuildContext context) {
    if (text == 'AC' || text == '⌫') {
      return Colors.redAccent;
    } else if ('÷×−+'.contains(text)) {
      return Colors.orangeAccent;
    } else if (text == '=') {
      return Colors.green;
    } else {
      return Theme.of(context).colorScheme.primaryContainer.withOpacity(0.2);
    }
  }

  Color _getTextColor(String text, BuildContext context) {
    if ('AC⌫÷×−+=.'.contains(text)) {
      return Colors.white;
    } else {
      return Theme.of(context).colorScheme.onPrimaryContainer;
    }
  }
}
