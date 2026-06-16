import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/settings/settings_bloc.dart';
import '../../blocs/routines/routines_bloc.dart';
import '../../models/routine.dart';
import '../../models/task.dart';
import '../../theme/app_theme.dart';

class RoutineEditorScreen extends StatefulWidget {
  final Routine routine;
  final bool isNew;

  const RoutineEditorScreen({
    super.key,
    required this.routine,
    required this.isNew,
  });

  @override
  State<RoutineEditorScreen> createState() => _RoutineEditorScreenState();
}

class _RoutineEditorScreenState extends State<RoutineEditorScreen> {
  late TextEditingController _titleController;
  late String _startTime;
  late String _selectedIcon;
  late List<Task> _tasks;
  String _frequency = 'Every day';

  final List<String> _availableIcons = [
    '🌅',
    '🥪',
    '🎒',
    '🌙',
    '🧼',
    '📚',
    '🏃',
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.routine.title);
    _startTime = widget.routine.startTime;
    _selectedIcon = widget.routine.iconPath;
    _tasks = List.from(widget.routine.tasks);
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _selectTime() async {
    final parts = _startTime.split(':');
    final initialTime = TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    if (picked != null) {
      setState(() {
        _startTime =
            "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
      });
    }
  }

  void _addTask() {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final durationController = TextEditingController(
      text: '5',
    ); // Default 5 mins

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Task Title (e.g. Brush teeth)',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descController,
                decoration: const InputDecoration(
                  labelText: 'Instructions / Description',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: durationController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Duration (Minutes)',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  final minutes = int.tryParse(durationController.text) ?? 5;
                  setState(() {
                    _tasks.add(
                      Task(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        title: titleController.text,
                        description: descController.text,
                        orderIndex: _tasks.length,
                        durationSeconds: minutes * 60,
                      ),
                    );
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _save() {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a routine name')),
      );
      return;
    }

    final updated = widget.routine.copyWith(
      title: _titleController.text,
      startTime: _startTime,
      iconPath: _selectedIcon,
      tasks: _tasks,
    );

    context.read<RoutinesBloc>().add(SaveRoutineEvent(updated));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final state = context.watch<SettingsBloc>().state;
    final font = state.selectedFont;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.sageGreen,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back, color: Colors.white, size: 16),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.isNew ? 'New Routine' : 'Edit Routine',
          style: textTheme.headlineSmall?.copyWith(fontFamily: font),
        ),
        actions: [
          if (!widget.isNew)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () {
                context.read<RoutinesBloc>().add(
                  DeleteRoutineEvent(widget.routine.id),
                );
                Navigator.pop(context);
              },
            ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ListView(
                  children: [
                    _buildSectionLabel('ROUTINE DETAILS', font),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Routine Name',
                      ),
                      style: TextStyle(fontFamily: font),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: _selectTime,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                color: theme.cardColor,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: theme.dividerColor),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.access_time_filled_rounded,
                                    color: AppTheme.sageGreen,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _startTime,
                                    style: textTheme.bodyLarge?.copyWith(
                                      fontFamily: font,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: theme.cardColor,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: theme.dividerColor),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _frequency,
                                icon: const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: AppTheme.sageGreen,
                                ),
                                style: textTheme.bodyLarge?.copyWith(
                                  fontFamily: font,
                                  fontWeight: FontWeight.bold,
                                ),
                                items:
                                    <String>[
                                      'Every day',
                                      'Weekdays',
                                      'Weekends',
                                    ].map<DropdownMenuItem<String>>((
                                      String val,
                                    ) {
                                      return DropdownMenuItem<String>(
                                        value: val,
                                        child: Text(val),
                                      );
                                    }).toList(),
                                onChanged: (String? val) {
                                  if (val != null) {
                                    setState(() {
                                      _frequency = val;
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    _buildSectionLabel('ROUTINE ICON', font),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 60,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _availableIcons.length,
                        itemBuilder: (context, index) {
                          final icon = _availableIcons[index];
                          final isSelected = _selectedIcon == icon;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedIcon = icon;
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.only(right: 12),
                              width: 55,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppTheme.sageGreen
                                    : theme.cardColor,
                                border: Border.all(
                                  color: isSelected
                                      ? AppTheme.sageGreen
                                      : theme.dividerColor,
                                  width: 1.5,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  icon,
                                  style: const TextStyle(fontSize: 24),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),

                    _buildSectionLabel('TASKS • DRAG TO REORDER', font),
                    const SizedBox(height: 12),

                    if (_tasks.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Text(
                            'No steps added yet. Add one below!',
                            style: textTheme.bodyMedium?.copyWith(
                              color: theme.hintColor,
                              fontFamily: font,
                            ),
                          ),
                        ),
                      ),

                    ...List.generate(_tasks.length, (index) {
                      final t = _tasks[index];
                      return Container(
                        key: ValueKey(t.id),
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: theme.dividerColor),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.drag_indicator_rounded,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    t.title,
                                    style: textTheme.titleSmall?.copyWith(
                                      fontFamily: font,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '${t.durationSeconds ~/ 60} min - ${t.description}',
                                    style: textTheme.bodySmall?.copyWith(
                                      fontFamily: font,
                                      color: theme.hintColor,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.remove_circle_outline,
                                color: Colors.redAccent,
                                size: 20,
                              ),
                              onPressed: () {
                                setState(() {
                                  _tasks.removeAt(index);
                                });
                              },
                            ),
                          ],
                        ),
                      );
                    }),

                    const SizedBox(height: 12),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: _addTask,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add_circle_outline_rounded),
                          const SizedBox(width: 8),
                          Text(
                            'Add task',
                            style: TextStyle(
                              fontFamily: font,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.sageGreen,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: _save,
                child: Text(
                  'Save routine',
                  style: TextStyle(
                    fontFamily: font,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String text, String font) {
    final theme = Theme.of(context);
    return Text(
      text,
      style: theme.textTheme.titleSmall?.copyWith(
        fontFamily: font,
        letterSpacing: 1.2,
        fontWeight: FontWeight.bold,
        color: theme.hintColor,
      ),
    );
  }
}
