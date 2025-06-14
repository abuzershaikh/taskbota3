import 'package:flutter/material.dart';
import 'package:phone_ui_training/phone_mockup/phone_mockup_container.dart';
import 'command_service.dart';
// Import sub_command_handlers.dart once it's created
// For now, we'll define a placeholder for where SayHelloSubCommandHandler would be.
import 'sub_command_handlers.dart'; // Assuming this will be created next

class CommandController {
  final CommandService _commandService;
  final GlobalKey<PhoneMockupContainerState> _phoneMockupKey;
  // In a real app, you might have a map or a factory for handlers
  // Map<String, SubCommandHandler> _handlers = {};

  CommandController(this._commandService, this._phoneMockupKey) {
    // Initialize handlers, e.g.:
    // _handlers['say_hello'] = SayHelloSubCommandHandler();
  }

  Future<void> processCommand(Command command) async {
    print('CommandController: Received commandName - "${command.commandName}" with payload - "${command.commandPayload}"');
    print('CommandController: Processing command ${command.commandName} (ID: ${command.timestamp})');

    SubCommandHandler? handler;

    // Simple routing for now
    if (command.commandName == 'say_hello') {
      handler = SayHelloSubCommandHandler();
    } else if (command.commandName == 'echo') { // Add this case
      handler = EchoSubCommandHandler();
    } else if (command.commandName == 'open_settings') {
      handler = OpenSettingsSubCommandHandler(_phoneMockupKey);
    } else {
      print('CommandController: No handler for command ${command.commandName}');
      // Update command to 'failed' status if no handler is found
      Command updatedCommand = command.copyWith(
        status: 'failed',
        resultPayload: 'No handler for command: ${command.commandName}',
      );
      await _commandService.updateCommandInCsv(updatedCommand);
      return;
    }

    try {
      final result = await handler.execute(command.commandPayload);
      Command updatedCommand = command.copyWith(
        status: result['status'], // 'success' or 'failed'
        resultPayload: result['result_payload'],
      );
      await _commandService.updateCommandInCsv(updatedCommand);
      print('CommandController: Command ${command.commandName} processed, status: ${updatedCommand.status}');
    } catch (e) {
      print('CommandController: Error executing command ${command.commandName}: $e');
      Command updatedCommand = command.copyWith(
        status: 'failed',
        resultPayload: 'Execution error: $e',
      );
      await _commandService.updateCommandInCsv(updatedCommand);
    }
  }
}
