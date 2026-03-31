import 'dart:math';

String? handleBasicQueries(String input) {
  input = input.toLowerCase().trim();

  // Greetings

  if (['hi', 'hello', 'hey'].any((e) => input.contains(e))) {
    final replies = ['Hi, tell me a math problem', 'Hello, tell me a math problem', 'Hey, what do you want to calculate?', 'Hey there, what should I solve?','Hi there, what should I solve?'];
    return replies[Random().nextInt(replies.length)];
  }

  // Asking identity
  if (input.contains('who are you') || input.contains('what are you')||input.contains('about yourself')||input.contains('introduce yourself')) {
    return "I am CalcAI, your AI voice calculator";
  }

  if (input.contains('your name')) {
    return "CalcAI";
  }

  if (input.contains('your gender') ||
      input.contains('are you male') ||
      input.contains('are you female') ||
      input.contains('are you a girl') ||
      input.contains('are you a boy') ||
      input.contains('what are you') ||
      input.contains('are you a woman') ||
      input.contains('are you a man')) {

    return "I'm an AI, so I don't have a gender";
  }

  if (input.contains('your job') ||
      input.contains('your task') ||
      input.contains('your work') ||
      input.contains('what do you do') ||
      input.contains('your purpose')) {
    return "I help you solve math problems quickly and easily.";
  }


  if (input.contains('your age')||input.contains('how old are you')) {
    return "I don’t have an age like humans";
  }

  if (input.contains('developer name')||input.contains('who made you')||input.contains('your developer')) {
    return "Jannatul Ferdous";
  }


  // How are you
  if (input.contains('how are you')) {
    return "Good";
  }

  // Thanks
  if (input.contains('thank')) {
    return "Welcome";
  }

  // Bye
  if (input.contains('bye') ||
      input.contains('goodbye') ||
      input.contains('see you') ||
      input.contains('cya')) {
    final replies = [
      "Bye! Have a great day!",
      "See you soon!",
      "Goodbye!",
      "Catch you later!",
      "Bye! Come back anytime!",
    ];
    return replies[Random().nextInt(replies.length)];
  }

  return null; // ❗ means not handled locally
}