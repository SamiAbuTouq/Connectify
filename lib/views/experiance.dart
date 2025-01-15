import 'package:flutter/material.dart';
import '../module/shared_data.dart';

class Experiance extends StatefulWidget {
  const Experiance({super.key});

  @override
  State<Experiance> createState() => _ExperianceState();
}

class _ExperianceState extends State<Experiance> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedDuration;
  final TextEditingController _optionalInfoController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Connectify',
          style: TextStyle(
            fontFamily: "F1",
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 30,
          ),
        ),
        backgroundColor: Colors.blue,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(25, 40, 25, 0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Select Your Experience",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 7),
              DropdownButtonFormField<String>(
                dropdownColor: Colors.white,
                value: _selectedDuration,
                hint: const Text("Select years of experience"),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                      value: "less than 1 Year",
                      child: Text("less than 1 Year")),
                  DropdownMenuItem(value: "1 Year", child: Text("1 Year")),
                  DropdownMenuItem(value: "2 Year", child: Text("2 Year")),
                  DropdownMenuItem(value: "4 Year", child: Text("4 Year")),
                  DropdownMenuItem(value: "3 Year", child: Text("3 Year")),
                  DropdownMenuItem(
                      value: "5 to 10 Year", child: Text("5 to 10 Year")),
                  DropdownMenuItem(value: "+10 Year", child: Text("+10 Year")),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedDuration = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return "Please select a duration.";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'More information (Optional)',
                  ),
                  const SizedBox(height: 7),
                  TextFormField(
                    controller: _optionalInfoController,
                    minLines: 3,
                    maxLines: null,
                    decoration: const InputDecoration(
                      hintText: "write here...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.arrow_forward),
                  iconAlignment: IconAlignment.end,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    iconColor: Colors.white,
                    iconSize: 22,
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blue,
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      sharedData['experiance'] = _selectedDuration;
                      sharedData['otherInfo'] = _optionalInfoController.text;
                      Navigator.pushNamed(context, "/selectService");
                    }
                  },
                  label: const Text(
                    "Next",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
