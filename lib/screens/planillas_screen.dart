import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:employee_attendance/constants/constants.dart';
import 'package:employee_attendance/services/db_service.dart';
import 'package:employee_attendance/services/attendance_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart' as route;
import 'package:simple_month_year_picker/simple_month_year_picker.dart';
import 'package:employee_attendance/models/user_model.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:open_document/my_files/init.dart';
import 'package:syncfusion_flutter_datagrid_export/export.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:employee_attendance/helper/save_file_mobile.dart' if (dart.library.html) 'package:employee_attendance/helper/save_file_web.dart' as helper;

import '../services/auth_service.dart';


class PlanillaScreen extends StatefulWidget {
  const PlanillaScreen({super.key});

  @override
  State<PlanillaScreen> createState() => _PlanillaScreenState();
}

class _PlanillaScreenState extends State<PlanillaScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;
  late final bool allowFiltering;
  String selectedName = '';
  int? selectedpas;
  String selectedProyecto = '';
  late var fecha = '';
  int selectedOption = 246; // Opción seleccionada inicialmente

  late EmployeeDataSource _employeeDataSource =
  EmployeeDataSource(employeeData: []);
  List<Employee> _employees = <Employee>[];
  final GlobalKey<SfDataGridState> _key = GlobalKey<SfDataGridState>();

  @override
  void initState() {
    super.initState();
    getEmployeeDataFromSupabase().then((employeeList) {
      setState(() {
        _employees = employeeList;
        _employeeDataSource = EmployeeDataSource(employeeData: _employees);

      });
    });
  }
///////////////////
  Future<void> _exportDataGridToPdf(String periodo , String nombre  ,String proyecto) async {
    final PdfDocument document =
    _key.currentState!.exportToPdfDocument(
      excludeColumns: const <String>['id'],
      exportTableSummaries: true,
      exportStackedHeaders: true,
      fitAllColumnsInOnePage: true,
      headerFooterExport: (DataGridPdfHeaderFooterExportDetails headerFooterExport) {
        final double width = headerFooterExport.pdfPage.getClientSize().width;
        final PdfPageTemplateElement header = PdfPageTemplateElement(Rect.fromLTWH(0, 0, width, 65));
        header.graphics.drawString(
          '\n Proyecto: ' + proyecto,
          PdfStandardFont(PdfFontFamily.helvetica, 11, style: PdfFontStyle.bold),
          bounds: const Rect.fromLTWH(170, 25, 200, 60),
        );
        header.graphics.drawString(
          '\n Periodo:' + periodo,
         // '\n Fecha:' + DateFormat.yMMMd().format(DateTime.now()),
          PdfStandardFont(PdfFontFamily.helvetica, 11, style: PdfFontStyle.bold),
          bounds: const Rect.fromLTWH(400, 25, 200, 60),
        );
        header.graphics.drawString(
          'REGISTRO DE ASISTENCIAS \n Nombre:' + nombre ,
          PdfStandardFont(PdfFontFamily.helvetica, 11, style: PdfFontStyle.bold),
          bounds: const Rect.fromLTWH(0, 25, 200, 60),
        );
        headerFooterExport.pdfDocumentTemplate.top = header;
      },
    );
    PdfPage page = document.pages[0];
    page.graphics.drawString(
        '                 _____________________                  _____________________', PdfStandardFont(PdfFontFamily.helvetica, 12),
        bounds: const Rect.fromLTWH(40, 650, 400, 30));
    document.pageSettings.orientation = PdfPageOrientation.landscape;
    final List<int> bytes = document.saveSync();
    await helper.saveAndLaunchFile(bytes, 'DataGrid.pdf');
    document.dispose();
  }



  //////////////////////////////
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
            e['created_at'].toString()!= "null" ? e['created_at'] : "null",
            e['obraid'].toString(),
            e['check_in'].toString() != "null" ? e['check_in'] : "null",
            // e['check_in'].toString() != "null" ? e['check_in'] : "00:00",
            e['check_out'].toString() != "null" ? e['check_out'] : "null",
            e['obraid2'].toString(),
            e['check_in2'].toString() != "null" ? e['check_in2'] : "null",
            e['check_out2'].toString() != "null"
                ? e['check_out2']
                : "null"))
            .toList();
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
    final attendanceService = route.Provider.of<AttendanceService>(context);
    final dbService = route.Provider.of<DbService>(context);
    dbService.allempleados.isEmpty ? dbService.getAllempleados() : null;

    return Scaffold(
        appBar: AppBar(
          leading: Builder(builder: (BuildContext context) {
            return Container(
              child: Image(image: AssetImage('/icon/icon.png')),
            );
          }),
          title: Text(
            "ArtConsGroup",
            style: TextStyle(fontSize: 17),
          ),
          actions: [
            Row(
              children: [
                Icon(
                  Icons.brightness_2_outlined,
                  size:17, // Icono para tema claro
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
              margin: const EdgeInsets.only(top: 20),
              alignment: Alignment.topRight,
              child: TextButton.icon(
                  onPressed: () {
                    route.Provider.of<AuthService>(context, listen: false)
                        .signOut();
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text("Salir")),
            ),
            Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.only(left: 20, top: 15, bottom: 5),
              child: const Text(
                "Resumen de Asistencias",
                style: TextStyle(fontSize: 17),
              ),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                dbService.allempleados.isEmpty
                    ? SizedBox( width:60,
                    child: const LinearProgressIndicator())
                    : Container(
                  //  padding: EdgeInsets.all(5),
                  margin: const EdgeInsets.only(
                      left: 5, top: 5, bottom: 10, right: 10),
                  height: 45,
                  width: 300,
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
                          style: const TextStyle(fontSize: 14),
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
                        selectedName = dbService.allempleados.firstWhere(
                                (element) => element.id == selectedValue).name.toString();
                    selectedpas= dbService.allempleados.firstWhere(
                                (element) => element.id == selectedValue).department;
                        selectedProyecto = dbService.allDepartments.firstWhere(
                                (element) => element.id == selectedpas).title;
                        // filterData(); // Volver a filtrar los datos cuando se selecciona una opción nueva
                      });
                    },
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
                        //attendanceService.attendanceHistoryMonth= fecha;
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
                          'Dia2',
                          FilterCondition(
                            value: fecha,
                            filterOperator: FilterOperator.and,
                            type: FilterType.equals,
                          ),
                        );
                      });
                    },
                    child: const Text("Mes",
                        style: const TextStyle(fontSize: 15))
                ),
                Text(
                  fecha,
                  style: const TextStyle(fontSize: 15),
                ),
              /*  MaterialButton(
                    child: Text('Clear Filters'),
                    onPressed: () {
                      _employeeDataSource.clearFilters();
                    }),*/
                Text(dbService.empleadolista == null
                    ? "Nombre no seleccionado"
                    : "Nombre: "),
                Text( selectedName),
                Container(
                  width: 10,
                ),
                Text("Proyecto: $selectedProyecto"),
                Container(
                  margin: const EdgeInsets.all(12.0),
                  child: Row(
                    children: <Widget>[
                      const Padding(padding: EdgeInsets.all(20)),
                      SizedBox(
                        height: 40.0,
                        width: 150.0,
                        child: MaterialButton(
                            color: Colors.blue,
                            onPressed: () async { await _exportDataGridToPdf(attendanceService.attendanceHistoryMonth, selectedName,selectedProyecto);},
                            child: const Center(
                                child: Text(
                                  'Exportar a PDF',
                                  style: TextStyle(color: Colors.white),
                                ))),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Expanded(child: SfDataGridTheme(
              data: SfDataGridThemeData(),
              child: SfDataGrid(
                key: _key,
                source: _employeeDataSource,
                rowHeight: 45,
                headerRowHeight: 30,
                tableSummaryRows: [
                  GridTableSummaryRow(
                      showSummaryInRow: false,
                      title: '{Count2}',
                      titleColumnSpan: 6,
                      columns: [
                        GridSummaryColumn(
                            name: 'Count2',
                            columnName: 'TotalHoras',
                            summaryType: GridSummaryType.sum),
                      ],
                      position: GridTableSummaryRowPosition.bottom),

                ],

                columnWidthCalculationRange: ColumnWidthCalculationRange.allRows,
                //allowFiltering: true,
                allowSorting: true,
                allowMultiColumnSorting: true,
                //columnWidthMode: ColumnWidthMode.auto,
                //  gridLinesVisibility: GridLinesVisibility.both,
                headerGridLinesVisibility: GridLinesVisibility.both,
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
                      columnName: 'Dia2',
                      allowFiltering: false,
                      allowSorting: false,
                      label: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Dia2',
                            overflow: TextOverflow.ellipsis,
                          ))),
                  GridColumn(
                      columnName: 'Dia',
                      allowFiltering: false,
                      allowSorting: false,
                      label: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Dia',
                            overflow: TextOverflow.ellipsis,
                          ))),
                  GridColumn(
                      columnName: 'Fecha',
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
                      columnName: 'Proyecto',
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
                      columnName: 'HoraIn',
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
                      columnName: 'HoraOut',
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
                      columnName: 'SuTotalH1',
                      allowFiltering: false,
                      allowSorting: false,
                      label: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'subHoras',
                            overflow: TextOverflow.ellipsis,
                          ))),
                  GridColumn(
                      columnName: 'Proyecto2',
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
                      columnName: 'HoraIn2',
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
                      columnName: 'HoraOut2',
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
                      columnName: 'SuTotalH2',
                      allowFiltering: false,
                      allowSorting: false,
                      label: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'subHoras',
                            overflow: TextOverflow.ellipsis,
                          ))),
                  GridColumn(
                      columnName: 'TotalHoras',
                      allowFiltering: false,
                      allowSorting: false,
                      label: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Total Horas',
                            overflow: TextOverflow.ellipsis,
                          ))),
                ],
                stackedHeaderRows: <StackedHeaderRow>[
                  StackedHeaderRow(cells: [
                    StackedHeaderCell(
                        columnNames: [
                          'id',
                          'Dia2',
                          'Dia',
                          'Fecha',
                          'Proyecto',
                          'HoraIn',
                          'HoraOut',
                          'SuTotalH1',
                          'Proyecto2',
                          'HoraIn2',
                          'HoraOut2',
                          'SuTotalH2',
                          'TotalHoras'
                        ],
                        child: Container(
                          // color: Colors.cyan[200],
                            child: const Center(
                                child: Text('NOMINA DE ASISTENCIA')))),
                  ])
                ],
                selectionMode: SelectionMode.multiple,
              ),
            ))
          ],
        ));
  }
}

class EmployeeDataSource extends DataGridSource {
  /// Creates the employee data source class with required details.
  String obtenerSumaDeTiempo(String HoraOut, String HoraIn, String HoraOut2, String HoraIn2) {
    if (HoraIn == "null" || HoraOut == "null") {
      if (HoraIn2 == "null" || HoraOut2 == "null") {
        return Tiempo2('00:00', '00:00', '00:00', '00:00').obtenerSumadeTiempo().toString();
      } else {
        return Tiempo2('00:00', '00:00', HoraOut2, HoraIn2).obtenerSumadeTiempo().toString();
      }
    } else {
      if (HoraIn2 == "null" || HoraOut2 == "null") {
        return Tiempo2(HoraOut, HoraIn, '00:00', '00:00').obtenerSumadeTiempo().toString();
      } else {
        return Tiempo2(HoraOut, HoraIn, HoraOut2, HoraIn2).obtenerSumadeTiempo().toString();
      }
    }
  }

  String obtenerSumaDeTiempo2(String HoraOut, String HoraIn, String HoraOut2, String HoraIn2) {
    if (HoraIn == "null" || HoraOut == "null") {
      if (HoraIn2 == "null" || HoraOut2 == "null") {
        return Tiempo3('00:00', '00:00', '00:00', '00:00').obtenerSumadeTiempoenminutos().toString();
      } else {
        return Tiempo3('00:00', '00:00', HoraOut2, HoraIn2).obtenerSumadeTiempoenminutos().toString();
      }
    } else {
      if (HoraIn2 == "null" || HoraOut2 == "null") {
        return Tiempo3(HoraOut, HoraIn, '00:00', '00:00').obtenerSumadeTiempoenminutos().toString();
      } else {
        return Tiempo3(HoraOut, HoraIn, HoraOut2, HoraIn2).obtenerSumadeTiempoenminutos().toString();
      }
    }
  }

  EmployeeDataSource({required List<Employee> employeeData}) {
    _employeeData = employeeData
        .map<DataGridRow>((e) => DataGridRow(cells: [
      DataGridCell<String>(columnName: 'id', value: e.id),
      DataGridCell<String>(
          columnName: 'Dia2', value: e.Dia2.toString().substring(3)),
      DataGridCell<String>(
          columnName: 'Dia', value: Diadelasemana(e.Fecha).obtenerdia().toString()),
      DataGridCell<String>(
          columnName: 'Fecha',
          value: e.Fecha.split('T')[0].toString()),
      DataGridCell<String>(columnName: 'Proyecto', value: e.Proyecto),
      DataGridCell<String>(columnName: 'HoraIn', value: e.HoraIn),
      DataGridCell<String>(columnName: 'HoraOut', value: e.HoraOut),
      DataGridCell<String>(
          columnName: 'SuTotalH1',
          value: (e.HoraIn == "null" || e.HoraOut == "null")
              ? "00:00"
              : Tiempo(e.HoraOut, e.HoraIn).obtenerDiferenciaTiempo().toString()
      ),
      DataGridCell<String>(columnName: 'Proyecto2', value: e.Proyecto2),
      DataGridCell<String>(columnName: 'HoraIn2', value: e.HoraIn2),
      DataGridCell<String>(columnName: 'HoraOut2', value: e.HoraOut2),

      DataGridCell<String>(
          columnName: 'SuTotalH2',
          value: (e.HoraIn2 == "null" || e.HoraOut2 == "null")
              ? "00:00"
              :  Tiempo(e.HoraOut2, e.HoraIn2).obtenerDiferenciaTiempo().toString()
      ),
      DataGridCell<int>(
          columnName: 'TotalHoras',
          value: int.parse(obtenerSumaDeTiempo2(e.HoraOut, e.HoraIn,e.HoraOut2, e.HoraIn2))
      /*DataGridCell<String>(
          columnName: 'TotalHoras',
          value: obtenerSumaDeTiempo2(e.HoraOut, e.HoraIn,e.HoraOut2, e.HoraIn2)*/
        /* (DateFormat.Hm()
                          .format(DateFormat("hh:mm").parse(e.HoraOut2))).difference(DateFormat.Hm()
                      .format(DateFormat("hh:mm").parse(e.HoraIn2))))*/
      )
    ]))
        .toList();

  }

  List<DataGridRow> _employeeData = [];

  @override
  List<DataGridRow> get rows => _employeeData;

/*  @override
  String calculateSummaryValue(GridTableSummaryRow summaryRow,
      GridSummaryColumn? summaryColumn, RowColumnIndex rowColumnIndex) {
    List<int> getCellValues(GridSummaryColumn summaryColumn) {
      final List<int> values = <int>[];
      for (final DataGridRow row in rows) {
        final DataGridCell? cell = row.getCells().firstWhereOrNull(
                (DataGridCell element) =>
            element.columnName == summaryColumn.columnName);
        if (cell != null && cell.value != null) {
          values.add(cell.value);
        }
      }
      return values;
    }

    String? title = summaryRow.title;
    if (title != null) {
      if (summaryRow.showSummaryInRow && summaryRow.columns.isNotEmpty) {
        for (final GridSummaryColumn summaryColumn in summaryRow.columns) {
          if (title!.contains(summaryColumn.name)) {
            double deviation = 0;
            final List<int> values = getCellValues(summaryColumn);
            if (values.isNotEmpty) {
              int sum = values.reduce((value, element) =>
              value + pow(element - values.average, 2).toInt());
              deviation = sqrt((sum) / (values.length - 1));
            }
            title = title.replaceAll(
                '{${summaryColumn.name}}', deviation.toString());
          }
        }
      }
    }

    return title ?? '';
  }*/

  @override
  Widget? buildTableSummaryCellWidget(
      GridTableSummaryRow summaryRow,
      GridSummaryColumn? summaryColumn,
      RowColumnIndex rowColumnIndex,
      String summaryValue,
      ) {
    print("valooooo$summaryValue"+"dd");
int i = int.parse(summaryValue);
    Duration duracion = Duration(minutes: i);
    String horasf = '${duracion.inHours}';
    String minuf= '${duracion.inMinutes.remainder(60).toString().padLeft(2, '0')}';
    String resultados =  horasf+":"+minuf;
    return Container(
      padding: EdgeInsets.all(15.0),
      child: Text(resultados),
    );
  }


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


class Diadelasemana {
  String inghora;

  Diadelasemana(this.inghora);

  String obtenerdia() {
   /* DateTime horaOutDateTime = DateFormat('EEE').parse();
    String resultado =  horaOutDateTime.toString();*/

    DateTime dateTime = DateTime.parse(inghora);
    DateFormat dateFormat = DateFormat('E', "es_ES");
    String resultado = dateFormat.format(dateTime);

    print("dia:$resultado");
     return resultado;
  }
}



class Tiempo {
  String horaOut;
  String horaIn;

  Tiempo(this.horaOut, this.horaIn);

  String obtenerDiferenciaTiempo() {
    DateTime horaOutDateTime = DateFormat('HH:mm').parse(horaOut);
    DateTime horaInDateTime = DateFormat('HH:mm').parse(horaIn);
    Duration diferenciaTiempo = horaOutDateTime.difference(horaInDateTime);
    String horas = '${diferenciaTiempo.inHours}';
    String minutos = '${diferenciaTiempo.inMinutes.remainder(60).toString().padLeft(2, '0')}';
    String resultado =  horas +":" + minutos;
    return resultado;
  }
}

class Tiempo3 {
  String horaOut;
  String horaIn;
  String horaOut2;
  String horaIn2;

  Tiempo3(this.horaOut, this.horaIn, this.horaOut2, this.horaIn2);

  String obtenerSumadeTiempoenminutos() {
    DateTime horaOutDateTime = DateFormat('HH:mm').parse(horaOut);
    DateTime horaInDateTime = DateFormat('HH:mm').parse(horaIn);
    DateTime horaOutDateTime2 = DateFormat('HH:mm').parse(horaOut2);
    DateTime horaInDateTime2 = DateFormat('HH:mm').parse(horaIn2);
    Duration diferenciaTiempo = horaOutDateTime.difference(horaInDateTime);
    Duration diferenciaTiempo2 = horaOutDateTime2.difference(horaInDateTime2);
    Duration sumaHoras = diferenciaTiempo + diferenciaTiempo2 ;
    String sumahoras = '${sumaHoras.inHours}';
    String sumaminutos1 = '${sumaHoras.inMinutes}';
    String sumaminutos = '${sumaHoras.inMinutes.remainder(60).toString().padLeft(2, '0')}';
    String resultado =  sumahoras +":" + sumaminutos;


    print ("minutos:$sumaminutos1");


    return sumaminutos1;

  }
}



class Tiempo2 {
  String horaOut;
  String horaIn;
  String horaOut2;
  String horaIn2;

  Tiempo2(this.horaOut, this.horaIn, this.horaOut2, this.horaIn2);

  String obtenerSumadeTiempo() {
    DateTime horaOutDateTime = DateFormat('HH:mm').parse(horaOut);
    DateTime horaInDateTime = DateFormat('HH:mm').parse(horaIn);
    DateTime horaOutDateTime2 = DateFormat('HH:mm').parse(horaOut2);
    DateTime horaInDateTime2 = DateFormat('HH:mm').parse(horaIn2);
    Duration diferenciaTiempo = horaOutDateTime.difference(horaInDateTime);
    Duration diferenciaTiempo2 = horaOutDateTime2.difference(horaInDateTime2);
    Duration sumaHoras = diferenciaTiempo + diferenciaTiempo2 ;
    String sumahoras = '${sumaHoras.inHours}';
    String sumaminutos = '${sumaHoras.inMinutes.remainder(60).toString().padLeft(2, '0')}';
    String resultado =  sumahoras +":" + sumaminutos;

    print (diferenciaTiempo);
    print (diferenciaTiempo2);
    print (sumaHoras);
    print (sumahoras);
    print (sumaminutos);

    return resultado;

  }
}
class Employee {
  /// Creates the employee class with required details.
  Employee(this.id, this.Dia2, this.Fecha, this.Proyecto, this.HoraIn,
      this.HoraOut, this.Proyecto2, this.HoraIn2, this.HoraOut2);

  final String id;
  final String Dia2;
  final String Fecha;
  final String Proyecto;
  final String HoraIn;
  final String HoraOut;
  final String Proyecto2;
  final String HoraIn2;
  final String HoraOut2;
}