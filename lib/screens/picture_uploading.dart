import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class UploadPicturesTasks extends StatefulWidget {
  final List<AssetEntity> images;
  UploadPicturesTasks({Key? key, required this.images}) : super(key: key);

  @override
  State<UploadPicturesTasks> createState() => _UploadPicturesTasksState();
}

class _UploadPicturesTasksState extends State<UploadPicturesTasks> {
  List<UploadTask> _uploadTasks = [];
  Reference ref = FirebaseStorage.instance.ref().child('weight_img');
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Загрузка изображений"),),
      body: ListView.builder(
              itemCount: _uploadTasks.length,
              itemBuilder: (context, index) => UploadTaskListTile(
                task: _uploadTasks[index],
                onDismissed: () => _removeTaskAtIndex(index),
                onDownloadLink: () async {
                  return _downloadLink(_uploadTasks[index].snapshot.ref);
                },
                onDownload: (){},
              ),
            ),
    );
  }

  Future<UploadTask?> uploadFile(File? file) async {
    if (file == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No file was selected'),
        ),
      );

      return null;
    }

    UploadTask uploadTask;

    final metadata = SettableMetadata(
      contentType: 'image/jpeg',
      customMetadata: {'picked-file-path': file.path},
    );

    uploadTask = ref.putFile(File(file.path), metadata);

    return Future.value(uploadTask);
  }

  void _removeTaskAtIndex(int index) {
    setState(() {
      _uploadTasks = _uploadTasks..removeAt(index);
    });
  }

 

  Future<void> _downloadLink(Reference ref) async {
    final link = await ref.getDownloadURL();

    await Clipboard.setData(
      ClipboardData(
        text: link,
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Success!\n Copied download URL to Clipboard!',
        ),
      ),
    );
  }
}


class UploadTaskListTile extends StatelessWidget {
  // ignore: public_member_api_docs
  const UploadTaskListTile({
    Key? key,
    required this.task,
    required this.onDismissed,
    required this.onDownload,
    required this.onDownloadLink,
  }) : super(key: key);

  /// The [UploadTask].
  final UploadTask /*!*/ task;

  /// Triggered when the user dismisses the task from the list.
  final VoidCallback /*!*/ onDismissed;

  /// Triggered when the user presses the download button on a completed upload task.
  final VoidCallback /*!*/ onDownload;

  /// Triggered when the user presses the "link" button on a completed upload task.
  final VoidCallback /*!*/ onDownloadLink;

  /// Displays the current transferred bytes of the task.
  String _bytesTransferred(TaskSnapshot snapshot) {
    return '${snapshot.bytesTransferred}/${snapshot.totalBytes}';
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<TaskSnapshot>(
      stream: task.snapshotEvents,
      builder: (
        BuildContext context,
        AsyncSnapshot<TaskSnapshot> asyncSnapshot,
      ) {
        Widget subtitle = const Text('---');
        TaskSnapshot? snapshot = asyncSnapshot.data;
        TaskState? state = snapshot?.state;

        if (asyncSnapshot.hasError) {
          if (asyncSnapshot.error is FirebaseException &&
              // ignore: cast_nullable_to_non_nullable
              (asyncSnapshot.error as FirebaseException).code == 'canceled') {
            subtitle = const Text('Upload canceled.');
          } else {
            // ignore: avoid_print
            print(asyncSnapshot.error);
            subtitle = const Text('Something went wrong.');
          }
        } else if (snapshot != null) {
          subtitle = Text('$state: ${_bytesTransferred(snapshot)} bytes sent');
        }

        return Dismissible(
          key: Key(task.hashCode.toString()),
          onDismissed: ($) => onDismissed(),
          child: ListTile(
            title: Text('Upload Task #${task.hashCode}'),
            subtitle: subtitle,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (state == TaskState.running)
                  IconButton(
                    icon: const Icon(Icons.pause),
                    onPressed: task.pause,
                  ),
                if (state == TaskState.running)
                  IconButton(
                    icon: const Icon(Icons.cancel),
                    onPressed: task.cancel,
                  ),
                if (state == TaskState.paused)
                  IconButton(
                    icon: const Icon(Icons.file_upload),
                    onPressed: task.resume,
                  ),
                if (state == TaskState.success)
                  IconButton(
                    icon: const Icon(Icons.file_download),
                    onPressed: onDownload,
                  ),
                if (state == TaskState.success)
                  IconButton(
                    icon: const Icon(Icons.link),
                    onPressed: onDownloadLink,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}