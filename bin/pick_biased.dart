import 'package:pick_biased/pick_biased.dart' as pick_biased;

import 'dart:io';
import 'dart:math';
import 'dart:convert';
import 'package:args/args.dart';

Random random = new Random();
late bool verbose;

void main(List<String> args) {
  // parse options
  if (args.isEmpty) {
    print('Please specify a file.');
    exit(0);
  }

  var parser = ArgParser();
  parser
    ..addFlag('verbose', abbr: 'v', defaultsTo: false);

  var argResults = parser.parse(args);

  verbose = argResults['verbose'] as bool;

  try {
    var input = new File(args[0]);
    List<String> lines = input.readAsLinesSync();

    // look for options in the first line of the file
    String firstLine = lines[0];
    bool isOptionStringPresent = isJsonParseable(lines[0]);
    Map options = parseOptions(firstLine, defaultOptions());
    if (isOptionStringPresent) lines.removeAt(0);
    output("Options used: " + json.encode(options));

    // fetch the random line
    String randomLine = getRandomLine(lines, options['probabilityPower'].toDouble());
    stdout.writeln(randomLine);
  } catch (e) {
    stderr.writeln(e);
    exit(1);
  }
}

void output(String msg) {
  if (!verbose) return;
  stdout.writeln(msg);
}

Map parseOptions(String optionLine, Map defaultOptions) {
  try {
    // override default options from json
    Map optionsFromFile = jsonDecode(optionLine);
    optionsFromFile.forEach((k, v) => defaultOptions.update(k, (value) => v)); 
  } catch (e) {
    // not parseable, so do do nothings and we'll have the default options instead
  }

  return defaultOptions;
}

Map defaultOptions() {
  Map options = {
    'probabilityPower': 2.5
  };
  return options;
}

bool isJsonParseable(String line) {
  try {
    var tmp = jsonDecode(line);
    return true;
  } catch (e) {
    return false;
  }
}

/**
 * get a random (biased) line from a list; probabilityPower: see biasedRandomNumber()
 */
String getRandomLine(List<String> lines, double probabilityPower) {
  int randomLineNumber = biasedRandomNumber(0, lines.length - 1, probabilityPower: probabilityPower);
  return lines[randomLineNumber];
}


/**
 * generate biased random number between [min] and [max] 
 * [probabilityPower] > 1 results in bias towards lower number
 * [probabilityPower] < 1 = bias towards higher numbers 
 * source: https://stackoverflow.com/a/7262658
 */
int biasedRandomNumber(int min, int max, {double probabilityPower = 2.5}) {
  double randomNumber = random.nextDouble();
  double a = (min + (max + 1 - min)).floorToDouble();
  double b = pow(randomNumber, probabilityPower).toDouble();
  return (a * b).toInt();
}

