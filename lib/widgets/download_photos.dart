import 'package:fluent_ui/fluent_ui.dart';
import 'package:idcard_maker_frontend/services/remote_services.dart';
import '../models/student_model.dart';

class DownloadPhotos extends StatefulWidget {
  final int schoolId;
  final List<Photo> photos;
  const DownloadPhotos({Key? key, required this.schoolId, required this.photos})
      : super(key: key);

  @override
  State<DownloadPhotos> createState() => _DownloadPhotosState();
}

class _DownloadPhotosState extends State<DownloadPhotos> {
  RemoteServices _remoteServices = RemoteServices();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: 300,
        // height: 200,
        child: Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Download Student Data",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              DropDownButton(
                title: Text('Select Photo Column'),
                items: List<MenuFlyoutItem>.generate(
                  widget.photos.length,
                  (index) => MenuFlyoutItem(
                    text: Text(widget.photos[index].field),
                    onPressed: () {},
                  ),
                ),
              ),
              // Button(
              //   child: Text("Download"),
              //   onPressed: () {
              //     _remoteServices
              //         .generateExcel(
              //       schoolId,
              //       'all',
              //       'all',
              //     );
              //   },
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
