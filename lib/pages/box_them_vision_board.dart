import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:home_widget/home_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class TodoItem {
  String id;
  String text;
  bool isDone;

  TodoItem({
    required this.id,
    required this.text,
    this.isDone = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'isDone': isDone,
      };

  factory TodoItem.fromJson(Map<String, dynamic> json) => TodoItem(
        id: json['id'],
        text: json['text'],
        isDone: json['isDone'],
      );
}

class VisionBoardDetailsPage extends StatefulWidget {
  final String title;

  const VisionBoardDetailsPage({super.key, required this.title});

  @override
  State<VisionBoardDetailsPage> createState() => _VisionBoardDetailsPageState();
}

class _VisionBoardDetailsPageState extends State<VisionBoardDetailsPage> {
  final screenshotController = ScreenshotController();
  final Map<String, TextEditingController> _controllers = {};
  final List<String> visionCategories = [
    'Travel',
    'Self Care',
    'Forgive',
    'Love',
    'Family',
    'Career',
    'Health',
    'Hobbies',
    'Knowledge',
    'Social',
    'Reading',
    'Food',
    'Music',
    'Tech',
    'DIY',
    'Luxury',
    'Income',
    'BMI',
    'Invest',
    'Inspiration',
    'Help'
  ];
  final Map<String, List<TodoItem>> _todoLists = {};

  @override
  void initState() {
    super.initState();
    for (var category in visionCategories) {
      _controllers[category] = TextEditingController();
      _todoLists[category] = [];
      _loadSavedData(category);
    }
  }

  Future<void> _loadSavedData(String category) async {
    final prefs = await SharedPreferences.getInstance();

    // Load todos
    final savedTodos = prefs.getString('BoxThem_todos_$category');
    if (savedTodos != null) {
      final List<dynamic> decoded = json.decode(savedTodos);
      setState(() {
        _todoLists[category] =
            decoded.map((item) => TodoItem.fromJson(item)).toList();
      });
    }

    // Update the text controller with formatted text
    setState(() {
      _controllers[category]?.text = _formatDisplayText(category);
    });
  }

  String _formatDisplayText(String category) {
    final todos = _todoLists[category];
    if (todos == null || todos.isEmpty) return '';

    return todos.map((item) => "• ${item.text}").join("\n");
  }

  Future<void> _saveTodoList(String category) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = json
        .encode(_todoLists[category]?.map((item) => item.toJson()).toList());

    // Save to both SharedPreferences and HomeWidget
    await prefs.setString('BoxThem_todos_$category', encoded);
    await HomeWidget.saveWidgetData('BoxThem_todos_$category', encoded);

    // Update the widget
    await HomeWidget.updateWidget(
      androidName: 'VisionBoardWidget',
      iOSName: 'VisionBoardWidget',
    );
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _takeScreenshotAndShare() async {
    try {
      final image = await screenshotController.capture();
      if (image == null) return;

      final directory = await getApplicationDocumentsDirectory();
      final imagePath = '${directory.path}/vision_board.png';
      final imageFile = File(imagePath);
      await imageFile.writeAsBytes(image);

      await Share.shareXFiles([XFile(imagePath)],
          text: 'My Vision Board for 2025');
    } catch (e) {
      debugPrint('Error sharing vision board: $e');
    }
  }

  Widget _buildVisionCard(String title) {
    return GestureDetector(
      onTap: () => _showTodoDialog(title),
      onLongPress: () async {
        // Send message to update widget with edit mode
        await HomeWidget.saveWidgetData('edit_mode', title);
        await HomeWidget.updateWidget(
          androidName: 'VisionBoardWidget',
          iOSName: 'VisionBoardWidget',
        );
      },
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/vision-board-ruled.png'),
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withAlpha(50),
              spreadRadius: 2,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: GestureDetector(
                    onTap: () {
                      _showTodoDialog(title);
                    },
                    child: _todoLists[title]?.isEmpty ?? true
                        ? const Text(
                            'Write your\nvision here',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                              height: 1.4,
                            ),
                          )
                        : Text.rich(
                            TextSpan(
                              children: _todoLists[title]?.map((todo) {
                                    return TextSpan(
                                      text: "• ${todo.text}\n",
                                      style: TextStyle(
                                        fontSize: 16,
                                        decoration: todo.isDone == true
                                            ? TextDecoration.lineThrough
                                            : TextDecoration.none,
                                        color: todo.isDone == true
                                            ? Colors.grey
                                            : Colors.black,
                                      ),
                                    );
                                  }).toList() ??
                                  [],
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTodoDialog(String category) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: TodoListDialog(
          category: category,
          todoItems: _todoLists[category] ?? [],
          onSave: (updatedItems) async {
            setState(() {
              _todoLists[category] = updatedItems;
              _controllers[category]?.text = _formatDisplayText(category);
            });
            await _saveTodoList(category);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Screenshot(
                controller: screenshotController,
                child: Container(
                  color: Colors.grey[100],
                  padding: const EdgeInsets.all(12.0),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 0.7,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                    ),
                    itemCount: visionCategories.length,
                    itemBuilder: (context, index) =>
                        _buildVisionCard(visionCategories[index]),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: _takeScreenshotAndShare,
              icon:
                  const Icon(Icons.share, color: Color.fromARGB(255, 0, 0, 0)),
              label: const Text(
                'Share Vision Board',
                style: TextStyle(
                    fontSize: 18, color: Color.fromARGB(255, 0, 0, 0)),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TodoListDialog extends StatefulWidget {
  final String category;
  final List<TodoItem> todoItems;
  final Function(List<TodoItem>) onSave;

  const TodoListDialog({
    super.key,
    required this.category,
    required this.todoItems,
    required this.onSave,
  });

  @override
  TodoListDialogState createState() => TodoListDialogState();
}

class TodoListDialogState extends State<TodoListDialog> {
  late List<TodoItem> _items;
  final _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.todoItems);
  }

  void _addItem() {
    if (_textController.text.isNotEmpty) {
      setState(() {
        _items.add(TodoItem(
          id: DateTime.now().toString(),
          text: _textController.text,
        ));
        _textController.clear();
      });
    }
  }

  void _toggleItem(TodoItem item) {
    setState(() {
      item.isDone = !item.isDone;
    });
  }

  void _removeItem(TodoItem item) {
    setState(() {
      _items.remove(item);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.category,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _textController,
            decoration: InputDecoration(
              hintText: 'Add a new task',
              suffixIcon: IconButton(
                icon: const Icon(Icons.add),
                onPressed: _addItem,
              ),
            ),
            onSubmitted: (_) => _addItem(),
          ),
          const SizedBox(height: 8),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final item = _items[index];
                return ListTile(
                  leading: Checkbox(
                    value: item.isDone,
                    onChanged: (value) {
                      _toggleItem(item);
                    },
                  ),
                  title: Text(
                    item.text,
                    style: TextStyle(
                      decoration:
                          item.isDone ? TextDecoration.lineThrough : null,
                      color: item.isDone ? Colors.grey : Colors.black,
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _removeItem(item),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  widget.onSave(_items);
                  await HomeWidget.updateWidget(
                    androidName: 'VisionBoardWidget',
                    iOSName: 'VisionBoardWidget',
                  );
                  Navigator.pop(context);
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
