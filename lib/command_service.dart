import 'dart:async';
import 'dart:io';
import 'package:csv/csv.dart';
// For path manipulation

// Define the shared CSV path. This assumes the Flutter app is run from the project root.
// Adjustments might be needed for bundled apps or different execution contexts.
final String SHARED_CSV_PATH = r'D:\AppCommunication\commands.csv';
// final String SHARED_CSV_PATH = '/Users/yourusername/path/to/your/project/shared_communication/commands.csv'; // Example absolute path for testing

class Command {
  final String timestamp;
  final String sourceApp;
  final String commandName;
  final String commandPayload;
  String status;
  String resultPayload;

  Command({
    required this.timestamp,
    required this.sourceApp,
    required this.commandName,
    required this.commandPayload,
    required this.status,
    required this.resultPayload,
  });

  // Creates a Command from a CSV row (List<dynamic>)
  factory Command.fromCsvRow(List<dynamic> row) {
    if (row.length < 6) {
      throw const FormatException('CSV row does not have enough columns to create a Command.');
    }
    return Command(
      timestamp: row[0].toString(),
      sourceApp: row[1].toString(),
      commandName: row[2].toString(),
      commandPayload: row[3].toString(),
      status: row[4].toString(),
      resultPayload: row[5].toString(),
    );
  }

  // Converts a Command object to a list for CSV writing
  List<dynamic> toCsvRow() {
    return [timestamp, sourceApp, commandName, commandPayload, status, resultPayload];
  }

  // Creates a copy of the command with optional updated fields
  Command copyWith({
    String? timestamp,
    String? sourceApp,
    String? commandName,
    String? commandPayload,
    String? status,
    String? resultPayload,
  }) {
    return Command(
      timestamp: timestamp ?? this.timestamp,
      sourceApp: sourceApp ?? this.sourceApp,
      commandName: commandName ?? this.commandName,
      commandPayload: commandPayload ?? this.commandPayload,
      status: status ?? this.status,
      resultPayload: resultPayload ?? this.resultPayload,
    );
  }

  @override
  String toString() {
    return 'Command(timestamp: $timestamp, sourceApp: $sourceApp, commandName: $commandName, payload: $commandPayload, status: $status, result: $resultPayload)';
  }
}

class CommandService {
  // Placeholder for CommandController interaction
  Function(Command command)? onNewPythonCommand;
  Timer? _pollingTimer;

  CommandService({this.onNewPythonCommand});

  Future<List<Command>> readCommands() async {
    final file = File(SHARED_CSV_PATH);
    if (!await file.exists()) {
      print('CommandService: CSV file does not exist at $SHARED_CSV_PATH');
      return [];
    }

    try {
      final csvString = await file.readAsString();
      final List<List<dynamic>> rowsAsListOfValues = const CsvToListConverter(eol: '\n', fieldDelimiter: ',').convert(csvString);
      
      if (rowsAsListOfValues.isEmpty) {
        return []; // Empty file or only header
      }

      // Skip header row
      return rowsAsListOfValues.skip(1).map((row) {
        try {
          return Command.fromCsvRow(row);
        } catch (e) {
          print('Error parsing row: $row. Error: $e');
          return null; // Or handle more gracefully
        }
      }).where((command) => command != null).cast<Command>().toList();
    } catch (e) {
      print('Error reading or parsing CSV: $e');
      return [];
    }
  }

  Future<void> updateCommandInCsv(Command commandToUpdate) async {
    final file = File(SHARED_CSV_PATH);
    if (!await file.exists()) {
      print('CommandService: Cannot update command, CSV file does not exist.');
      return;
    }

    List<List<dynamic>> allRows;
    try {
      final csvString = await file.readAsString();
      allRows = const CsvToListConverter(eol: '\n', fieldDelimiter: ',').convert(csvString);
    } catch (e) {
      print('Error reading CSV for update: $e');
      return;
    }

    if (allRows.isEmpty) {
      print('CommandService: CSV is empty, cannot update.');
      return;
    }

    // Find and update the command
    bool found = false;
    for (int i = 1; i < allRows.length; i++) { // Skip header
      if (allRows[i][0] == commandToUpdate.timestamp && allRows[i][1] == commandToUpdate.sourceApp) {
        allRows[i] = commandToUpdate.toCsvRow();
        found = true;
        break;
      }
    }

    if (!found) {
      print('CommandService: Command with timestamp ${commandToUpdate.timestamp} from ${commandToUpdate.sourceApp} not found for update.');
      // Optionally, append if not found and that's desired behavior (not for this use case)
      return;
    }

    try {
      final String outputCsv = const ListToCsvConverter(eol: '\n', fieldDelimiter: ',').convert(allRows);
      await file.writeAsString(outputCsv);
      print('CommandService: Command ${commandToUpdate.commandName} (ID: ${commandToUpdate.timestamp}) updated in CSV to status ${commandToUpdate.status}.');
    } catch (e) {
      print('Error writing updated CSV: $e');
    }
  }

  void startPolling({Duration interval = const Duration(seconds: 3)}) {
    print('CommandService: Starting to poll $SHARED_CSV_PATH every $interval');
    _pollingTimer?.cancel(); // Cancel any existing timer
    _pollingTimer = Timer.periodic(interval, (timer) async {
      // print('CommandService: Polling for commands...');
      final commands = await readCommands();
      for (var command in commands) {
        if (command.sourceApp == 'python' && command.status == 'pending') {
          if (onNewPythonCommand != null) {
            print('CommandService: New pending Python command found: ${command.commandName}');
            onNewPythonCommand!(command);
          }
        }
      }
    });
  }

  void stopPolling() {
    print('CommandService: Stopping polling.');
    _pollingTimer?.cancel();
  }
}
