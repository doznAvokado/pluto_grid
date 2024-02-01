import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

import 'ui.dart';

class PlutoBaseCell extends StatelessWidget implements PlutoVisibilityLayoutChild {
  final PlutoCell cell;

  final PlutoColumn column;

  final int rowIdx;

  final PlutoRow row;

  final PlutoGridStateManager stateManager;

  const PlutoBaseCell({
    Key? key,
    required this.cell,
    required this.column,
    required this.rowIdx,
    required this.row,
    required this.stateManager,
  }) : super(key: key);

  @override
  double get width => column.width;

  @override
  double get startPosition => column.startPosition;

  @override
  bool get keepAlive => stateManager.currentCell == cell;

  void _addGestureEvent(PlutoGridGestureType gestureType, Offset offset) {
    stateManager.eventManager!.addEvent(
      PlutoGridCellGestureEvent(
        gestureType: gestureType,
        offset: offset,
        cell: cell,
        column: column,
        rowIdx: rowIdx,
      ),
    );
  }

  void _handleOnTapUp(TapUpDetails details) {
    _addGestureEvent(PlutoGridGestureType.onTapUp, details.globalPosition);
  }

  void _handleOnLongPressStart(LongPressStartDetails details) {
    if (stateManager.selectingMode.isNone) {
      return;
    }

    _addGestureEvent(
      PlutoGridGestureType.onLongPressStart,
      details.globalPosition,
    );
  }

  void _handleOnLongPressMoveUpdate(LongPressMoveUpdateDetails details) {
    if (stateManager.selectingMode.isNone) {
      return;
    }

    _addGestureEvent(
      PlutoGridGestureType.onLongPressMoveUpdate,
      details.globalPosition,
    );
  }

  void _handleOnLongPressEnd(LongPressEndDetails details) {
    if (stateManager.selectingMode.isNone) {
      return;
    }

    _addGestureEvent(
      PlutoGridGestureType.onLongPressEnd,
      details.globalPosition,
    );
  }

  void _handleOnDoubleTap() {
    _addGestureEvent(PlutoGridGestureType.onDoubleTap, Offset.zero);
  }

  void _handleOnSecondaryTap(TapDownDetails details) {
    _addGestureEvent(
      PlutoGridGestureType.onSecondaryTap,
      details.globalPosition,
    );
  }

  void Function()? _onDoubleTapOrNull() {
    return stateManager.onRowDoubleTap == null ? null : _handleOnDoubleTap;
  }

  void Function(TapDownDetails details)? _onSecondaryTapOrNull() {
    return stateManager.onRowSecondaryTap == null ? null : _handleOnSecondaryTap;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      // Essential gestures.
      onTapUp: _handleOnTapUp,
      onLongPressStart: _handleOnLongPressStart,
      onLongPressMoveUpdate: _handleOnLongPressMoveUpdate,
      onLongPressEnd: _handleOnLongPressEnd,
      // Optional gestures.
      onDoubleTap: _onDoubleTapOrNull(),
      onSecondaryTapDown: _onSecondaryTapOrNull(),
      child: _CellContainer(
        cell: cell,
        rowIdx: rowIdx,
        row: row,
        column: column,
        cellPadding: column.cellPadding ?? stateManager.configuration.style.defaultCellPadding,
        stateManager: stateManager,
        child: _Cell(
          stateManager: stateManager,
          rowIdx: rowIdx,
          column: column,
          row: row,
          cell: cell,
        ),
      ),
    );
  }
}

class _CellContainer extends PlutoStatefulWidget {
  final PlutoCell cell;

  final PlutoRow row;

  final int rowIdx;

  final PlutoColumn column;

  final EdgeInsets cellPadding;

  final PlutoGridStateManager stateManager;

  final Widget child;

  const _CellContainer({
    required this.cell,
    required this.row,
    required this.rowIdx,
    required this.column,
    required this.cellPadding,
    required this.stateManager,
    required this.child,
  });

  @override
  State<_CellContainer> createState() => _CellContainerState();
}

class _CellContainerState extends PlutoStateWithChange<_CellContainer> {
  BoxDecoration _decoration = const BoxDecoration();

  @override
  PlutoGridStateManager get stateManager => widget.stateManager;

  @override
  void initState() {
    super.initState();

    updateState(PlutoNotifierEventForceUpdate.instance);
  }

  @override
  void updateState(PlutoNotifierEvent event) {
    final style = stateManager.style;

    final isCurrentCell = stateManager.isCurrentCell(widget.cell);
    final isCheckboxCell = stateManager.currentCell?.column.enableRowChecked == true;

    _decoration = update(
      _decoration,
      _boxDecoration(
        hasFocus: stateManager.hasFocus,
        readOnly: widget.column.checkReadOnly(widget.row, widget.cell),
        isEditing: stateManager.isEditing,
        isCurrentCell: isCurrentCell,
        isSelectedCell: stateManager.isSelectedCell(
          widget.cell,
          widget.column,
          widget.rowIdx,
        ),
        isGroupedRowCell: stateManager.enabledRowGroups && stateManager.rowGroupDelegate!.isExpandableCell(widget.cell),
        enableCellVerticalBorder: style.enableCellBorderVertical,
        borderColor: style.borderColor,
        activatedBorderColor: style.activatedBorderColor,
        activatedColor: style.activatedColor,
        inactivatedBorderColor: style.inactivatedBorderColor,
        wrongCellColor: style.wrongCellColor,
        gridBackgroundColor: style.gridBackgroundColor,
        cellColorInEditState: style.cellColorInEditState,
        cellColorInReadOnlyState: style.cellColorInReadOnlyState,
        cellColorGroupedRow: style.cellColorGroupedRow,
        selectingMode: stateManager.selectingMode,
        isCheckboxCell: isCheckboxCell,
      ),
    );
  }

  Color? _currentCellColor({
    required bool readOnly,
    required bool hasFocus,
    required bool isEditing,
    required Color activatedColor,
    required Color gridBackgroundColor,
    required Color cellColorInEditState,
    required Color cellColorInReadOnlyState,
    required PlutoGridSelectingMode selectingMode,
  }) {
    if (!hasFocus) {
      /// 셀 선택 후 드랍다운 눌러서, 셀과 함께 그리드 조차도 포커스 아웃일 때 선택했던 셀 배경색.
      return Colors.transparent;
    }

    if (!isEditing) {
      return selectingMode.isRow ? activatedColor : null;
    }

    return readOnly == true ? cellColorInReadOnlyState : cellColorInEditState;
  }

  /// 셀 Decoration 옵션
  BoxDecoration _boxDecoration({
    required bool hasFocus,
    required bool readOnly,
    required bool isEditing,
    required bool isCurrentCell,
    required bool isSelectedCell,
    required bool isGroupedRowCell,
    required bool enableCellVerticalBorder,
    required Color borderColor,
    required Color activatedBorderColor,
    required Color activatedColor,
    required Color inactivatedBorderColor,
    required Color wrongCellColor,
    required Color gridBackgroundColor,
    required Color cellColorInEditState,
    required Color cellColorInReadOnlyState,
    required Color? cellColorGroupedRow,
    required PlutoGridSelectingMode selectingMode,
    required bool isCheckboxCell,
  }) {
    /// 0819 dwk edited. 체크박스 & 명부 다이얼로그로 추가할 때, 초기 행은 valid 체크 no.
    final isValid = isCheckboxCell || widget.cell.skipValidation || widget.row.isNew
        ? true
        : widget.column.type.isValid(widget.cell.value);

    final bool isEditableCell = widget.cell.column.enableEditingMode ?? true;

    final cellBorderColor = isEditableCell
        ? isValid
            ? activatedBorderColor
            : wrongCellColor
        : inactivatedBorderColor;

    /// 0819 readOnly 일때, 셀 선택 효과 없애기 위함. readOnly에서 스크롤 되게끔 하고자 함.
    if (widget.stateManager.mode == PlutoGridMode.readOnly) {
      return BoxDecoration(
        color: isGroupedRowCell ? cellColorGroupedRow : null,
        border: enableCellVerticalBorder
            ? BorderDirectional(
                bottom: BorderSide.none,
                end: BorderSide(color: borderColor, width: 1.0),
              )
            : null,
      );
    }

    if (isCurrentCell) {
      /// 현재 한번 선택한 셀 Border
      return BoxDecoration(
        color: _currentCellColor(
          hasFocus: hasFocus,
          isEditing: isEditing,
          readOnly: readOnly,
          gridBackgroundColor: gridBackgroundColor,
          activatedColor: activatedColor,
          cellColorInReadOnlyState: cellColorInReadOnlyState,
          cellColorInEditState: cellColorInEditState,
          selectingMode: selectingMode,
        ),
        border: hasFocus
            ? Border(
                top: BorderSide(color: cellBorderColor, width: 2),
                left: BorderSide(color: cellBorderColor, width: 2),
                right: BorderSide(
                  color: isEditableCell
                      ? isValid
                          ? activatedBorderColor
                          : wrongCellColor
                      : borderColor, // editable 아닌 셀 클릭시, 우측 보더만 굵기와 색상지정.
                  width: isEditableCell ? 2 : 1,
                ),
                bottom: BorderSide(color: cellBorderColor, width: 2),
              ) // 셀 한번누름 & 편집모드 시 스타일
            : Border(
                bottom: BorderSide.none,
                right: BorderSide(color: borderColor),
              ), // 셀을 한번 선택 후, 드랍다운 눌렀을 시, 우측 border 사라짐 이슈 방지.
      );
    } else if (isSelectedCell) {
      /// PlutoGridSelectingMode 가 cell or horizontal 일 때.
      return BoxDecoration(
        color: activatedColor,
        border: Border.all(
          color: hasFocus ? activatedBorderColor : inactivatedBorderColor,
          width: 1,
        ),
      );
    } else {
      return BoxDecoration(
        color: isGroupedRowCell ? cellColorGroupedRow : null,
        border: enableCellVerticalBorder
            ? BorderDirectional(
                bottom: BorderSide.none,
                end: BorderSide(color: borderColor, width: 1.0),
              )
            : null,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: _decoration,
      child: Padding(
        padding: widget.cellPadding,
        child: widget.child,
      ),
    );
  }
}

class _Cell extends PlutoStatefulWidget {
  final PlutoGridStateManager stateManager;

  final int rowIdx;

  final PlutoRow row;

  final PlutoColumn column;

  final PlutoCell cell;

  const _Cell({
    required this.stateManager,
    required this.rowIdx,
    required this.row,
    required this.column,
    required this.cell,
    Key? key,
  }) : super(key: key);

  @override
  State<_Cell> createState() => _CellState();
}

class _CellState extends PlutoStateWithChange<_Cell> {
  bool _showTypedCell = false;

  @override
  PlutoGridStateManager get stateManager => widget.stateManager;

  @override
  void initState() {
    super.initState();

    updateState(PlutoNotifierEventForceUpdate.instance);
  }

  @override
  void updateState(PlutoNotifierEvent event) {
    _showTypedCell = update<bool>(
      _showTypedCell,
      stateManager.isEditing && stateManager.isCurrentCell(widget.cell),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_showTypedCell && widget.column.enableEditingMode == true) {
      if (widget.column.type.isSelect) {
        return PlutoSelectCell(
          stateManager: stateManager,
          cell: widget.cell,
          column: widget.column,
          row: widget.row,
        );
      } else if (widget.column.type.isNumber) {
        return PlutoNumberCell(
          stateManager: stateManager,
          cell: widget.cell,
          column: widget.column,
          row: widget.row,
        );
      } else if (widget.column.type.isDate) {
        return PlutoDateCell(
          stateManager: stateManager,
          cell: widget.cell,
          column: widget.column,
          row: widget.row,
        );
      } else if (widget.column.type.isTime) {
        return PlutoTimeCell(
          stateManager: stateManager,
          cell: widget.cell,
          column: widget.column,
          row: widget.row,
        );
      } else if (widget.column.type.isText) {
        return PlutoTextCell(
          stateManager: stateManager,
          cell: widget.cell,
          column: widget.column,
          row: widget.row,
        );
      } else if (widget.column.type.isCurrency) {
        return PlutoCurrencyCell(
          stateManager: stateManager,
          cell: widget.cell,
          column: widget.column,
          row: widget.row,
        );
      } else if (widget.column.type.isDropdown) {
        return PlutoDropDownCell(
          stateManager: stateManager,
          cell: widget.cell,
          column: widget.column,
          row: widget.row,
        );
      } else if (widget.column.type.isAutoComplete) {
        return PlutoAutoCompleteTextCell(
          stateManager: stateManager,
          cell: widget.cell,
          column: widget.column,
          row: widget.row,
        );
      }
    }

    return PlutoDefaultCell(
      cell: widget.cell,
      column: widget.column,
      rowIdx: widget.rowIdx,
      row: widget.row,
      stateManager: stateManager,
    );
  }
}
