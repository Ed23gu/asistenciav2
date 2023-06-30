import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:employee_attendance/constants/constants.dart';
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
  late EmployeeDataSource _employeeDataSource =
      EmployeeDataSource(employeeData: []);
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
                e['date'].toString(),
                e['created_at'].toString(),
                e['obraid'].toString(),
                e['check_in'].toString(),
                e['check_out'].toString(),
                e['obraid2'].toString(),
                e['check_in2'].toString(),
                e['check_out2'].toString()))
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
    //String idempleado = 'afebcc8c-9b68-4d49-83a5-ca67971eaedb';

    // Using below conditions because build can be called multiple times
    dbService.allempleados.isEmpty ? dbService.getAllempleados() : null;
    //final attendanceService = route.Provider.of<AttendanceService>(context);
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
                    margin: const EdgeInsets.only(
                        left: 10, top: 5, bottom: 10, right: 10),
                    height: 60,
                    width: double.infinity,
                    child: DropdownButtonFormField(
                      decoration:
                          const InputDecoration(border: OutlineInputBorder()),
                      value: dbService.empleadolista ??
                          dbService.allempleados.first.id,
                      items: dbService.allempleados.map((UserModel item) {
                        return DropdownMenuItem(
                          value: item.id,
                          child: Text(
                            item.name.toString(),
                            style: const TextStyle(fontSize: 18),
                          ),
                        );
                      }).toList(),
                      onChanged: (selectedValue) {
                        setState(() {
                          dbService.empleadolista = selectedValue.toString();
                          _employeeDataSource.clearFilters();
                          _employeeDataSource.addFilter(
                              'id',
                              FilterCondition(
                                  type: FilterType.equals,
                                  value: dbService.empleadolista));
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
                            value: dbService.empleadolista,
                            // filterOperator: FilterOperator.and,
                            type: FilterType.equals,
                          ),
                        );
                        _employeeDataSource.addFilter(
                          'fecha',
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
                ),
                MaterialButton(
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
              //columnWidthMode: ColumnWidthMode.auto,
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
                    visible: false,
                    label: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'ID',
                          overflow: TextOverflow.ellipsis,
                        ))),
                GridColumn(
                    columnName: 'fecha',
                    allowFiltering: false,
                    allowSorting: false,
                    label: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'fec',
                          overflow: TextOverflow.ellipsis,
                        ))),
                GridColumn(
                    columnName: 'creatat',
                    allowFiltering: false,
                    allowSorting: true,
                    label: Container(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Fecha',
                          overflow: TextOverflow.ellipsis,
                        ))),
                GridColumn(
                    columnName: 'obra',
                    allowFiltering: false,
                    allowSorting: false,
                    label: Container(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Proyecto',
                          overflow: TextOverflow.ellipsis,
                        ))),
                GridColumn(
                    columnName: 'horain',
                    allowFiltering: false,
                    allowSorting: false,
                    label: Container(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Ingreso',
                          overflow: TextOverflow.ellipsis,
                        ))),
                GridColumn(
                    columnName: 'horaout',
                    allowFiltering: false,
                    allowSorting: false,
                    label: Container(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Salida',
                          overflow: TextOverflow.ellipsis,
                        ))),
                GridColumn(
                    columnName: 'obra2',
                    allowFiltering: false,
                    allowSorting: false,
                    label: Container(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Proyecto',
                          overflow: TextOverflow.ellipsis,
                        ))),
                GridColumn(
                    columnName: 'horain2',
                    allowFiltering: false,
                    allowSorting: false,
                    label: Container(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Ingreso',
                          overflow: TextOverflow.ellipsis,
                        ))),
                GridColumn(
                    columnName: 'horaout2',
                    allowFiltering: false,
                    allowSorting: false,
                    label: Container(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Salida',
                          overflow: TextOverflow.ellipsis,
                        ))),
                GridColumn(
                    columnName: 'totalhoras2',
                    allowFiltering: false,
                    allowSorting: false,
                    label: Container(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'THoras',
                          overflow: TextOverflow.ellipsis,
                        ))),
              ],
              stackedHeaderRows: <StackedHeaderRow>[
                StackedHeaderRow(cells: [
                  StackedHeaderCell(
                      columnNames: [
                        'id',
                        'fecha',
                        'creatat',
                        'obra',
                        'horain',
                        'horaout',
                        'obra2',
                        'horain2',
                        'horaout2',
                        'totalhoras2'
                      ],
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
              DataGridCell<String>(columnName: 'fecha', value: e.fecha.toString().substring(3)),
              DataGridCell<String>(columnName: 'creatat',value: e.creatat.split('T')[0].toString()),
              DataGridCell<String>(columnName: 'obra', value: e.obra),
              DataGridCell<String>(columnName: 'horain', value: e.horain),
              DataGridCell<String>(columnName: 'horaout', value: e.horaout),
              DataGridCell<String>(columnName: 'obra2', value: e.obra2),
              DataGridCell<String>(columnName: 'horain2', value: e.horain2),
              DataGridCell<String>(columnName: 'horaout2', value: e.horaout2),
              DataGridCell<String>(
                  columnName: 'totalhoras2',
                  value: DateFormat.Hm().format(
                      DateFormat("yyyy-MM-dd hh:mm:ss")
                          .parse('2020-01-02 03:04:05')))
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
  Employee(this.id, this.fecha, this.creatat, this.obra, this.horain,
      this.horaout, this.obra2, this.horain2, this.horaout2);

  final String id;
  final String fecha;
  final String creatat;
  final String obra;
  final String horain;
  final String horaout;
  final String obra2;
  final String horain2;
  final String horaout2;
}
