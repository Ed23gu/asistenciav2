import 'package:employee_attendance/models/attendance_model.dart';
import 'package:employee_attendance/services/attendance_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:simple_month_year_picker/simple_month_year_picker.dart';

class PlanillaScreen extends StatefulWidget {
  const PlanillaScreen({super.key});

  @override
  State<PlanillaScreen> createState() => _PlanillaScreenState();
}

class _PlanillaScreenState extends State<PlanillaScreen> {
  @override
  Widget build(BuildContext context) {
    final attendanceService = Provider.of<AttendanceService>(context);
    return Column(
      children: [
        Container(
          alignment: Alignment.centerLeft,
          margin: const EdgeInsets.only(left: 20, top: 60, bottom: 10),
          child: const Text(
            "Mi Asistencia",
            style: TextStyle(fontSize: 25),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              attendanceService.attendanceHistoryMonth,
              style: const TextStyle(fontSize: 25),
            ),
            OutlinedButton(
                onPressed: () async {
                  final selectedDate =
                      await SimpleMonthYearPicker.showMonthYearPickerDialog(
                          context: context, disableFuture: true);
                  String pickedMonth =
                      DateFormat('MMMM yyyy').format(selectedDate);
                  attendanceService.attendanceHistoryMonth = pickedMonth;
                },
                child: const Text("Seleccionar mes")),
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
                                        blurRadius: 10,
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
    );
  }
}
