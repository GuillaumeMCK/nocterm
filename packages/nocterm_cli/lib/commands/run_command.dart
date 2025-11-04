import 'dart:io';

/// Run a dart command with --enable-vm-service automatically added
Future<void> runRunCommand(List<String> args) async {
  if (args.isEmpty) {
    print('Error: No command provided');
    print('');
    print('Usage: nocterm run dart <script.dart> [arguments]');
    print('');
    print('Example: nocterm run dart lib/main.dart');
    exit(1);
  }

  // Verify first argument is 'dart'
  if (args[0] != 'dart') {
    print('Error: Command must start with "dart"');
    print('');
    print('Usage: nocterm run dart <script.dart> [arguments]');
    exit(1);
  }

  // Build the modified command: dart --enable-vm-service <rest of args>
  final modifiedArgs = [
    'dart',
    '--enable-vm-service',
    ...args.sublist(1), // All arguments after 'dart'
  ];

  print('Running: ${modifiedArgs.join(' ')}');
  print('');

  // Execute the command
  final process = await Process.start(
    modifiedArgs[0],
    modifiedArgs.sublist(1),
    mode: ProcessStartMode.inheritStdio,
  );

  // Forward signals to child process
  ProcessSignal.sigint.watch().listen((_) {
    process.kill(ProcessSignal.sigint);
  });

  if (Platform.isMacOS || Platform.isLinux) {
    ProcessSignal.sigterm.watch().listen((_) {
      process.kill(ProcessSignal.sigterm);
    });
  }

  // Wait for process to complete
  final exitCode = await process.exitCode;
  exit(exitCode);
}
