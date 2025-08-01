// Smart Reminder App (Dart Console Application)
import 'dart:async';
import 'dart:io';

class Reminder {
  String title;
  String description;
  DateTime time;
  bool isDone;
  bool isRecurring;
  String repeatType; // 'daily', 'weekly', 'hourly'

  Reminder(this.title, this.description, this.time,
      {this.isDone = false, this.isRecurring = false, this.repeatType = ''});

  String get countdown {
    final now = DateTime.now();
    final diff = time.difference(now);
    if (diff.isNegative) return "Time Passed";
    return "${diff.inMinutes} min ${diff.inSeconds % 60} sec left";
  }
}

List<Reminder> reminders = [];

void main() {
  Timer.periodic(Duration(seconds: 10), (_) => checkReminders());
  showMenu();
}

void showMenu() {
  while (true) {
    print("\n========= Smart Reminder Menu =========");
    print("1. Add Reminder");
    print("2. View All Reminders");
    print("3. Edit Reminder");
    print("4. Delete Reminder");
    print("5. Exit");
    stdout.write("Select an option: ");
    String? input = stdin.readLineSync();
    switch (input) {
      case '1':
        addReminder();
        break;
      case '2':
        viewReminders();
        break;
      case '3':
        editReminder();
        break;
      case '4':
        deleteReminder();
        break;
      case '5':
        print("Goodbye!");
        exit(0);
      default:
        print("Invalid choice. Try again.");
    }
  }
}

void addReminder() {
  stdout.write("Enter Title: ");
  String title = stdin.readLineSync() ?? '';

  stdout.write("Enter Description: ");
  String description = stdin.readLineSync() ?? '';

  DateTime? time;
  while (true) {
    print("Enter reminder date and time for the future.");
    print("Date format: YYYY-MM-DD (e.g. 2025-08-05)");
    stdout.write("Date: ");
    String dateInput = stdin.readLineSync() ?? '';
    print("Time format: HH:MM in 24-hour (e.g. 14:30 for 2:30 PM)");
    stdout.write("Time: ");
    String timeInput = stdin.readLineSync() ?? '';
    try {
      String combined = dateInput.trim() + 'T' + timeInput.trim();
      time = DateTime.parse(combined);
      if (time.isBefore(DateTime.now())) {
        print('⛔ You entered a past date/time. Please enter a future date and time.');
        continue;
      }
      break;
    } catch (e) {
      print('⛔ Invalid format. Make sure date is YYYY-MM-DD and time is HH:MM in 24-hour format.');
    }
  }

  stdout.write("Is this recurring? (y/n): ");
  bool isRecurring = (stdin.readLineSync() ?? '').toLowerCase() == 'y';
  String repeatType = '';
  if (isRecurring) {
    while (true) {
      stdout.write("Repeat Type (daily/weekly/hourly): ");
      repeatType = stdin.readLineSync() ?? '';
      if (['daily', 'weekly', 'hourly'].contains(repeatType.toLowerCase())) {
        repeatType = repeatType.toLowerCase();
        break;
      }
      print('⛔ Invalid repeat type. Choose daily, weekly, or hourly.');
    }
  }

  reminders.add(Reminder(title, description, time!,
      isRecurring: isRecurring, repeatType: repeatType));

  print("Reminder added successfully.");
}

void viewReminders() {
  if (reminders.isEmpty) {
    print("No reminders found.");
    return;
  }

  reminders.sort((a, b) => a.time.compareTo(b.time));

  for (int i = 0; i < reminders.length; i++) {
    final r = reminders[i];
    print("\n[$i] ${r.title} | ${r.time} | ${r.isDone ? 'Done' : 'Pending'}");
    print("    ${r.description}");
    print("    Countdown: ${r.countdown}");
    if (r.isRecurring) print("    Repeats: ${r.repeatType}");
  }
}

void editReminder() {
  if (reminders.isEmpty) {
    print("No reminders to edit.");
    return;
  }
  viewReminders();
  stdout.write("Enter index to edit: ");
  String? idxStr = stdin.readLineSync();
  int index;
  try {
    index = int.parse(idxStr ?? '');
  } catch (_) {
    print("Invalid input.");
    return;
  }

  if (index < 0 || index >= reminders.length) {
    print("Invalid index.");
    return;
  }

  stdout.write("New Title (leave blank to keep same): ");
  String? newTitle = stdin.readLineSync();
  stdout.write("New Description (leave blank to keep same): ");
  String? newDesc = stdin.readLineSync();
  stdout.write("New Time (YYYY-MM-DD HH:MM) (leave blank to keep same): ");
  String? newTimeStr = stdin.readLineSync();

  if (newTitle != null && newTitle.isNotEmpty) reminders[index].title = newTitle;
  if (newDesc != null && newDesc.isNotEmpty) reminders[index].description = newDesc;
  if (newTimeStr != null && newTimeStr.isNotEmpty) {
    try {
      DateTime newTime = DateTime.parse(newTimeStr.replaceFirst(' ', 'T'));
      if (newTime.isBefore(DateTime.now())) {
        print("Cannot set to past time; keeping old time.");
      } else {
        reminders[index].time = newTime;
      }
    } catch (_) {
      print("Invalid time format; keeping old time.");
    }
  }

  print("Reminder updated.");
}

void deleteReminder() {
  if (reminders.isEmpty) {
    print("No reminders to delete.");
    return;
  }
  viewReminders();
  stdout.write("Enter index to delete: ");
  String? idxStr = stdin.readLineSync();
  int index;
  try {
    index = int.parse(idxStr ?? '');
  } catch (_) {
    print("Invalid input.");
    return;
  }

  if (index < 0 || index >= reminders.length) {
    print("Invalid index.");
    return;
  }

  reminders.removeAt(index);
  print("Reminder deleted.");
}

void checkReminders() {
  DateTime now = DateTime.now();
  for (var r in reminders) {
    if (!r.isDone &&
        r.time.year == now.year &&
        r.time.month == now.month &&
        r.time.day == now.day &&
        r.time.hour == now.hour &&
        r.time.minute == now.minute) {
      print("\n🔔 Reminder Alert: ${r.title} - ${r.description} at ${r.time}");
      stdout.write("Mark as done? (y/n): ");
      if ((stdin.readLineSync() ?? '').toLowerCase() == 'y') {
        r.isDone = true;
      }

      if (r.isRecurring) {
        switch (r.repeatType) {
          case 'daily':
            r.time = r.time.add(Duration(days: 1));
            r.isDone = false;
            break;
          case 'weekly':
            r.time = r.time.add(Duration(days: 7));
            r.isDone = false;
            break;
          case 'hourly':
            r.time = r.time.add(Duration(hours: 1));
            r.isDone = false;
            break;
        }
      }
    }
  }
}
