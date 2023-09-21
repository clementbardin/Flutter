import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

void main() {
  runApp(SnakeGame());
}

class SnakeGame extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SnakeGameScreen(),
    );
  }
}

class SnakeGameScreen extends StatefulWidget {
  @override
  _SnakeGameScreenState createState() => _SnakeGameScreenState();
}

class _SnakeGameScreenState extends State<SnakeGameScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final snakeSize = 20.0;
  final gridSize = 20;
  List<Offset> snake = [Offset(5, 5)];
  Offset food = Offset(10, 10);
  Direction direction = Direction.down;
  bool isPlaying = false;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    startGame();
  }

  void startGame() {
    snake = [Offset(5, 5)];
    direction = Direction.right;
    isPlaying = true;
    if (timer != null && timer!.isActive) {
      timer!.cancel();
    }
    timer = Timer.periodic(Duration(milliseconds: 200), (timer) {
      if (isPlaying) {
        moveSnake();
      }
    });
  }

  void moveSnake() {
    setState(() {
      switch (direction) {
        case Direction.up:
          snake.insert(0, Offset(snake.first.dx, snake.first.dy - 1));
          break;
        case Direction.down:
          snake.insert(0, Offset(snake.first.dx, snake.first.dy + 1));
          break;
        case Direction.left:
          snake.insert(0, Offset(snake.first.dx - 1, snake.first.dy));
          break;
        case Direction.right:
          snake.insert(0, Offset(snake.first.dx + 1, snake.first.dy));
          break;
      }

      if (snake.first == food) {
        // Le serpent mange la nourriture
        generateFood();
      } else {
        snake.removeLast();
      }

      checkCollision();
    });
  }

  void generateFood() {
    final random = Random();
    int x, y;
    do {
      x = random.nextInt(gridSize);
      y = random.nextInt(gridSize);
    } while (snake.contains(Offset(x.toDouble(), y.toDouble())));
    food = Offset(x.toDouble(), y.toDouble());
  }

  void checkCollision() {
    if (snake.first.dx < 0 ||
        snake.first.dx >= gridSize ||
        snake.first.dy < 0 ||
        snake.first.dy >= gridSize ||
        snake.sublist(1).contains(snake.first)) {
      gameOver();
    }
  }

  void gameOver() {
    isPlaying = false;
    timer?.cancel();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Partie terminée'),
          content: Text('Votre score : ${snake.length - 1}'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                startGame();
              },
              child: Text('Rejouez'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Jeu Snake'),
      ),
      body: GestureDetector(
        // Gérer les gestes de balayage vertical pour les déplacements du serpent
        onVerticalDragUpdate: (details) {
          if (direction != Direction.up && details.delta.dy > 0) {
            direction = Direction.down;
          } else if (direction != Direction.down && details.delta.dy < 0) {
            direction = Direction.up;
          }
        },
        // Gérer les gestes de balayage horizontal pour les déplacements du serpent
        onHorizontalDragUpdate: (details) {
          if (direction != Direction.left && details.delta.dx > 0) {
            direction = Direction.right;
          } else if (direction != Direction.right && details.delta.dx < 0) {
            direction = Direction.left;
          }
        },
        child: Center(
          child: Container(
            width: snakeSize * gridSize,
            height: snakeSize * gridSize,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blue),
            ),
            child: Stack(
              children: <Widget>[
                Positioned(
                  left: food.dx * snakeSize,
                  top: food.dy * snakeSize,
                  child: Container(
                    width: snakeSize,
                    height: snakeSize,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),

                // Dessiner le serpent
                for (var segment in snake)
                  Positioned(
                    left: segment.dx * snakeSize,
                    top: segment.dy * snakeSize,
                    child: Container(
                      width: snakeSize,
                      height: snakeSize,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.rectangle,
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

enum Direction { up, down, left, right }
