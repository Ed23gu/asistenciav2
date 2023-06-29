import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:employee_attendance/constants/constants.dart';
import 'package:employee_attendance/models/attendance_model.dart';
import 'package:employee_attendance/services/attendance_service.dart';
import 'package:employee_attendance/services/db_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart' as route;
import 'package:simple_month_year_picker/simple_month_year_picker.dart';
import 'package:employee_attendance/models/user_model.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PlanillaScreen extends StatefulWidget {
  const PlanillaScreen({super.key});

  @override
  State<PlanillaScreen> createState() => _PlanillaScreenState();
}

class _PlanillaScreenState extends State<PlanillaScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;
  late final bool allowFiltering;
  late var fecha = '';
  int selectedOption = 246; // Opción seleccionada inicialmente
  List<int> options = [
    246,
    2,
    3,
    4,
    247,
    253,
    249,
    248,
    250,
  ];
  late EmployeeDataSource _employeeDataSource ;
  List<Employee> _employees = <Employee>[];

  @override
  void initState() {
    super.initState();
    getEmployeeDataFromSupabase().then((employeeList) {
      setState(() {
        _employees = employeeList;
        print(_employees);
        _employeeDataSource = EmployeeDataSource(employeeData: _employees);
      });
    });
  }

  Future<List<Employee>> getEmployeeDataFromSupabase() async {
    try {
      final response = await _supabase
          .from(Constants.attendancetable)
          .select()
          .order('created_at', ascending: false);
      if (response != null) {
        final data = response as List<dynamic>;
        final employeeList = data
            .map((e) => Employee(
                  e['employee_id'].toString(),
                  e['date'] as String,
                  e['nombre_asis'] as String,
                  e['created_at'] as String,
                ))
            .toList();
        print(employeeList);
        return employeeList;
      } else {
        throw Exception('Error al obtener los datos de empleados');
      }
    } catch (error) {
      print('Error al obtener los datos de empleados: $error');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final dbService = route.Provider.of<DbService>(context);
    String idempleado = 'afebcc8c-9b68-4d49-83a5-ca67971eaedb';

    // Using below conditions because build can be called multiple times
    dbService.allempleados.isEmpty ? dbService.getAllempleados() : null;
    final attendanceService = route.Provider.of<AttendanceService>(context);
    return Scaffold(
        appBar: AppBar(
          leading: Builder(builder: (BuildContext context) {
            return Container(
              child: Image(image: AssetImage('assets/icon/icon.png')),
            );
          }),
          title: Text(
            "ArtConsGroup",
            style: TextStyle(fontSize: 20),
          ),
          actions: [
            Row(
              children: [
                Icon(
                  Icons.brightness_2_outlined,
                  size: 20, // Icono para tema claro
                  color:
                      AdaptiveTheme.of(context).mode == AdaptiveThemeMode.light
                          ? Colors.grey
                          : Colors.white,
                ),
                Switch(
                    value: AdaptiveTheme.of(context).mode ==
                        AdaptiveThemeMode.light,
                    onChanged: (bool value) {
                      if (value) {
                        AdaptiveTheme.of(context).setLight();
                      } else {
                        AdaptiveTheme.of(context).setDark();
                      }
                    }),
                Icon(
                  Icons.brightness_low_rounded,
                  size: 20, // Icono para tema oscuro
                  color:
                      AdaptiveTheme.of(context).mode == AdaptiveThemeMode.light
                          ? Colors.white
                          : Colors.grey,
                ),
              ],
            )
          ],
        ),
        body: Column(
          children: [
            Container(
              alignment: Alignment.centerLeft,
              margin: const EdgeInsets.only(left: 20, top: 15, bottom: 5),
              child: const Text(
                "Resumen de Asistencias",
                style: TextStyle(fontSize: 20),
              ),
            ),
            dbService.allempleados.isEmpty
                ? const LinearProgressIndicator()
                : Container(
            //  padding: EdgeInsets.all(5),
              margin: const EdgeInsets.only(left: 10, top: 5, bottom: 10,right: 10),
height: 60,
                    width: double.infinity,
                    child: DropdownButtonFormField(
                      decoration:
                          const InputDecoration(
                              border: OutlineInputBorder()),
                      value: dbService.empleadolista ??
                          dbService.allempleados.first.id,
                      items: dbService.allempleados.map((UserModel item) {
                        return DropdownMenuItem(
                            value: item.id,
                          child :Text(
                            item.name.toString(),
                            style: const TextStyle(fontSize: 18 ),
                          ),
                        );
                      }).toList(),
                      onChanged: (selectedValue) {
                        setState(() {
                          dbService.empleadolista = selectedValue.toString();
                          idempleado = selectedValue.toString();
                          _employeeDataSource.clearFilters();
                          _employeeDataSource.addFilter(
                              'id',
                              FilterCondition(
                                  type: FilterType.equals,
                                  value: idempleado));
                          // filterData(); // Volver a filtrar los datos cuando se selecciona una opción nueva
                        });
                      },
                    ),
                  ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  width: 10,
                ),
                OutlinedButton(
                    onPressed: () async {
                      final selectedDate =
                      await SimpleMonthYearPicker.showMonthYearPickerDialog(
                          context: context, disableFuture: true);
                      String pickedMonth =
                      DateFormat('MMMM yyyy').format(selectedDate);
                      setState(() {
                        fecha = pickedMonth;
                        _employeeDataSource.clearFilters();
                        _employeeDataSource.addFilter(
                          'id',
                          FilterCondition(
                            value: idempleado,
                           // filterOperator: FilterOperator.and,
                            type: FilterType.equals,
                          ),
                        );
                        _employeeDataSource.addFilter(
                          'name',
                          FilterCondition(
                            value: fecha,
                            filterOperator: FilterOperator.and,
                            type: FilterType.equals,
                          ),
                        );
                      });
                    },
                    child: const Text("Mes",
                        style: const TextStyle(fontSize: 17))),
                Container(
                  width: 10,
                ),
                Text(
                  fecha,
                  style: const TextStyle(fontSize: 18),
                ), MaterialButton(
                    child: Text('fechass'),
                    onPressed: () {
                      _employeeDataSource.addFilter(
                        'Fecha2',
                        FilterCondition(
                          value: fecha,
                          type: FilterType.contains,
                          filterBehavior: FilterBehavior.stringDataType,
                        ),
                      );
                    }),
                MaterialButton(
                    child: Text('Clear Filters'),
                    onPressed: () {
                      _employeeDataSource.clearFilters();
                    }),
              ],
            ),
            Text(dbService.empleadolista == null
                ? "-"
                : dbService.empleadolista!),

            Row(
              children: [
                Container(
                  height: 10,
                )
              ],
            ),
            SfDataGrid(
              source: _employeeDataSource,
              columnWidthCalculationRange: ColumnWidthCalculationRange.allRows,
              //allowFiltering: true,
              allowSorting: true,
              allowMultiColumnSorting: true,
              columnWidthMode: ColumnWidthMode.auto,
              //  gridLinesVisibility: GridLinesVisibility.both,
              headerGridLinesVisibility: GridLinesVisibility.both,
              onFilterChanging: (DataGridFilterChangeDetails details) {
                if (details.column.columnName == 'name') {
                  return false;
                }
                return true;
              },
              //allowTriStateSorting: true,
              columns: [
                GridColumn(
                    columnName: 'id',
                   // visible: false,
                    label: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'ID',
                          overflow: TextOverflow.ellipsis,
                        ))),
                GridColumn(
                    columnName: 'name',
                    allowFiltering: false,
                    allowSorting: false,
                    label: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Name',
                          overflow: TextOverflow.ellipsis,
                        ))),
                GridColumn(
                    columnName: 'date',
                    allowFiltering: false,
                    allowSorting: false,
                    label: Container(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Fecha',
                          overflow: TextOverflow.ellipsis,
                        ))),
                GridColumn(
                    columnName: 'date2',
                    allowFiltering: false,
                    allowSorting: false,
                    label: Container(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Fecha2',
                          overflow: TextOverflow.ellipsis,
                        ))),
              ],
              stackedHeaderRows: <StackedHeaderRow>[
                StackedHeaderRow(cells: [
                  StackedHeaderCell(
                      columnNames: ['id', 'name','date'  , 'date2'],
                      child: Container(
                         // color: Colors.cyan[200],
                          child: const Center(
                              child: Text('NOMINA DE ASISTENCIA')))),
                ])
              ],
              selectionMode: SelectionMode.multiple,
            ),
          ],
        ));
  }
}

class EmployeeDataSource extends DataGridSource {
  /// Creates the employee data source class with required details.
  EmployeeDataSource({required List<Employee> employeeData}) {
    _employeeData = employeeData
        .map<DataGridRow>((e) => DataGridRow(cells: [
              DataGridCell<String>(columnName: 'id', value: e.id),
              DataGridCell<String>(columnName: 'name', value: e.name),
              DataGridCell<String>(columnName: 'date', value: e.date),
              DataGridCell<String>(columnName: 'date2', value: DateFormat('MMMM yyyy','en_US').format(e.date2 as DateTime) )
            ]))
        .toList();
  }

  List<DataGridRow> _employeeData = [];

  @override
  List<DataGridRow> get rows => _employeeData;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
        cells: row.getCells().map<Widget>((e) {
      return Container(
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.all(8.0),
        child: Text(e.value.toString()),
      );
    }).toList());
  }
}

class Employee {
  /// Creates the employee class with required details.
  Employee(this.id, this.name, this.date , this.date2);

  /// Id of an employee.
  final String id;

  /// Name of an employee.
  final String name;

  /// Designation of an employee.
  final String date;

  final String date2;
}
