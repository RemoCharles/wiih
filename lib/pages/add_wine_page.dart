import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wiih/classes/country_selection.dart';
import 'package:wiih/classes/image_helper.dart';
import 'package:wiih/classes/type_selection.dart';
import 'package:wiih/classes/wine.dart';
import 'package:wiih/classes/grapevariety_selection.dart';

class AddWinePage extends StatefulWidget {
  const AddWinePage({super.key});

  @override
  _AddWinePageState createState() => _AddWinePageState();
}

class _AddWinePageState extends State<AddWinePage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController wineryController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController yearController = TextEditingController();

  String selectedType = WineOptions.types[0];
  String selectedCountry = WineOptions.countries[0];
  List<String> selectedGrapeVarieties = [];
  File? _image;

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enrich your collection'),
      ),
      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Card(
            elevation: 4,
            margin: const EdgeInsets.all(8.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Box 1: Name, Winery, Country
                  _buildTextField(
                      'Name', nameController, TextCapitalization.words),
                  _buildTextField(
                      'Winery', wineryController, TextCapitalization.words),
                  _buildCountrySelection(),

                  const SizedBox(height: 16),

                  // Box 2: Type, Grape Variety, Year, Price
                  _buildTypeSelection(),
                  _buildGrapeVarietySelection(),
                  _buildNumberInputField('Year', yearController),
                  _buildNumberInputField('Price', priceController),

                  const SizedBox(height: 16),

                  // Box 3: Image Selection
                  _buildImageSelection(),

                  const SizedBox(height: 16),

                  // Action buttons
                  _buildActionButtons(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      TextCapitalization capitalization) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        textCapitalization: capitalization,
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderSide: BorderSide(
              width: 1,
              color: Theme.of(context).colorScheme.onSecondaryContainer,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCountrySelection() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () async {
          String? result = await _showSelectionDialog(
            context,
            CountrySelectionDialog(selectedCountry: selectedCountry),
          );
          if (result != null) setState(() => selectedCountry = result);
        },
        child: _buildInputDecorator('Country', selectedCountry),
      ),
    );
  }

  Widget _buildTypeSelection() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () async {
          String? result = await _showSelectionDialog(
            context,
            TypeSelectionDialog(selectedType: selectedType),
          );
          if (result != null) setState(() => selectedType = result);
        },
        child: _buildInputDecorator('Type', selectedType),
      ),
    );
  }

  Widget _buildGrapeVarietySelection() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () async {
          List<String>? result = await _showSelectionDialog(
            context,
            GrapeVarietySelectionDialog(
              grapeVarieties: WineOptions.grapeVarieties..sort(),
              selectedValues: Set.from(selectedGrapeVarieties),
            ),
          );
          if (result != null) {
            setState(() => selectedGrapeVarieties = result..sort());
          }
        },
        child: _buildInputDecorator(
          'Grape Varieties',
          selectedGrapeVarieties.isNotEmpty
              ? selectedGrapeVarieties.join(', ')
              : 'Select',
        ),
      ),
    );
  }

  Widget _buildNumberInputField(
      String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(4),
        ],
        decoration: InputDecoration(
          labelText: label,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              width: 1,
              color: Theme.of(context).colorScheme.onSecondaryContainer,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageSelection() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          ElevatedButton.icon(
              onPressed: _captureImage, label: const Icon(Icons.camera_alt)),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: _pickImage,
            icon: const Icon(Icons.image),
            label: const Text('Pick Image'),
          ),
          const SizedBox(width: 16),
          _image != null
              ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
              : Container(),
        ],
      ),
    );
  }

  Padding _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          ElevatedButton(
            onPressed: _saveWine,
            style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context)
                    .colorScheme
                    .onPrimary // Primary color for action buttons
                ),
            child: const Text('Save'),
          ),
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context)
                    .colorScheme
                    .onPrimary // Primary color for action buttons
                ),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildInputDecorator(String label, String value) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            width: 1,
            color: Theme.of(context).colorScheme.onSecondaryContainer,
          ),
        ),
      ),
      child: Text(value),
    );
  }

  Future<T?> _showSelectionDialog<T>(
      BuildContext context, Widget dialog) async {
    return await showDialog<T>(
      context: context,
      builder: (BuildContext context) {
        return dialog;
      },
    );
  }

  Future<void> _pickImage() async {
    File? pickedImage = await pickImage();
    if (pickedImage != null) {
      setState(() {
        _image = pickedImage;
      });
    }
  }

  Future<void> _captureImage() async {
    File? capturedImage = await captureImage();
    if (capturedImage != null) {
      setState(() {
        _image = capturedImage;
      });
    }
  }

  Future<void> _saveWine() async {
    if (!_isSaveButtonEnabled()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    // Show progress dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Saving wine...'),
            ],
          ),
        );
      },
    );

    // Upload the image if available
    String? imageUrl = _image != null ? await uploadImage(_image!) : null;

    // Create the Wine object
    Wine newWine = Wine(
      id: DateTime.now().millisecondsSinceEpoch,
      name: nameController.text,
      type: selectedType,
      winery: wineryController.text,
      country: selectedCountry,
      grapeVariety: selectedGrapeVarieties.join(', '),
      year: int.tryParse(yearController.text) ?? 0,
      price: int.tryParse(priceController.text) ?? 0,
      imageUrl: imageUrl,
      bottleCount: 1,
    );

    Navigator.pop(context); // Dismiss the progress dialog
    Navigator.pop(context, newWine); // Return the new wine

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Wine saved successfully')),
    );
  }

  bool _isSaveButtonEnabled() {
    return nameController.text.isNotEmpty &&
        selectedType.isNotEmpty &&
        selectedCountry.isNotEmpty &&
        yearController.text.isNotEmpty &&
        wineryController.text.isNotEmpty;
  }
}
