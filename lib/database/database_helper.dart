import 'dart:async';
import 'dart:convert';
import 'package:cskmemp/app_config.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:http/http.dart' as http;

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper.internal();

  factory DatabaseHelper() => _instance;

  static late Database _database;

  DatabaseHelper.internal();

  Future<Database> get database async {
    return _database;
  }

  Future<Database> initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'cskmemp.db');

    _database = await openDatabase(path, version: 1);

    return _database;
  }

  // function to check if the database is open
  Future<bool> isDatabaseOpen() async {
    final db = await database;
    if (db.isOpen) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> _createTableTasks(Database db, int version) async {
    await db.execute(
        'CREATE TABLE IF NOT EXISTS PendingTasks(taskId INTEGER PRIMARY KEY, taskDescription TEXT, creationDate DATE, assignedBy TEXT)');
    await db.execute(
        'CREATE TABLE IF NOT EXISTS AssignedTasks(taskId INTEGER PRIMARY KEY, taskDescription TEXT, creationDate DATE, assignedTo TEXT)');
    await db.execute(
        'CREATE TABLE IF NOT EXISTS CompletedTasks(taskId INTEGER PRIMARY KEY, taskDescription TEXT, creationDate DATE, assignedBy TEXT)');
  }

  Future<int> insertDataToPendingTasks({
    required taskId,
    required taskDescription,
    required creationDate,
    required assignedBy,
  }) async {
    final db = await database;
    final values = {
      'taskId': taskId,
      'taskDescription': taskDescription,
      'creationDate': creationDate,
      'assignedBy': assignedBy,
    };

    return await db.insert('PendingTasks', values);
  }

  Future<int> insertDataToAssignedTasks({
    required taskId,
    required taskDescription,
    required creationDate,
    required assignedTo,
  }) async {
    final db = await database;
    final values = {
      'taskId': taskId,
      'taskDescription': taskDescription,
      'creationDate': creationDate,
      'assignedTo': assignedTo,
    };

    return await db.insert('AssignedTasks', values);
  }

  Future<int> insertDataToCompletedTasks({
    required taskId,
    required taskDescription,
    required creationDate,
    required assignedBy,
  }) async {
    final db = await database;
    final values = {
      'taskId': taskId,
      'taskDescription': taskDescription,
      'creationDate': creationDate,
      'assignedBy': assignedBy,
    };

    return await db.insert('CompletedTasks', values);
  }

  //delete data from PendingTasks table
  Future<int> deleteDataFromPendingTasks({required taskId}) async {
    final db = await database;
    return await db.delete(
      'PendingTasks',
      where: 'taskId = ?',
      whereArgs: [taskId],
    );
  }

  //delete data from AssignedTasks table
  Future<int> deleteDataFromAssignedTasks({required taskId}) async {
    final db = await database;
    return await db.delete(
      'AssignedTasks',
      where: 'taskId = ?',
      whereArgs: [taskId],
    );
  }

  //delete data from CompletedTasks table
  Future<int> deleteDataFromCompletedTasks({required taskId}) async {
    final db = await database;
    return await db.delete(
      'CompletedTasks',
      where: 'taskId = ?',
      whereArgs: [taskId],
    );
  }

  //fetch data from PendingTasks table in the ascending order of taskId
  Future<List<Map<String, dynamic>>> getDataFromPendingTasks() async {
    final db = await database;
    return await db.query('PendingTasks', orderBy: 'taskId ASC');
  }

  //fetch data from AssignedTasks table in the ascending order of taskId
  Future<List<Map<String, dynamic>>> getDataFromAssignedTasks() async {
    final db = await database;
    return await db.query('AssignedTasks', orderBy: 'taskId ASC');
  }

  //fetch data from CompletedTasks table in the ascending order of taskId
  Future<List<Map<String, dynamic>>> getDataFromCompletedTasks() async {
    final db = await database;
    return await db.query('CompletedTasks', orderBy: 'taskId ASC');
  }

  //fetch data in json format from server using http package and store it in PendingTasks table
  Future<void> syncDataToPendingTasks() async {
    final db = await database;
    final dataFromServer = await fetchPendingTasksDataFromServer();

    await db.transaction((txn) async {
      final batch = txn.batch();

      for (var data in dataFromServer) {
        //insert data to PendingTasks table where taskId is not exists in the table
        batch.rawInsert(
            'INSERT OR IGNORE INTO PendingTasks(taskId, taskDescription, creationDate, assignedBy) VALUES(?, ?, ?, ?)',
            [
              data['taskId'],
              data['description'],
              data['date'],
              data['assignedBy'],
            ]);
      }
      await batch.commit();
    });
  }

  Future<List<Map<String, dynamic>>> fetchPendingTasksDataFromServer() async {
    var userNo = await AppConfig().getUserNo().then((String result) => result);
    var response = await http.post(
      Uri.parse('https://www.cskm.com/schoolexpert/cskmemp/fetchTasks.php'),
      body: {
        'secretKey': AppConfig.secreetKey,
        'userNo': userNo,
        'taskType': 'My',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch data from server');
    }
  }

  Future<void> syncDataToAssignedTasks() async {
    final db = await database;
    final dataFromServer = await fetchAssignedTasksDataFromServer();

    await db.transaction((txn) async {
      final batch = txn.batch();

      for (var data in dataFromServer) {
        //insert data to AssignedTasks table where taskId is not exists in the table
        batch.rawInsert(
            'INSERT OR IGNORE INTO AssignedTasks(taskId, taskDescription, creationDate, assignedTo) VALUES(?, ?, ?, ?)',
            [
              data['taskId'],
              data['description'],
              data['date'],
              data['assignedTo'],
            ]);
      }
      await batch.commit();
    });
  }

  Future<List<Map<String, dynamic>>> fetchAssignedTasksDataFromServer() async {
    var userNo = await AppConfig().getUserNo().then((String result) => result);
    var response = await http.post(
      Uri.parse('https://www.cskm.com/schoolexpert/cskmemp/fetchTasks.php'),
      body: {
        'secretKey': AppConfig.secreetKey,
        'userNo': userNo,
        'taskType': 'Assigned',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch data from server');
    }
  }

  Future<void> syncDataToCompletedTasks() async {
    final db = await database;
    final dataFromServer = await fetchCompletedTasksDataFromServer();

    await db.transaction((txn) async {
      final batch = txn.batch();

      for (var data in dataFromServer) {
        //insert data to CompletedTasks table where taskId is not exists in the table
        batch.rawInsert(
            'INSERT OR IGNORE INTO CompletedTasks(taskId, taskDescription, creationDate, assignedBy) VALUES(?, ?, ?, ?)',
            [
              data['taskId'],
              data['description'],
              data['date'],
              data['assignedBy'],
            ]);
      }
      await batch.commit();
    });
  }

  Future<List<Map<String, dynamic>>> fetchCompletedTasksDataFromServer() async {
    var userNo = await AppConfig().getUserNo().then((String result) => result);
    var response = await http.post(
      Uri.parse('https://www.cskm.com/schoolexpert/cskmemp/fetchTasks.php'),
      body: {
        'secretKey': AppConfig.secreetKey,
        'userNo': userNo,
        'taskType': 'Completed',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch data from server');
    }
  }

  Future<void> createTableEmpNotifications(
    Database db,
    int version,
  ) async {
    // Check if the table already exists
    var tableExists = await db.query(
      'sqlite_master',
      columns: ['name'],
      where: 'type = ? AND name = ?',
      whereArgs: ['table', 'empNotifications'],
    );

    if (tableExists.isEmpty) {
      // Table does not exist, create it
      await db.execute('''
      CREATE TABLE empNotifications (
        id INTEGER PRIMARY KEY,
        userno TEXT,
        notification TEXT,
        notificationDate TEXT,
        notificationStatus TEXT
      )
    ''');
    }
  }

  //fetch data in json format from server using http package and store it in PendingTasks table
  Future<void> syncDataToEmpNotifications() async {
    final db = await database;
    // fetch the max(id) from empNotifications table
    final maxId = Sqflite.firstIntValue(await db.rawQuery(
        'SELECT MAX(id) FROM empNotifications where userno = ?',
        [AppConfig.globalUserNo]));

    // if maxId is null, then set it to 0
    final maxIdNotNull = maxId == null ? 0 : maxId;

    final dataFromServer =
        await fetchEmpNotificationsDataFromServer(maxIdNotNull);
    //print(dataFromServer);
    await db.transaction((txn) async {
      final batch = txn.batch();

      for (var data in dataFromServer) {
        //insert data to empNotifications table where taskId is not exists in the table
        batch.rawInsert(
            'INSERT OR IGNORE INTO empNotifications(id, userno, notification, notificationDate, notificationStatus) VALUES(?, ?, ?, ?, ?)',
            [
              data['id'],
              data['userno'],
              data['notification'],
              data['notificationDate'],
              data['notificationStatus'],
            ]);
      }
      await batch.commit();
      //print('Data synced to empNotifications table');
    });
  }

  Future<List<dynamic>> fetchEmpNotificationsDataFromServer(maxId) async {
    var response = await http.post(
      Uri.parse(
          'https://www.cskm.com/schoolexpert/cskmemp/sync_notifications.php'),
      body: {
        'secretKey': AppConfig.secreetKey,
        'userno': AppConfig.globalUserNo,
        'lastid': maxId.toString(),
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final data2 = data['notifications'];
      // print the datatype of data2
      //print(data2.runtimeType);
      //print(data2);
      return data2;
    } else {
      throw Exception('Failed to fetch data from server');
    }
  }

  //fetch data from empNotifications table in the ascending order of id
  Future<List<Map<String, dynamic>>> getDataFromEmpNotifications() async {
    final db = await database;
    return await db.query(
      'empNotifications',
      where: 'userno = ?',
      whereArgs: [AppConfig.globalUserNo],
      orderBy: 'id DESC',
    );
  }

  // update notification status to R in the database
  Future<void> updateNotificationStatusToR() async {
    final db = await database;
    await db.rawUpdate(
        'UPDATE empNotifications SET notificationStatus = ? WHERE userno = ?',
        ['R', AppConfig.globalUserNo]);
  }

  // delete all data from empNotifications table
  Future<void> deleteAllDataFromEmpNotifications() async {
    final db = await database;
    await db.rawDelete('DELETE FROM empNotifications');
  }

  Future<void> createTablePhotoGallery(
    Database db,
    int version,
  ) async {
    // Check if the table already exists
    var tableExists = await db.query(
      'sqlite_master',
      columns: ['name'],
      where: 'type = ? AND name = ?',
      whereArgs: ['table', 'photogallery'],
    );

    if (tableExists.isEmpty) {
      // Table does not exist, create it
      await db.execute('''
        CREATE TABLE photogallery (
          photoId INTEGER PRIMARY KEY,
          heading TEXT,
          photoDt TEXT,
          link TEXT,
          sno INTEGER
        )
      ''');
    }
  }

  Future<void> syncDataToPhotoGallery() async {
    final db = await database;

    // fetch max(photoId) from photogallery table
    final maxPhotoId = Sqflite.firstIntValue(
        await db.rawQuery('SELECT MAX(photoId) FROM photogallery'));
    // if maxPhotoId is null, then set it to 0 in maxPhotoIdNotNull
    final maxPhotoIdNotNull = maxPhotoId == null ? 0 : maxPhotoId;

    final dataFromServer =
        await fetchPhotoGalleryDataFromServer(maxPhotoIdNotNull);

    await db.transaction((txn) async {
      final batch = txn.batch();

      for (var data in dataFromServer) {
        batch.rawInsert(
          'INSERT OR IGNORE INTO photogallery(photoId, heading, photoDt, link, sno) VALUES(?, ?, ?, ?, ?)',
          [
            data['photoId'],
            data['heading'],
            data['photoDt'],
            data['link'],
            data['sno'],
          ],
        );
      }
      await batch.commit();
    });
  }

  Future<List<dynamic>> fetchPhotoGalleryDataFromServer(maxPhotoId) async {
    var response = await http.post(
      Uri.parse(
          'https://www.cskm.com/schoolexpert/cskmemp/sync_photogallery.php'),
      body: {
        'lastPhotoId': maxPhotoId.toString(),
        // Add other required parameters here
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      //print("data=$data");
      final data2 = data['photogalleries'];
      return data2;
    } else {
      throw Exception('Failed to fetch data from server');
    }
  }

  Future<List<Map<String, dynamic>>> getDataFromPhotoGallery() async {
    final db = await database;
    return await db.query('photogallery', orderBy: 'sno ASC');
  }

  // drop table photogallery
  // Future<void> dropTablePhotoGallery() async {
  //   final db = await database;
  //   await db.execute('DROP TABLE photogallery');
  // }

  Future<void> createTableMessages(Database db, int version) async {
    // Check if the table already exists
    var tableExists = await db.query(
      'sqlite_master',
      columns: ['name'],
      where: 'type = ? AND name = ?',
      whereArgs: ['table', 'messages'],
    );

    if (tableExists.isEmpty) {
      // Table does not exist, create it
      await db.execute('''
        CREATE TABLE messages (
          msgId INTEGER PRIMARY KEY,
          msg TEXT,
          msgDate TEXT,
          adm_no TEXT,
          userno TEXT,
          msgType TEXT
        )
      ''');
    }
  }

  Future<void> syncDataToMessages() async {
    final db = await database;

    // fetch max(msgId) from messages table
    final maxMsgId = Sqflite.firstIntValue(
      await db.rawQuery('SELECT MAX(msgId) FROM messages WHERE userno = ?',
          [AppConfig.globalUserNo]),
    );
    // if maxMsgId is null, then set it to 0 in maxMsgIdNotNull
    final maxMsgIdNotNull = maxMsgId == null ? 0 : maxMsgId;

    final dataFromServer = await fetchMessagesDataFromServer(maxMsgIdNotNull);

    await db.transaction((txn) async {
      final batch = txn.batch();

      for (var data in dataFromServer) {
        batch.rawInsert(
          'INSERT OR IGNORE INTO messages(msgId, msg, msgDate, adm_no, userno, msgType) VALUES(?, ?, ?, ?, ?, ?)',
          [
            data['msgId'],
            data['msg'],
            data['msgDate'],
            data['adm_no'],
            data['userno'],
            data['msgType'],
          ],
        );
      }
      await batch.commit();
    });
  }

  Future<List<dynamic>> fetchMessagesDataFromServer(maxMsgId) async {
    var response = await http.post(
      Uri.parse('https://www.cskm.com/schoolexpert/cskmemp/sync_messages.php'),
      body: {
        'lastMsgId': maxMsgId.toString(),
        'userno': AppConfig.globalUserNo,
        'secretKey': AppConfig.secreetKey,
        // Add other required parameters here
      },
    );

    if (response.statusCode == 200) {
      //print("response= ${response.body}");
      final data = json.decode(response.body);

      final data2 = data['messages'];
      return data2;
    } else {
      throw Exception('Failed to fetch data from server');
    }
  }

  Future<List<Map<String, dynamic>>> getDataFromMessages(adm_no, userno) async {
    final db = await database;
    return await db.query(
      'messages',
      where: 'adm_no = ? AND userno = ?',
      whereArgs: [adm_no, userno],
      orderBy: 'msgId ASC',
    );
  }

  // function to update the messageStatus to R for the given userno and adm_no
  Future<void> updateMessageStatusToR(adm_no, userno) async {
    //print(
    //"updateMessageStatusToR called for userno=$userno and adm_no=$adm_no");

    await http.post(
      Uri.parse(
          'https://www.cskm.com/schoolexpert/cskmemp/update_messages.php'),
      body: {
        'userno': userno,
        'adm_no': adm_no,
        'secretKey': AppConfig.secreetKey,
        // Add other required parameters here
      },
    );
    //print("response= ${response.body}");
  }

  // close the database
  Future<void> close() async {
    final db = await database;
    db.close();
  }

  // delete database
  Future<void> removeDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'cskmemp.db');
    await deleteDatabase(path);
  }
}
