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
    inputFormatters = textColumn.inputFormatters;

    if (textColumn.isOnlyDigits) {
      final onlyDigitInputFormatter = DecimalTextInputFormatter(
        decimalRange: 10,
        activatedNegativeValues: false,
        allowFirstDot: false,
        decimalSeparator: "",
      );

      if (textColumn.inputFormatters != null) {
        inputFormatters = [...textColumn.inputFormatters!, onlyDigitInputFormatter];
      } else {
        inputFormatters = [onlyDigitInputFormatter];
      }
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
    inputFormatters = autoCompleteColumn.inputFormatters;

    if (autoCompleteColumn.isOnlyDigits) {
      final onlyDigitInputFormatter = DecimalTextInputFormatter(
        decimalRange: 10,
        activatedNegativeValues: false,
        allowFirstDot: false,
        decimalSeparator: "",
      );

      if (autoCompleteColumn.inputFormatters != null) {
        inputFormatters = [...autoCompleteColumn.inputFormatters!, onlyDigitInputFormatter];
      } else {
        inputFormatters = [onlyDigitInputFormatter];
      }
    }
  }
}
