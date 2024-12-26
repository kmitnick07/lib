import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:prestige_prenew_frontend/components/customs/custom_dialogs.dart';
import 'package:prestige_prenew_frontend/components/extensions/extensions.dart';
import 'package:prestige_prenew_frontend/config/iis_method.dart';
import 'package:prestige_prenew_frontend/utils/aws_service/file_data_model.dart';
import 'package:uuid/uuid.dart';

class CustomFileDragArea extends StatelessWidget {
  const CustomFileDragArea({
    super.key,
    this.onFilePicked,
    this.child,
    this.fileTypes,
    this.disableMultipleFiles = false,
  });

  final Widget? child;
  final Function(List<FilesDataModel> files)? onFilePicked;
  final List? fileTypes;
  final bool disableMultipleFiles;

  @override
  Widget build(BuildContext context) {
    return DropTarget(
        onDragDone: (details) async {
          List<FilesDataModel> fileModelList = [];
          for (var file in details.files) {
            var uuid = const Uuid();
            if (fileTypes.isNullOrEmpty || fileTypes!.contains(file.name.split('.').last)) {
              fileModelList.add(await IISMethods().compressImage(FilesDataModel(
                name: file.name,
                bytes: await file.readAsBytes(),
                extension: file.name.split('.').last,
                path: !kIsWeb ? file.path : null,
                size: (await file.readAsBytes()).length,
                tempId: uuid.v4(),
              )));
              if (disableMultipleFiles) {
                break;
              }
            } else {
              showError('Only ${fileTypes?.join(', ')} Supported');
            }
          }
          if (onFilePicked != null) {
            onFilePicked!(fileModelList);
          }
        },
        child: InkWell(
          onTap: () async {
            List<FilesDataModel> fileModelList = [];
            if (disableMultipleFiles) {
              fileModelList = await IISMethods().pickSingleFile(fileType: fileTypes);
            } else {
              fileModelList = await IISMethods().pickMultipleFiles(fileType: fileTypes);
            }
            if (onFilePicked != null) {
              onFilePicked!(fileModelList);
            }
          },
          child: child,
        ));
  }
}
