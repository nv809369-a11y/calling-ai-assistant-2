// Project Name: Calling AI Assistant
// Created by Nitin Editor

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

void main() {
  runApp(const CallingAIAssistantApp());
}

class CallingAIAssistantApp extends StatelessWidget {
  const CallingAIAssistantApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calling AI Assistant',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isAssistantActive = false;
  static String ownerName = "Nitin"; 
  
  final FlutterTts flutterTts = FlutterTts();
  final stt.SpeechToText speechToText = stt.SpeechToText();
  
  bool isListening = false;
  String lastRecognizedWords = "Call aane ka wait ho raha hai...";
  String aiResponseText = "AI assistant ready hai.";

  int _tapCount = 0;

  @override
  void initState() {
    super.initState();
    _configureVoiceEngine();
  }

  Future<void> _configureVoiceEngine() async {
    await flutterTts.setLanguage("hi-IN");
    await flutterTts.setSpeechRate(0.45);
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);
  }

  Future<void> simulateIncomingCall() async {
    String greeting = "Hello sir, namaste! Boliye, main $ownerName ka assistant bol raha hu. Bataiye kya kaam hai?";
    await flutterTts.speak(greeting);
    await Future.delayed(const Duration(seconds: 4));
    _startListeningToCaller();
  }

  void _startListeningToCaller() async {
    bool available = await speechToText.initialize();
    if (available) {
      setState(() {
        isListening = true;
        lastRecognizedWords = "Sun rahe hain... boliye aap kya kehna chahte hain?";
      });

      speechToText.listen(
        onResult: (result) {
          setState(() {
            lastRecognizedWords = result.recognizedWords;
          });
          if (result.finalResult || result.recognizedWords.isNotEmpty) {
            _handleAIResponse(result.recognizedWords);
          }
        },
      );
    }
  }

  void _handleAIResponse(String callerInput) async {
    speechToText.stop();
    setState(() {
      isListening = false;
    });

    String reply = "";
    String lowerInput = callerInput.toLowerCase();

    if (lowerInput.contains('galat') || lowerInput.contains('chutiya') || lowerInput.contains('bhadwa') || lowerInput.contains('faltu')) {
      reply = "Sir, aap please tameez se baat kijiye. Aise galat bhasha ka upyog mat kariye, warna mujhe call disconnect karni padegi. Aapka shubh naam kya hai?";
    } else if (lowerInput.contains('naam') || lowerInput.contains('kaun ho')) {
      reply = "Main $ownerName ji ki personal assistant hoon. Bataiye unse kya baat karni hai?";
    } else {
      reply = "Main aapki baat samajh gayi hu. $ownerName ji ko aapka yeh message zaroor de dungi. Kya kuch aur kehna hai aapko?";
    }

    setState(() {
      aiResponseText = reply;
    });

    await flutterTts.speak(reply);
  }

  void _handleSecretTap(BuildContext context) {
    _tapCount++;
    if (_tapCount >= 5) {
      _tapCount = 0; 
      _showPreAdminPasswordDialog(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calling AI Assistant'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.support_agent, size: 80, color: Colors.deepPurple),
            const SizedBox(height: 20),
            Text(
              'Assistant for: $ownerName',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepPurple),
            ),
            const SizedBox(height: 10),
            Text(
              isAssistantActive ? 'Assistant is ACTIVE & Ready' : 'Assistant is OFF',
              style: TextStyle(
                fontSize: 16,
                color: isAssistantActive ? Colors.green : Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            SwitchListTile(
              title: const Text('Enable Auto-Call AI Answering'),
              subtitle: const Text('Automatically pickup, listen & reply respectfully'),
              value: isAssistantActive,
              onChanged: (bool value) {
                setState(() {
                  isAssistantActive = value;
                });
              },
            ),
            const SizedBox(height: 15),
            ElevatedButton.icon(
              onPressed: simulateIncomingCall,
              icon: const Icon(Icons.phone_in_talk),
              label: const Text('Test Live AI Conversation'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
            ),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.purple.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('📞 Caller Said: "$lastRecognizedWords"', style: const TextStyle(fontSize: 13, color: Colors.black87)),
                  const SizedBox(height: 5),
                  Text('🤖 AI Reply: "$aiResponseText"', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                ],
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () {
                _showCustomerSupportDialog(context);
              },
              icon: const Icon(Icons.headset_mic),
              label: const Text('Customer Support'),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => _handleSecretTap(context),
              child: const Text(
                'Created by Nitin Editor',
                style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPreAdminPasswordDialog(BuildContext context) {
    final TextEditingController prePassController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Security Verification'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Enter Access Code to proceed:', style: TextStyle(fontSize: 13, color: Colors.grey)),
              const SizedBox(height: 10),
              TextField(
                controller: prePassController,
                obscureText: true,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Enter Code (737448)'),
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
                String enteredCode = prePassController.text.trim();
                Navigator.pop(context);
                if (enteredCode == "737448") {
                  _showFinalAdminLoginDialog(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Incorrect Code! Auto-back activated.')),
                  );
                }
              },
              child: const Text('Verify'),
            ),
          ],
        );
      },
    );
  }

  void _showFinalAdminLoginDialog(BuildContext context) {
    final TextEditingController idController = TextEditingController();
    final TextEditingController passController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Admin Panel Login'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Created by Nitin Editor', style: TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 10),
              TextField(
                controller: idController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Enter Admin ID'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: passController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Enter Admin Password'),
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
                String inputID = idController.text.trim();
                String inputPass = passController.text.trim();
                Navigator.pop(context);

                if (inputID == "7307448905" && inputPass == "29/05/2005") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AdminPanelScreen()),
                  ).then((_) => setState(() {}));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Access Denied! Auto-back activated.')),
                  );
                }
              },
              child: const Text('Login'),
            ),
          ],
        );
      },
    );
  }

  void _showCustomerSupportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Customer Support'),
          content: const Text('For any assistance, contact creator Nitin Editor.\n\nEmail: Nv809369@gmail.com'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({Key? key}) : super(key: key);

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  final TextEditingController _nameController = TextEditingController(text: _HomeScreenState.ownerName);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel - Nitin Editor'),
        backgroundColor: Colors.black87,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Welcome Admin (Nitin Editor)', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            const Text('Change Assistant Owner Name (Instant Update):', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter Name',
              ),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _HomeScreenState.ownerName = _nameController.text.trim();
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Name updated successfully!')),
                );
              },
              child: const Text('Update Name Immediately'),
            ),
            const SizedBox(height: 30),
            const Text('• Saved Call Recordings & Logs Manager'),
            const Spacer(),
            const Center(
              child: Text(
                'Created by Nitin Editor',
                style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
