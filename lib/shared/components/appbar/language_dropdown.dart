import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ncd_screening_mobile/shared/bloc/language/language_bloc.dart';
import 'package:ncd_screening_mobile/shared/bloc/language/language_event.dart';
import 'package:ncd_screening_mobile/shared/bloc/language/language_state.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_colors.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_radius.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_spacing.dart';

class LanguageDropdown extends StatelessWidget {
  final BuildContext context;
  const LanguageDropdown({super.key, required this.context});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LanguageBloc, LanguageState>(
      builder: (context, state) {
        return DropdownButtonHideUnderline(
          child: DropdownButton2(
            isExpanded: true,
            customButton: Container(
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(PRadius.md),
              ),
              child: IconButton(
                tooltip: 'เปลี่ยนภาษา',
                onPressed: null,
                icon: Icon(
                  Icons.language,
                  color: state.isDropdownOpen
                      ? PColor.primaryColor
                      : PColor.contentColor,
                ),
              ),
            ),
            items: [
              DropdownMenuItem(
                value: const Locale('th'),
                child: Text(
                  'ไทย',
                  style: TextStyle(
                    color: state.locale == const Locale('th')
                        ? PColor.primaryColor
                        : null,
                  ),
                ),
              ),
              DropdownMenuItem(
                value: const Locale('en'),
                child: Text(
                  'English',
                  style: TextStyle(
                    color: state.locale == const Locale('en')
                        ? PColor.primaryColor
                        : PColor.contentColor,
                  ),
                ),
              ),
            ],
            value: state.locale,
            onChanged: (Locale? newLocale) {
              if (newLocale != null) {
                context.read<LanguageBloc>().add(
                  ChangeLanguageEvent(newLocale),
                );
              }
            },
            onMenuStateChange: (isOpen) {
              context.read<LanguageBloc>().add(ToggleDropdownEvent(isOpen));
            },
            dropdownStyleData: DropdownStyleData(
              width: 100,
              padding: const EdgeInsets.symmetric(vertical: PSpacing.xs),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(PRadius.xs),
                color: PColor.neutralColor,
                boxShadow: PShadow.dropdown,
              ),
              offset: const Offset(-8, -8),
            ),
          ),
        );
      },
    );
  }
}
