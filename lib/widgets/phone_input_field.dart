import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../config/phone_countries.dart';

/// Country code dropdown + national number field.
class PhoneInputField extends StatelessWidget {
  final TextEditingController nationalController;
  final String selectedIso;
  final ValueChanged<String>? onCountryChanged;
  final String? Function(String?)? validator;
  final bool lockIso;
  final String? lockIsoCode;

  const PhoneInputField({
    super.key,
    required this.nationalController,
    this.selectedIso = PhoneCountries.defaultIso,
    this.onCountryChanged,
    this.validator,
    this.lockIso = false,
    this.lockIsoCode,
  });

  @override
  Widget build(BuildContext context) {
    final iso = lockIso ? (lockIsoCode ?? PhoneCountries.defaultIso) : selectedIso;
    final country = PhoneCountries.byIso(iso);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (lockIso)
              Container(
                height: 56,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  '+${country.dialCode}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            else
              SizedBox(
                width: 130,
                child: DropdownButtonFormField<String>(
                  initialValue: iso,
                  isExpanded: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 12,
                    ),
                  ),
                  items: PhoneCountries.all
                      .map(
                        (c) => DropdownMenuItem(
                          value: c.iso,
                          child: Text(
                            '+${c.dialCode}',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    onCountryChanged?.call(value);
                  },
                ),
              ),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                controller: nationalController,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(country.nationalLength + 1),
                ],
                decoration: InputDecoration(
                  hintText: country.example,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: validator ??
                    (value) => country.validateNational(value),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          '${country.nationalLength} digits, e.g. ${country.example}',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}
