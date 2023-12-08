import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pluto_grid/pluto_grid.dart';

import 'decimal_input_formatter.dart';
import 'text_cell.dart';

class PlutoTextCell extends StatefulWidget implements TextCell {
  @override
  final PlutoGridStateManager stateManager;

  @override
  final PlutoCell cell;

  @override
  final PlutoColumn column;

  @override
  final PlutoRow row;

  const PlutoTextCell({
    required this.stateManager,
    required this.cell,
    required this.column,
    required this.row,
    Key? key,
  }) : super(key: key);

  @override
  PlutoTextCellState createState() => PlutoTextCellState();
}

class PlutoTextCellState extends State<PlutoTextCell> with TextCellState<PlutoTextCell> {
  @override
  List<TextInputFormatter>? inputFormatters;

  /// 0816 dwk disables below.
  // @override
  // late TextInputType keyboardType;

  @override
  void initState() {
    super.initState();
    final textColumn = widget.column.type.text;
    final List<TextInputFormatter> additionalFormatters = [];

    if (textColumn.maxLength != null) {
      additionalFormatters.add(
          LengthLimitingTextInputFormatter(textColumn.maxLength, maxLengthEnforcement: MaxLengthEnforcement.enforced));
    }

    if (textColumn.isOnlyDigits) {
      additionalFormatters.add(DecimalTextInputFormatter(
        decimalRange: 10,
        activatedNegativeValues: false,
        allowFirstDot: false,
        decimalSeparator: "",
      ));
    }

    if (textColumn.denySpacingCharacter) {
      additionalFormatters.add(FilteringTextInputFormatter.deny(' '));
    }

    if (textColumn.denySpecialCharacter) {
      additionalFormatters
          .add(FilteringTextInputFormatter(RegExp(r"[^ㄱ-ㅎ가-힣ㅏ-ㅣa-zA-Z0-9]|[\\\[\]\^\_\`\₩]+"), allow: false));
    }

    if (textColumn.denyNumbers) {
      additionalFormatters.add(FilteringTextInputFormatter(RegExp(r"[0-9]+"), allow: false));
    }

    if (textColumn.inputFormatters != null) {
      inputFormatters = [...textColumn.inputFormatters!, ...additionalFormatters];
    } else {
      inputFormatters = [...additionalFormatters];
    }
  }
}

class PlutoAutoCompleteTextCell extends StatefulWidget implements AutoCompleteTextCell {
  @override
  final PlutoGridStateManager stateManager;

  @override
  final PlutoCell cell;

  @override
  final PlutoColumn column;

  @override
  final PlutoRow row;

  const PlutoAutoCompleteTextCell({
    required this.stateManager,
    required this.cell,
    required this.column,
    required this.row,
    Key? key,
  }) : super(key: key);

  @override
  State<PlutoAutoCompleteTextCell> createState() => _PlutoAutoCompleteTextCellState();
}

class _PlutoAutoCompleteTextCellState extends State<PlutoAutoCompleteTextCell>
    with AutoCompleteTextCellState<PlutoAutoCompleteTextCell> {
  @override
  List<TextInputFormatter>? inputFormatters;

  /// 0816 dwk disables below.
  // @override
  // late TextInputType keyboardType;

  @override
  void initState() {
    super.initState();
    final autoCompleteColumn = widget.column.type.autoComplete;
    final List<TextInputFormatter> additionalFormatters = [];

    if (autoCompleteColumn.maxLength != null) {
      additionalFormatters.add(LengthLimitingTextInputFormatter(autoCompleteColumn.maxLength,
          maxLengthEnforcement: MaxLengthEnforcement.enforced));
    }

    if (autoCompleteColumn.isOnlyDigits) {
      additionalFormatters.add(DecimalTextInputFormatter(
        decimalRange: 10,
        activatedNegativeValues: false,
        allowFirstDot: false,
        decimalSeparator: "",
      ));
    }

    if (autoCompleteColumn.denySpacingCharacter) {
      additionalFormatters.add(FilteringTextInputFormatter.deny(' '));
    }

    if (autoCompleteColumn.denySpecialCharacter) {
      additionalFormatters
          .add(FilteringTextInputFormatter(RegExp(r"[^ㄱ-ㅎ가-힣ㅏ-ㅣa-zA-Z0-9]|[\\\[\]\^\_\`\₩]+"), allow: false));
    }

    if (autoCompleteColumn.denyNumbers) {
      additionalFormatters.add(FilteringTextInputFormatter(RegExp(r"[0-9]+"), allow: false));
    }

    if (autoCompleteColumn.inputFormatters != null) {
      inputFormatters = [...autoCompleteColumn.inputFormatters!, ...additionalFormatters];
    } else {
      inputFormatters = [...additionalFormatters];
    }
  }
}
