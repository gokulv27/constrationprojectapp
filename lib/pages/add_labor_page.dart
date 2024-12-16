import 'package:flutter/material.dart';
import '../models/labor.dart';
import '../models/labor_skill.dart';
import '../api/labor_api.dart';

class AddLaborPage extends StatefulWidget {
  final Labor? labor;

  const AddLaborPage({Key? key, this.labor}) : super(key: key);

  @override
  _AddLaborPageState createState() => _AddLaborPageState();
}

class _AddLaborPageState extends State<AddLaborPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _aadharController = TextEditingController();
  final TextEditingController _emergencyContactController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();
  final TextEditingController _dailyWagesController = TextEditingController();
  String? _selectedState;
  LaborSkill? _selectedSkill;
  List<LaborSkill> _skills = [];
  bool _isLoading = true;

  final List<String> _states = [
    'Andhra Pradesh', 'Arunachal Pradesh', 'Assam', 'Bihar', 'Chhattisgarh',
    'Goa', 'Gujarat', 'Haryana', 'Himachal Pradesh', 'Jharkhand',
    'Karnataka', 'Kerala', 'Madhya Pradesh', 'Maharashtra', 'Manipur',
    'Meghalaya', 'Mizoram', 'Nagaland', 'Odisha', 'Punjab', 'Rajasthan',
    'Sikkim', 'Tamil Nadu', 'Telangana', 'Tripura', 'Uttar Pradesh',
    'Uttarakhand', 'West Bengal', 'Andaman and Nicobar Islands', 'Chandigarh',
    'Dadra and Nagar Haveli and Daman and Diu', 'Delhi', 'Jammu and Kashmir',
    'Ladakh', 'Lakshadweep', 'Puducherry',
  ];

  @override
  void initState() {
    super.initState();
    _loadSkills();
    if (widget.labor != null) {
      _nameController.text = widget.labor!.name;
      _phoneController.text = widget.labor!.phoneNo;
      _aadharController.text = widget.labor!.aadharNo;
      _emergencyContactController.text = widget.labor!.emergencyContactNumber;
      _addressController.text = widget.labor!.address;
      _cityController.text = widget.labor!.city;
      _pincodeController.text = widget.labor!.pincode;
      _dailyWagesController.text = widget.labor!.dailyWages.toString();
      _selectedState = widget.labor!.state;
    }
  }

  Future<void> _loadSkills() async {
    setState(() => _isLoading = true);
    try {
      final skills = await LaborApi.getSkills();
      setState(() {
        _skills = skills;
        _isLoading = false;
        if (widget.labor != null) {
          _selectedSkill = _skills.firstWhere(
                (skill) => skill.id == widget.labor!.skillId,
            orElse: () => _skills.first,
          );
        }
      });
      print('Skills loaded: ${_skills.length}');
    } catch (e) {
      setState(() => _isLoading = false);
      print('Error loading skills: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load skills: $e')),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _aadharController.dispose();
    _emergencyContactController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _pincodeController.dispose();
    _dailyWagesController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final labor = Labor(
        id: widget.labor?.id ?? 0,
        name: _nameController.text,
        phoneNo: _phoneController.text,
        skillId: _selectedSkill?.id ?? 0, // Default to 0 if null
        skillName: _selectedSkill?.name ?? 'Unknown',
        aadharNo: _aadharController.text,
        emergencyContactNumber: _emergencyContactController.text,
        address: _addressController.text,
        city: _cityController.text,
        state: _selectedState ?? 'Unknown', // Default to 'Unknown' if null
        pincode: _pincodeController.text,
        dailyWages: double.tryParse(_dailyWagesController.text) ?? 0.0,
        createdAt: widget.labor?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.labor != null) {
        await LaborApi.updateLabor(labor);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Labor updated successfully!')),
        );
      } else {
        await LaborApi.createLabor(labor);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Labor added successfully!')),
        );
      }

      Navigator.of(context).pop(true);
    } catch (e) {
      print('Error submitting form: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save labor: $e')),
      );
    }
  }


  InputDecoration _getInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey[400]),
      filled: true,
      fillColor: Colors.grey[800],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.green, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.labor != null ? 'Edit Labor' : 'Add Labor',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Container(
        color: Colors.grey[900],
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: _getInputDecoration('Name'),
                        style: const TextStyle(color: Colors.white),
                        validator: (value) =>
                        value?.isEmpty ?? true ? 'Please enter a name' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _phoneController,
                        decoration: _getInputDecoration('Phone Number'),
                        style: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.phone,
                        validator: (value) =>
                        value?.isEmpty ?? true ? 'Please enter a phone number' : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<LaborSkill>(
                        value: _selectedSkill,
                        hint: Text(
                          'Select Skill',
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                        onChanged: (LaborSkill? newValue) {
                          setState(() {
                            _selectedSkill = newValue;
                          });
                          print('Selected skill: ${newValue?.name}');
                        },
                        items: _skills.map((LaborSkill skill) {
                          return DropdownMenuItem<LaborSkill>(
                            value: skill,
                            child: Text(skill.name, style: const TextStyle(color: Colors.white)),
                          );
                        }).toList(),
                        decoration: _getInputDecoration('Skill'),
                        dropdownColor: Colors.grey[800],
                        style: const TextStyle(color: Colors.white),
                        validator: (value) => value == null ? 'Please select a skill' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _aadharController,
                        decoration: _getInputDecoration('Aadhar Number'),
                        style: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.number,
                        validator: (value) =>
                        value?.isEmpty ?? true ? 'Please enter an Aadhar number' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emergencyContactController,
                        decoration: _getInputDecoration('Emergency Contact'),
                        style: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.phone,
                        validator: (value) => value?.isEmpty ?? true
                            ? 'Please enter an emergency contact' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _addressController,
                        decoration: _getInputDecoration('Address'),
                        style: const TextStyle(color: Colors.white),
                        validator: (value) =>
                        value?.isEmpty ?? true ? 'Please enter an address' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _cityController,
                        decoration: _getInputDecoration('City'),
                        style: const TextStyle(color: Colors.white),
                        validator: (value) =>
                        value?.isEmpty ?? true ? 'Please enter a city' : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedState,
                        hint: Text(
                          'Select State',
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                        onChanged: (value) => setState(() => _selectedState = value),
                        items: _states.map((state) {
                          return DropdownMenuItem(
                            value: state,
                            child: Text(state, style: const TextStyle(color: Colors.white)),
                          );
                        }).toList(),
                        decoration: _getInputDecoration('State'),
                        dropdownColor: Colors.grey[800],
                        style: const TextStyle(color: Colors.white),
                        validator: (value) => value == null ? 'Please select a state' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _pincodeController,
                        decoration: _getInputDecoration('Pincode'),
                        style: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.number,
                        validator: (value) =>
                        value?.isEmpty ?? true ? 'Please enter a pincode' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _dailyWagesController,
                        decoration: _getInputDecoration('Daily Wages'),
                        style: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value?.isEmpty ?? true) return 'Please enter daily wages';
                          if (double.tryParse(value!) == null) return 'Please enter a valid number';
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 152),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: Text(
                  widget.labor != null ? 'Update' : 'Add',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}