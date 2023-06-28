import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:employee_attendance/models/empleado_model.dart';
import 'package:employee_attendance/services/attendance_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart' as route;
import 'package:simple_month_year_picker/simple_month_year_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../constants/constants.dart';
import '../models/attendance_model.dart';

class PlanillaScreen extends StatefulWidget {
  const PlanillaScreen({super.key});

  @override
  State<PlanillaScreen> createState() => _PlanillaScreenState();
}

class _PlanillaScreenState extends State<PlanillaScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;
  late final bool allowFiltering;
  late var fecha= '';
  int selectedOption = 1; // Opción seleccionada inicialmente
  List<int> options = [
    1,
    2,
    3,
    4,
    5,
    6,
    7,
    8,
    9,
    10,
  ];
  late EmployeeDataSource _employeeDataSource;
  List<Employee> _employees = <Employee>[];

  @override
  void initState() {
    super.initState();
    _employees = getEmployeeData();
    _employeeDataSource = EmployeeDataSource(employeeData: _employees);
  }
  Future<List<AttendanceModel2>> getEmployeeData() async {
    final List data = await _supabase
        .from(Constants.attendancetable)
        .select()
        .eq('employee_id', _supabase.auth.currentUser!.id)
        .textSearch('date', "'$fecha'", config: 'english')
        .order('created_at', ascending: false);

    return data.map((attendance) => AttendanceModel2.fromJson(attendance)).toList();
  }
  @override
  Widget build(BuildContext context) {
    final attendanceService = route.Provider.of<AttendanceService>(context);
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "ArtConsGroup",
            style: TextStyle(fontSize: 25),
          ),
          actions: [
            Row(
              children: [
                Icon(
                  Icons.brightness_3, // Icono para tema claro
                  color: AdaptiveTheme.of(context).mode == AdaptiveThemeMode.light ? Colors.grey : Colors.white,
                ),
                Switch(
                    value: AdaptiveTheme.of(context).mode == AdaptiveThemeMode.light,
                    onChanged: (bool value) {
                      if (value) {
                        AdaptiveTheme.of(context).setLight();
                      } else {
                        AdaptiveTheme.of(context).setDark();
                      }
                    }

                    ),
                Icon(
                  Icons.brightness_7_rounded, // Icono para tema oscuro
                  color: AdaptiveTheme.of(context).mode == AdaptiveThemeMode.light ? Colors.white : Colors.grey,
                ),
              ],
            )
          ],
        ),
        body: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 40,
              child: DropdownButton<int>(
                value: selectedOption,
                onChanged: (int? newValue) {
                  setState(() {
                    selectedOption = newValue!;
                    _employeeDataSource.clearFilters();
                    _employeeDataSource.addFilter ('id',
                        FilterCondition(type: FilterType.equals, value: selectedOption));
                    // filterData(); // Volver a filtrar los datos cuando se selecciona una opción nueva
                  });
                },
                items: options.map<DropdownMenuItem<int>>((int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text(value.toString()),
                  );

                }).toList(),
              ),
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
                    // _employeeDataSource.addFilter ('usuario',
                    //    FilterCondition(type: FilterType.equals, value: fecha));
                    _employeeDataSource.addFilter(
                      'id',
                      FilterCondition(
                        filterOperator: FilterOperator.and,
                        value: selectedOption,
                        type: FilterType.equals,
                      ),
                    );
                    _employeeDataSource.addFilter(
                      'usuario',
                      FilterCondition(
                        value: fecha,
                        filterOperator: FilterOperator.and,
                        type: FilterType.equals,
                      ),
                    );
                  });
                },
                child: const Text("Seleccionar mes")
            ),
            MaterialButton(
                child: Text('Add \n Filter doble'),
                onPressed: () {
                  _employeeDataSource.addFilter(
                    'id',
                    FilterCondition(
                      value: selectedOption,
                      filterOperator: FilterOperator.and,
                      type: FilterType.greaterThanOrEqual,
                    ),
                  );

                  _employeeDataSource.addFilter(
                    'usuario',
                    FilterCondition(
                      value: fecha,
                      filterOperator: FilterOperator.and,
                      type: FilterType.equals,
                    ),
                  );
                }      ),
            Text(
              fecha,
              style: const TextStyle(fontSize: 10),
            ) ,

          ],
        ),
        SfDataGrid(source: _employeeDataSource,
            allowFiltering: true,
            allowSorting: true,
            allowMultiColumnSorting: true,
            //  gridLinesVisibility: GridLinesVisibility.both,
            headerGridLinesVisibility: GridLinesVisibility.both,
            onFilterChanging: (DataGridFilterChangeDetails details) {
              if (details.column.columnName == 'usuario') {
                return false;
              }
              return true;
            },
            //allowTriStateSorting: true,
            columns: [
              GridColumn(
                  columnName: 'id',
                  label: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      alignment: Alignment.centerRight,
                      child: Text(
                        'ID',
                        overflow: TextOverflow.ellipsis,
                      ))),
              GridColumn(
                  columnName: 'date',
                  // allowFiltering: false,
                  allowSorting: false,
                  label: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Fecha',
                        overflow: TextOverflow.ellipsis,
                      ))),
              GridColumn(
                  columnName: 'name',
                  allowFiltering: false,
                  allowSorting: false,
                  label: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'nombre',
                        overflow: TextOverflow.ellipsis,
                      ))),
            ]),
        Container(
          alignment: Alignment.centerLeft,
          margin: EdgeInsets.only(left: 20, top: 20, bottom: 10),
          child: Text(
            "Resumen Asistencias",
            style: TextStyle(fontSize: 20),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              attendanceService.attendanceHistoryMonth,
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(width: 10),
            OutlinedButton(
              onPressed: () async {
                final selectedDate = await SimpleMonthYearPicker.showMonthYearPickerDialog(
                  context: context,
                  disableFuture: true,
                );
                String pickedMonth = DateFormat('MMMM yyyy').format(selectedDate);
                setState(() {
                  attendanceService.attendanceHistoryMonth = pickedMonth;
                });
              },
              child: Text("Seleccionar mes"),
            ),
          ],
        ),
        Expanded(
            child: FutureBuilder(
                future: attendanceService.getAttendanceHistory(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data.length > 0) {
                      return ListView.builder(
                          itemCount: snapshot.data.length,
                          itemBuilder: (context, index) {
                            AttendanceModel attendanceData =
                                snapshot.data[index];
                            return Container(
                              margin: EdgeInsets.only(
                                  top: 12, left: 20, right: 20, bottom: 10),
                              height: 110,
                              decoration: BoxDecoration(
                                  color: Theme.of(context).brightness ==
                                          Brightness.light
                                      ? Colors.white
                                      //  color: Colors.white,
                                      : Color.fromARGB(255, 43, 41, 41),
                                  boxShadow: [
                                    BoxShadow(
                                        color:
                                            Color.fromARGB(110, 18, 148, 255),
                                        blurRadius: 3,
                                        offset: Offset(2, 2)),
                                  ],
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20))),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                      child: Container(
                                    width: 50,
                                    decoration: const BoxDecoration(
                                      color: Colors.blue,
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(20)),
                                    ),
                                    child: Center(
                                      child: Text(
                                        DateFormat("EE \n dd", "es_ES")
                                            .format(attendanceData.createdAt),
                                        style: const TextStyle(
                                            fontSize: 18,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  )),

                                  Expanded(
                                    child: Column(children: [
                                   /*   Container(
                                        height: 20,
                                        child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Text(
                                                "Nombre:",
                                                style: TextStyle(
                                                  decorationThickness: 2.2,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15,
                                                  color: Theme.of(context)
                                                              .brightness ==
                                                          Brightness.light
                                                      ? Colors.black
                                                      //  color: Colors.white,
                                                      : Colors.white,
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              Text(
                                                attendanceData.usuario ??
                                                    '--/--',
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  color: Theme.of(context)
                                                              .brightness ==
                                                          Brightness.light
                                                      ? Colors.black
                                                      //  color: Colors.white,
                                                      : Colors.white,
                                                ),
                                              ),
                                            ]),
                                      ),
                                      const SizedBox(
                                        child: Divider(),
                                      ), */
                                      Expanded(
                                          child: Row(children: [
                                        Expanded(
                                            child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              "Proyecto",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                                color: Theme.of(context)
                                                            .brightness ==
                                                        Brightness.light
                                                    ? Colors.black
                                                    //  color: Colors.white,
                                                    : Colors.white,
                                              ),
                                            ),
                                            Text(
                                              attendanceData.obra?.toString() ??
                                                  '--/--',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Theme.of(context)
                                                            .brightness ==
                                                        Brightness.light
                                                    ? Colors.black
                                                    //  color: Colors.white,
                                                    : Colors.white,
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 10,
                                              child: Divider(),
                                            ),
                                            Expanded(
                                                child: Row(children: [
                                              Expanded(
                                                  child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    "Ingreso",
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 15,
                                                      color: Theme.of(context)
                                                                  .brightness ==
                                                              Brightness.light
                                                          ? Colors.black
                                                          //  color: Colors.white,
                                                          : Colors.white,
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height: 10,
                                                    width: 80,
                                                    child: Divider(),
                                                  ),
                                                  Text(
                                                    attendanceData.checkIn,
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                      color: Theme.of(context)
                                                                  .brightness ==
                                                              Brightness.light
                                                          ? Colors.black
                                                          //  color: Colors.white,
                                                          : Colors.white,
                                                    ),
                                                  )
                                                ],
                                              )),
                                              Expanded(
                                                  child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    "Salida",
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 15,
                                                      color: Theme.of(context)
                                                                  .brightness ==
                                                              Brightness.light
                                                          ? Colors.black
                                                          //  color: Colors.white,
                                                          : Colors.white,
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height: 10,
                                                    width: 80,
                                                    child: Divider(),
                                                  ),
                                                  Text(
                                                    attendanceData.checkOut
                                                            ?.toString() ??
                                                        '--/--',
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                      color: Theme.of(context)
                                                                  .brightness ==
                                                              Brightness.light
                                                          ? Colors.black
                                                          //  color: Colors.white,
                                                          : Colors.white,
                                                    ),
                                                  )
                                                ],
                                              )),
                                            ])),
                                          ],
                                        )),
                                        const SizedBox(
                                          height: 10,
                                          width: 5,
                                        ),
                                        Expanded(
                                            child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              "Proyecto",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                                color: Theme.of(context)
                                                            .brightness ==
                                                        Brightness.light
                                                    ? Colors.black
                                                    //  color: Colors.white,
                                                    : Colors.white,
                                              ),
                                            ),
                                            Text(
                                              attendanceData.obra2?.toString() ??
                                                  '--/--',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Theme.of(context)
                                                            .brightness ==
                                                        Brightness.light
                                                    ? Colors.black
                                                    //  color: Colors.white,
                                                    : Colors.white,
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 10,
                                              child: Divider(),
                                            ),
                                            Expanded(
                                                child: Row(children: [
                                              Expanded(
                                                  child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    "Ingreso",
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 15,
                                                      color: Theme.of(context)
                                                                  .brightness ==
                                                              Brightness.light
                                                          ? Colors.black
                                                          //  color: Colors.white,
                                                          : Colors.white,
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height: 10,
                                                    width: 80,
                                                    child: Divider(),
                                                  ),
                                                  Text(
                                                    attendanceData.checkIn2?.toString() ??
                                                      '--/--',
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                      color: Theme.of(context)
                                                                  .brightness ==
                                                              Brightness.light
                                                          ? Colors.black
                                                          //  color: Colors.white,
                                                          : Colors.white,
                                                    ),
                                                  )
                                                ],
                                              )),
                                              Expanded(
                                                  child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    "Salida",
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 15,
                                                      color: Theme.of(context)
                                                                  .brightness ==
                                                              Brightness.light
                                                          ? Colors.black
                                                          //  color: Colors.white,
                                                          : Colors.white,
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height: 10,
                                                    width: 80,
                                                    child: Divider(),
                                                  ),
                                                  Text(
                                                    attendanceData.checkOut2
                                                            ?.toString() ??
                                                        '--/--',
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                      color: Theme.of(context)
                                                                  .brightness ==
                                                              Brightness.light
                                                          ? Colors.black
                                                          //  color: Colors.white,
                                                          : Colors.white,
                                                    ),
                                                  )
                                                ],
                                              )),
                                            ])),
                                          ],
                                        )),
                                      ])),

/////////////////////////////////////////

                                      ///
//////nombre colum///////////////////////
                                    ]),
                                  ),
///////////////////////////
                                ],
                              ),
                            );

                            ///////////////////////
                          });
                    } else {
                      return const Center(
                        child: Text(
                          "Datos no disponibles",
                          style: TextStyle(fontSize: 25),
                        ),
                      );
                    }
                  }
                  return const LinearProgressIndicator(
                    backgroundColor: Colors.white,
                    color: Colors.grey,
                  );
                })),
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
      DataGridCell<String>(columnName: 'date', value: e.date),
      DataGridCell<String>(columnName: 'usuario', value: e.usuario),
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
            alignment: Alignment.center,
            padding: EdgeInsets.all(8.0),
            child: Text(e.value.toString()),
          );
        }).toList());
  }
}


class Employee {
  final String id;
  final String date;
  final String? usuario;

  /// Creates the employee class with required details.
  Employee({required this.id, required this.date, this.usuario});/* this.designation, this.salary, this.hora*/

  factory Employee.fromJson(Map<String, dynamic> data) {
    return Employee(
      id: data['employee_id'],
      date: data['date'],
      usuario: data['nombre_asis'],
    );
  }
}
