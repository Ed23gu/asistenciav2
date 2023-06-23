import 'dart:io';
import 'package:employee_attendance/models/department_model.dart';
import 'package:quickalert/quickalert.dart';
import 'package:employee_attendance/models/user_model.dart';
import 'package:employee_attendance/services/attendance_service.dart';
import 'package:employee_attendance/services/db_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart' as route;
import 'package:slide_to_act/slide_to_act.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter_native_image/flutter_native_image.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final GlobalKey<SlideActionState> key = GlobalKey<SlideActionState>();
  final GlobalKey<SlideActionState> key2 = GlobalKey<SlideActionState>();
  bool buttonDisabled = false;
  bool buttonDisabled2 = true;
  bool buttonDisabled3 = true;
  bool buttonDisabled4 = true;
  bool buttonDisabled5 = true;
  bool isUploading = false;
  bool isUploading2 = false;
  bool isUploading3 = false;
  bool isUploading4 = false;
  int qt = 70;
  int per = 10;
  final picker = ImagePicker();
  File? pickedImage;
  File? _imagescom1;
  File? _imagescom2;
  File? _imagescom3;
  File? _imagescom4;
  File? _images;
  File? _images2;
  File? _images3;
  File? _images4;
  final SupabaseClient supabase = Supabase.instance.client;

  Future getMyFiles1() async {
    final List<FileObject> result = await supabase.storage
        .from('imageip')
        .list(path: supabase.auth.currentUser!.id);
    List<Map<String, String>> myImages = [];

    for (var image in result) {
      final getUrl = supabase.storage
          .from('imageip')
          .getPublicUrl("${supabase.auth.currentUser!.id}/${image.name}");
      myImages.add({'name': image.name, 'url': getUrl});
    }
    return myImages;
  }

  Future getMyFiles() async {
    final List<FileObject> result = await supabase.storage
        .from('imageip')
        .list(path: supabase.auth.currentUser!.id);
    List<Map<String, String>> myImages = [];

    for (var image in result) {
      final getUrl = supabase.storage
          .from('imageip')
          .getPublicUrl("${supabase.auth.currentUser!.id}/${image.name}");
      myImages.add({'name': image.name, 'url': getUrl});
    }
    return myImages;
  }

  Future limpiaima() async {
    _images = null;
    setState(() {});
  }

  Future limpiaima2() async {
    _images2 = null;
    setState(() {});
  }

  Future limpiaima3() async {
    _images3 = null;
    setState(() {});
  }

  Future limpiaima4() async {
    _images4 = null;
    setState(() {});
  }

  Future<File> customCompressed({
    @required File? imagePathToCompress,
    quality = 100,
    percentage = 15,
  }) async {
    var path = await FlutterNativeImage.compressImage(
      imagePathToCompress!.absolute.path,
      quality: qt,
      percentage: per,
    );
    return path;
  }

  Future<File> customCompressed2({
    @required File? imagePathToCompress,
    quality = 100,
    percentage = 15,
  }) async {
    var path = await FlutterNativeImage.compressImage(
      imagePathToCompress!.absolute.path,
      quality: qt,
      percentage: per,
    );
    return path;
  }

  Future<File> customCompressed3({
    @required File? imagePathToCompress,
    quality = 100,
    percentage = 15,
  }) async {
    var path = await FlutterNativeImage.compressImage(
      imagePathToCompress!.absolute.path,
      quality: qt,
      percentage: per,
    );
    return path;
  }

  Future<File> customCompressed4({
    @required File? imagePathToCompress,
    quality = 100,
    percentage = 15,
  }) async {
    var path = await FlutterNativeImage.compressImage(
      imagePathToCompress!.absolute.path,
      quality: qt,
      percentage: per,
    );
    return path;
  }

  Future choiceImage() async {
    var pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      _images = File(pickedFile.path);
      File? imagescom = await customCompressed(imagePathToCompress: _images);
      setState(() {
        isUploading = true;
        _imagescom1 = imagescom;
      });
    }
  }

  Future choiceImage2() async {
    var pickedFile2 = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile2 != null) {
      _images2 = File(pickedFile2.path);
      File? imagescom2 = await customCompressed2(imagePathToCompress: _images2);
      setState(() {
        isUploading2 = true;
        _imagescom2 = imagescom2;
      });
    }
  }

  Future choiceImage3() async {
    var pickedFile3 = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile3 != null) {
      _images3 = File(pickedFile3.path);
      File? imagescom3 = await customCompressed3(imagePathToCompress: _images3);
      setState(() {
        isUploading3 = true;
        _imagescom3 = imagescom3;
      });
    }
  }

  Future choiceImage4() async {
    var pickedFile4 = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile4 != null) {
      _images4 = File(pickedFile4.path);
      File? imagescom4 = await customCompressed4(imagePathToCompress: _images4);
      setState(() {
        isUploading4 = true;
        _imagescom4 = imagescom4;
      });
    }
  }

/////////////tomar foto y subir//////////////
  Future uploadFile() async {
    var pickedFile = _imagescom1;
    try {
      _images = File(pickedFile!.path);
      DateTime now = DateTime.now();
      String fileName = DateFormat('yyyy-MM-dd_HH-mm-ss').format(now) + '.jpg';
      String uploadedUrl = await supabase.storage
          .from('imageip')
          .upload("${supabase.auth.currentUser!.id}/$fileName", _images!);
      setState(() {
        isUploading = false;
        print(uploadedUrl); ////////////ver link de la imagen subida
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Foto cargada correctamente ! "),
        backgroundColor: Colors.green,
      ));
    } catch (e) {
      print("ERRROR : $e");
      setState(() {
        isUploading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Algo ha salido mal"),
        backgroundColor: Colors.red,
      ));
    }
  }

  Future uploadFile2() async {
    var pickedFile2 = _imagescom2;
    try {
      // File file = File(pickedFile.path);
      _images2 = File(pickedFile2!.path);
      // String fileName = pickedFile.name;
      DateTime now = DateTime.now();
      String fileName = DateFormat('yyyy-MM-dd_HH-mm-ss').format(now) + '.jpg';
      String uploadedUrl = await supabase.storage
          .from('imageip')
          .upload("${supabase.auth.currentUser!.id}/$fileName", _images2!);
      setState(() {
        isUploading2 = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Foto cargada correctamente !"),
        backgroundColor: Colors.green,
      ));
    } catch (e) {
      print("ERRROR : $e");
      setState(() {
        isUploading2 = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Algo ha salido mal"),
        backgroundColor: Colors.red,
      ));
    }
  }

  Future uploadFile3() async {
    var pickedFile3 = _imagescom3;
    try {
      // File file = File(pickedFile.path);
      _images3 = File(pickedFile3!.path);
      // String fileName = pickedFile.name;
      DateTime now = DateTime.now();
      String fileName = DateFormat('yyyy-MM-dd_HH-mm-ss').format(now) + '.jpg';
      String uploadedUrl = await supabase.storage
          .from('imageip')
          .upload("${supabase.auth.currentUser!.id}/$fileName", _images3!);
      setState(() {
        isUploading3 = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Foto cargada correctamente !"),
        backgroundColor: Colors.green,
      ));
    } catch (e) {
      print("ERRROR : $e");
      setState(() {
        isUploading3 = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Algo ha salido mal"),
        backgroundColor: Colors.red,
      ));
    }
  }

  Future uploadFile4() async {
    var pickedFile4 = _imagescom4;
    try {
      // File file = File(pickedFile.path);
      _images4 = File(pickedFile4!.path);
      // String fileName = pickedFile.name;
      DateTime now = DateTime.now();
      String fileName = DateFormat('yyyy-MM-dd_HH-mm-ss').format(now) + '.jpg';
      String uploadedUrl = await supabase.storage
          .from('imageip')
          .upload("${supabase.auth.currentUser!.id}/$fileName", _images4!);
      setState(() {
        isUploading4 = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Foto cargada correctamente !"),
        backgroundColor: Colors.green,
      ));
    } catch (e) {
      print("ERRROR : $e");
      setState(() {
        isUploading4 = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Algo ha salido mal"),
        backgroundColor: Colors.red,
      ));
    }
  }

  void disableButton() {
    setState(() {
      buttonDisabled = true;
    });
  }

  void disableButton2() {
    setState(() {
      buttonDisabled2 = true;
    });
  }

  void disableButton3() {
    setState(() {
      buttonDisabled3 = true;
    });
  }

  void disableButton4() {
    setState(() {
      buttonDisabled4 = true;
    });
  }

  void disableButton5() {
    setState(() {
      buttonDisabled5 = true;
    });
  }

  //////////////////////////////
  Future<void> deleteImage(String imageName) async {
    try {
      await supabase.storage
          .from('imageip')
          .remove([supabase.auth.currentUser!.id + "/" + imageName]);
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: const Text("Algo ha salido mal !")));
    }
  }

  @override
  void initState() {
    route.Provider.of<AttendanceService>(context, listen: false)
        .getTodayAttendance();

    super.initState();
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
          Switch(
              value: AdaptiveTheme.of(context).mode == AdaptiveThemeMode.light,
              onChanged: (bool value) {
                if (value) {
                  AdaptiveTheme.of(context).setLight();
                } else {
                  AdaptiveTheme.of(context).setDark();
                }
              })
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            route.Consumer<DbService>(builder: (context, dbServie, child) {
              return FutureBuilder(
                  future: dbServie.getUserData(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      UserModel user = snapshot.data!;
                      return Container(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          user.name != '' ? user.name : "#${user.employeeId}",
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      );
                    }
                    return const SizedBox(
                      width: 60,
                      child: LinearProgressIndicator(),
                    );
                  });
            }),
            const SizedBox(
              child: Divider(
                thickness: 1,
              ),
            ),
            route.Consumer<DbService>(builder: (context, dbServie, child) {
              return FutureBuilder(
                  future: dbServie.getTodaydep(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      DepartmentModel user2 = snapshot.data!;
                      return Container(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          user2.title != '' ? user2.title.toString() : "4 ",
                          style: const TextStyle(fontSize: 15),
                        ),
                      );
                    }
                    return const SizedBox(
                      width: 60,
                      child: LinearProgressIndicator(),
                    );
                  });
            }), //
            const SizedBox(
              child: Divider(
                thickness: 1,
              ),
            ),
            ///////////////fecha/////////////////////

            StreamBuilder(
                stream: Stream.periodic(const Duration(seconds: 1)),
                builder: (context, snapshot) {
                  return Container(
                    alignment: Alignment.center,
                    child: Text(
                      DateFormat("HH:mm:ss").format(DateTime.now()),
                      style: const TextStyle(fontSize: 35),
                    ),
                  );
                }),
            Container(
              alignment: Alignment.center,
              child: Text(
                DateFormat("dd MMMM yyyy").format(DateTime.now()),
                style: const TextStyle(fontSize: 15),
              ),
            ),
            const SizedBox(
              width: 90,
              child: Divider(
                thickness: 1,
              ),
            ),
            //////
            Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.only(top: 7),
            ),
            ///////////////hora/////////////////////
            Container(
              margin: EdgeInsets.only(top: 5, bottom: 7),
              height: 300,
              decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.light
                      ? Colors.white
                      //  color: Colors.white,
                      : Color.fromARGB(255, 43, 41, 41),
                  boxShadow: [
                    BoxShadow(
                        color: Color.fromARGB(110, 18, 148, 255),
                        blurRadius: 10,
                        offset: Offset(2, 2)),
                  ],
                  borderRadius: BorderRadius.all(Radius.circular(20))),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          "Ingreso",
                          style: TextStyle(
                            fontSize: 20, /*color: Colors.black5*/
                          ),
                        ),
                        const SizedBox(
                          width: 80,
                          child: Divider(),
                        ),
                        Text(
                          attendanceService.attendanceModel?.checkIn ?? '--/--',
                          style: const TextStyle(fontSize: 25),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            (_images == null &&
                                    attendanceService
                                            .attendanceModel?.checkIn ==
                                        null)
                                ? IconButton(
                                    icon: Icon(Icons.add_a_photo),
                                    onPressed: () {
                                      choiceImage();
                                      disableButton5();
                                    })
                                : AbsorbPointer(
                                    absorbing: buttonDisabled5,
                                    child: IconButton(
                                        icon: Icon(Icons.add_a_photo),
                                        onPressed: () {
                                          choiceImage();
                                          disableButton5();
                                        }),
                                  ),
                            attendanceService.attendanceModel?.checkIn == null
                                ? IconButton(
                                    icon: Icon(Icons.delete),
                                    color: Colors.red,
                                    onPressed: () {
                                      limpiaima();
                                      // disableButton();
                                    })
                                : AbsorbPointer(
                                    absorbing: buttonDisabled5,
                                    child: IconButton(
                                        icon: Icon(Icons.delete),
                                        color: Colors.red,
                                        onPressed: () {
                                          limpiaima();
                                          disableButton5();
                                        }),
                                  ),
                          ],
                        ),
                        Container(
                            child: _images == null
                                ? const Text('Ninguna Imagen \n  para mostrar')
                                : Image.file(
                                    _images!,
                                    height: 130,
                                  )),
                      ],
                    )),
                    Expanded(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          "Salida",
                          style: TextStyle(
                              fontSize: 20 /*, color: Colors.black54*/),
                        ),
                        const SizedBox(
                          width: 80,
                          child: Divider(),
                        ),
                        Text(
                          attendanceService.attendanceModel?.checkOut ??
                              '--/--',
                          style: const TextStyle(fontSize: 25),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            (_images2 == null &&
                                        attendanceService
                                                .attendanceModel?.checkOut ==
                                            null) &&
                                    attendanceService
                                            .attendanceModel?.checkIn !=
                                        null
                                ? IconButton(
                                    icon: Icon(Icons.add_a_photo),
                                    onPressed: () {
                                      choiceImage2();
                                      disableButton2();
                                    })
                                : AbsorbPointer(
                                    absorbing: buttonDisabled2,
                                    child: IconButton(
                                        icon: Icon(Icons.add_a_photo),
                                        onPressed: () {
                                          choiceImage2();
                                          disableButton2();
                                        })),
                            attendanceService.attendanceModel?.checkOut == null
                                ? IconButton(
                                    icon: Icon(Icons.delete),
                                    color: Colors.red,
                                    onPressed: () {
                                      limpiaima2();
                                      // disableButton();
                                    })
                                : AbsorbPointer(
                                    absorbing: buttonDisabled2,
                                    child: IconButton(
                                        icon: Icon(Icons.delete),
                                        color: Colors.red,
                                        onPressed: () {
                                          limpiaima2();
                                          disableButton2();
                                        }),
                                  ),
                          ],
                        ),
                        Container(
                            child: _images2 == null
                                ? Text('Ninguna Imagen \n  para mostrar')
                                : Image.file(
                                    _images2!,
                                    height: 130,
                                  )),
                      ],
                    )),
                  ]),
            ),
            Container(
              margin: const EdgeInsets.only(top: 5),
              child: Builder(builder: (context) {
                return SlideAction(
                  text: (attendanceService.attendanceModel?.checkIn != null &&
                          attendanceService.attendanceModel?.checkOut != null)
                      ? "Registro Exitoso. Gracias"
                      : (attendanceService.attendanceModel?.checkIn == null)
                          ? "Registrar el ingreso"
                          : "Registrar la salida",
                  //alignment: Alignment.topCenter,

                  textStyle: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).brightness == Brightness.light
                          ? Colors.black
                          : Colors.white),
                  outerColor: Theme.of(context).brightness == Brightness.light
                      ? Colors.white
                      : Color(0xFF2B2929),
                  innerColor: Colors.blue,
                  key: key,
                  onSubmit: () async {
                    if (attendanceService.attendanceModel?.checkIn != null &&
                        attendanceService.attendanceModel?.checkOut != null) {
                      QuickAlert.show(
                        context: context,
                        type: QuickAlertType.warning,
                        title: ' ',
                        text: 'Registro Completado',
                      );
                    } else if (attendanceService.attendanceModel?.checkIn ==
                            null &&
                        _images != null) {
                      uploadFile();
                      await attendanceService.markAttendance(context);
                    } else if (attendanceService.attendanceModel?.checkIn ==
                        null) {
                      QuickAlert.show(
                        context: context,
                        type: QuickAlertType.warning,
                        title: 'Suba',
                        text: 'una foto por favor',
                      );
                    } else if (_images2 != null) {
                      uploadFile2();
                      await attendanceService.markAttendance(context);
                    } else {
                      QuickAlert.show(
                        context: context,
                        type: QuickAlertType.warning,
                        title: 'Suba',
                        text: 'una foto por favor',
                      );
                    }
                    key.currentState!.reset();
                  },
                  /*onSubmit: () async {
                    if (attendanceService.attendanceModel?.checkIn != null &&
                        attendanceService.attendanceModel?.checkOut != null) {
                      QuickAlert.show(
                          context: context,
                          type: QuickAlertType.warning,
                          title: ' ',
                          text: 'Registro Completado');
                    } else {
                      (attendanceService.attendanceModel?.checkIn == null
                          ? (_images != null
                          ? (await attendanceService
                          .markAttendance(context))
                          : QuickAlert.show(
                          context: context,
                          type: QuickAlertType.warning,
                          title: 'Suba',
                          text: 'una foto por favor'))
                          : _images2 != null
                          ? (await attendanceService
                          .markAttendance(context))
                          : QuickAlert.show(
                          context: context,
                          type: QuickAlertType.warning,
                          title: 'Suba',
                          text: 'una foto por favor'));
                      attendanceService.attendanceModel?.checkIn == null
                          ? (_images != null
                          ? uploadFile()
                          : _images2 != null
                          ? uploadFile2()
                          : print("mal1"))
                          : _images2 != null
                          ? uploadFile2()
                          : print("mal2");
                    }
                    key.currentState!.reset();
                  },*/
                );
              }),
            ),
            Container(
              height: 10,
            ),
            /*  Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.only(top: 10),
              child: const Text(
                "Registro de la tarde",
                style: TextStyle(fontSize: 18),
              ),
            ),*/
            Container(
              margin: EdgeInsets.only(top: 5, bottom: 10),
              height: 300,
              decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.light
                      ? Colors.white
                      //  color: Colors.white,
                      : Color.fromARGB(255, 43, 41, 41),
                  boxShadow: [
                    BoxShadow(
                        color: Color.fromARGB(110, 18, 148, 255),
                        blurRadius: 10,
                        offset: Offset(2, 2)),
                  ],
                  borderRadius: BorderRadius.all(Radius.circular(20))),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          "Ingreso",
                          style: TextStyle(
                            fontSize: 20, /*color: Colors.black5*/
                          ),
                        ),
                        const SizedBox(
                          width: 80,
                          child: Divider(),
                        ),
                        Text(
                          attendanceService.attendanceModel?.checkIn2 ??
                              '--/--',
                          style: const TextStyle(fontSize: 25),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            (_images3 == null &&
                                        attendanceService
                                                .attendanceModel?.checkIn2 ==
                                            null) &&
                                    attendanceService
                                            .attendanceModel?.checkOut !=
                                        null
                                ? IconButton(
                                    icon: Icon(Icons.add_a_photo),
                                    onPressed: () {
                                      choiceImage3();
                                      disableButton3();
                                    })
                                : AbsorbPointer(
                                    absorbing: buttonDisabled3,
                                    child: IconButton(
                                        icon: Icon(Icons.add_a_photo),
                                        onPressed: () {
                                          choiceImage3();
                                          disableButton3();
                                        }),
                                  ),
                            attendanceService.attendanceModel?.checkIn2 == null
                                ? IconButton(
                                    icon: Icon(Icons.delete),
                                    color: Colors.red,
                                    onPressed: () {
                                      limpiaima3();
                                      // disableButton();
                                    })
                                : AbsorbPointer(
                                    absorbing: buttonDisabled3,
                                    child: IconButton(
                                        icon: Icon(Icons.delete),
                                        color: Colors.red,
                                        onPressed: () {
                                          limpiaima3();
                                          disableButton3();
                                        }),
                                  ),
                          ],
                        ),
                        Container(
                            child: _images3 == null
                                ? const Text('Ninguna Imagen \n  para mostrar')
                                : Image.file(
                                    _images3!,
                                    height: 130,
                                  )),
                      ],
                    )),
                    Expanded(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          "Salida",
                          style: TextStyle(
                              fontSize: 20 /*, color: Colors.black54*/),
                        ),
                        const SizedBox(
                          width: 80,
                          child: Divider(),
                        ),
                        Text(
                          attendanceService.attendanceModel?.checkOut2 ??
                              '--/--',
                          style: const TextStyle(fontSize: 25),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            (_images4 == null &&
                                        attendanceService
                                                .attendanceModel?.checkOut2 ==
                                            null) &&
                                    attendanceService
                                            .attendanceModel?.checkIn2 !=
                                        null
                                ? IconButton(
                                    icon: Icon(Icons.add_a_photo),
                                    onPressed: () {
                                      choiceImage4();
                                      disableButton4();
                                    })
                                : AbsorbPointer(
                                    absorbing: buttonDisabled4,
                                    child: IconButton(
                                        icon: Icon(Icons.add_a_photo),
                                        onPressed: () {
                                          choiceImage4();
                                          disableButton4();
                                        }),
                                  ),
                            attendanceService.attendanceModel?.checkOut2 == null
                                ? IconButton(
                                    icon: Icon(Icons.delete),
                                    color: Colors.red,
                                    onPressed: () {
                                      limpiaima4();
                                      // disableButton2();
                                    })
                                : AbsorbPointer(
                                    absorbing: buttonDisabled4,
                                    child: IconButton(
                                        icon: Icon(Icons.delete),
                                        color: Colors.red,
                                        onPressed: () {
                                          limpiaima4();
                                          disableButton4();
                                        }),
                                  ),
                          ],
                        ),
                        Container(
                            child: _images4 == null
                                ? Text('Ninguna Imagen \n para mostrar')
                                : Image.file(
                                    _images4!,
                                    height: 130,
                                  )),
                      ],
                    )),
                  ]),
            ),
            ///////////////////////////////////fotos//////////////
            Container(
              margin: const EdgeInsets.only(top: 5),
              child: Builder(builder: (context) {
                return SlideAction(
                  text: (attendanceService.attendanceModel?.checkIn2 != null &&
                          attendanceService.attendanceModel?.checkOut2 != null)
                      ? "Registro Exitoso Gracias"
                      : (attendanceService.attendanceModel?.checkIn2 == null)
                          ? "Registrar el ingreso"
                          : "Registrar la salida",
                  //alignment: Alignment.topCenter,

                  textStyle: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).brightness == Brightness.light
                          ? Colors.black
                          : Colors.white),
                  outerColor: Theme.of(context).brightness == Brightness.light
                      ? Colors.white
                      : Color(0xFF2B2929),
                  innerColor: Colors.blue,
                  key: key2,
                  onSubmit: () async {
                    if (attendanceService.attendanceModel?.checkIn2 != null &&
                        attendanceService.attendanceModel?.checkOut2 != null) {
                      QuickAlert.show(
                        context: context,
                        type: QuickAlertType.warning,
                        title: ' ',
                        text: 'Registro Completado',
                      );
                    } else if (attendanceService.attendanceModel?.checkIn2 ==
                        null &&
                        _images3 != null) {
                      uploadFile3();
                      await attendanceService.markAttendance2(context);
                    } else if (attendanceService.attendanceModel?.checkIn2 ==
                        null) {
                      QuickAlert.show(
                        context: context,
                        type: QuickAlertType.warning,
                        title: 'Suba',
                        text: 'una foto por favor',
                      );
                    } else if (_images4 != null) {
                      uploadFile4();
                      await attendanceService.markAttendance2(context);

                    } else {
                      QuickAlert.show(
                        context: context,
                        type: QuickAlertType.warning,
                        title: 'Suba',
                        text: 'una foto por favor',
                      );
                    }
                    key2.currentState!.reset();
                  },
                 /* onSubmit: () async {
                     if (attendanceService.attendanceModel?.checkIn2 != null &&
                        attendanceService.attendanceModel?.checkOut2 != null) {
                      QuickAlert.show(
                          context: context,
                          type: QuickAlertType.warning,
                          title: 'Suba',
                          text: 'una foto por favor');
                    } else {
                      (attendanceService.attendanceModel?.checkIn2 == null
                          ? (_images3 != null
                              ? (await attendanceService
                                  .markAttendance2(context))
                              : QuickAlert.show(
                                  context: context,
                                  type: QuickAlertType.warning,
                                  title: 'Suba',
                                  text: 'una foto por favor'))
                          : _images4 != null
                              ? (await attendanceService
                                  .markAttendance2(context))
                              : QuickAlert.show(
                                  context: context,
                                  type: QuickAlertType.warning,
                                  title: 'Suba ',
                                  text: 'una foto por favor'));
                      attendanceService.attendanceModel?.checkIn2 == null
                          ? (_images3 != null
                              ? uploadFile3()
                              : _images4 != null
                                  ? uploadFile4()
                                  : print("mal11"))
                          : _images4 != null
                              ? uploadFile4()
                              : print("mal22");
                    }
                    key2.currentState!.reset();
                  },*/
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

// flutter custom card button
Card buildButton({
  required onTap,
  required title,
  required text,
  required leadingIcon,
}) {
  return Card(
    shape: const StadiumBorder(),
    margin: const EdgeInsets.symmetric(
      horizontal: 20,
    ),
    clipBehavior: Clip.antiAlias,
    elevation: 1,
    child: ListTile(
      onTap: onTap,
      leading: leadingIcon,
      title: Text(title ?? ""),
      subtitle: Text(text ?? ""),
      trailing: const Icon(
        Icons.keyboard_arrow_right_rounded,
      ),
    ),
  );
}
