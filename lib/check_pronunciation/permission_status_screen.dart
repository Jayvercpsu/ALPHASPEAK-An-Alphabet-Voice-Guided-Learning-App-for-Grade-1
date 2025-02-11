import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionStatusScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Permission Status'),
        backgroundColor: Colors.blueAccent,
      ),
      body: FutureBuilder<Map<Permission, PermissionStatus>>(
        future: _fetchPermissionStatuses(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final permissions = snapshot.data!;
            return ListView(
              padding: EdgeInsets.all(16.0),
              children: permissions.entries.map((entry) {
                final permission = entry.key;
                final status = entry.value;
                return ListTile(
                  leading: Icon(
                    status == PermissionStatus.granted
                        ? Icons.check_circle
                        : Icons.error,
                    color: status == PermissionStatus.granted
                        ? Colors.green
                        : Colors.red,
                  ),
                  title: Text(permission.toString().split('.').last),
                  subtitle: Text(_statusText(status)),
                );
              }).toList(),
            );
          } else {
            return Center(child: Text('No permissions available.'));
          }
        },
      ),
    );
  }

  Future<Map<Permission, PermissionStatus>> _fetchPermissionStatuses() async {
    final permissions = [
      Permission.microphone,
      Permission.camera,
      Permission.location,
      Permission.storage,
    ];
    return await permissions.request();
  }

  String _statusText(PermissionStatus status) {
    switch (status) {
      case PermissionStatus.granted:
        return 'Permission Granted';
      case PermissionStatus.denied:
        return 'Permission Denied';
      case PermissionStatus.permanentlyDenied:
        return 'Permission Permanently Denied';
      case PermissionStatus.restricted:
        return 'Permission Restricted';
      case PermissionStatus.limited:
        return 'Permission Limited';
      default:
        return 'Unknown';
    }
  }
}
