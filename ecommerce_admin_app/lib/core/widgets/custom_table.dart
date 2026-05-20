import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class CustomTableColumn {
  final String title;
  final double? width;
  final AlignmentGeometry alignment;

  CustomTableColumn({
    required this.title,
    this.width,
    this.alignment = Alignment.centerLeft,
  });
}

class CustomTable extends StatelessWidget {
  final List<CustomTableColumn> columns;
  final int rowCount;
  final Widget Function(BuildContext, int, int) cellBuilder; // context, rowIndex, columnIndex
  final Function(int)? onRowTap;
  final Widget? emptyState;
  final bool isLoading;

  const CustomTable({
    Key? key,
    required this.columns,
    required this.rowCount,
    required this.cellBuilder,
    this.onRowTap,
    this.emptyState,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40.0),
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      );
    }

    if (rowCount == 0) {
      return emptyState ??
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 40.0),
            child: Center(
              child: Text(
                'No data available',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Horizontal scroll container to prevent table overflows
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: constraints.maxWidth,
            ),
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(AppColors.background),
              dataRowMinHeight: 56,
              dataRowMaxHeight: 72,
              dividerThickness: 1,
              horizontalMargin: 20,
              columnSpacing: 24,
              columns: columns.map((col) {
                return DataColumn(
                  label: Container(
                    width: col.width,
                    alignment: col.alignment,
                    child: Text(
                      col.title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              }).toList(),
              rows: List<DataRow>.generate(rowCount, (rowIndex) {
                return DataRow(
                  color: WidgetStateProperty.resolveWith<Color?>((states) {
                    if (states.contains(WidgetState.hovered)) {
                      return AppColors.background;
                    }
                    return null;
                  }),
                  onSelectChanged: onRowTap != null
                      ? (_) => onRowTap!(rowIndex)
                      : null,
                  cells: List<DataCell>.generate(columns.length, (colIndex) {
                    final col = columns[colIndex];
                    return DataCell(
                      Container(
                        width: col.width,
                        alignment: col.alignment,
                        child: cellBuilder(context, rowIndex, colIndex),
                      ),
                    );
                  }),
                );
              }),
            ),
          ),
        );
      },
    );
  }
}
