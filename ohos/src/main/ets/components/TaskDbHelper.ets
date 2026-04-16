/*
* Copyright (c) 2024 SwanLink (Jiangsu) Technology Development Co., LTD.
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
*     http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

import relationalStore from '@ohos.data.relationalStore';
import { Context } from '@kit.AbilityKit';
import { TaskEntry } from './TaskEntry';

export class TaskDbHelper {
  private static instance: TaskDbHelper;
  private static readonly DATABASE_VERSION = 4;
  private static readonly DATABASE_NAME = "download_tasks.db";
  private static readonly SQL_CREATE_ENTRIES =
    "CREATE TABLE IF NOT EXISTS " + TaskEntry.TABLE_NAME + " (" +
    TaskEntry.COLUMN_NAME_ID + " INTEGER PRIMARY KEY," +
    TaskEntry.COLUMN_NAME_TASK_ID + " VARCHAR(256), " +
    TaskEntry.COLUMN_NAME_URL + " TEXT, " +
    TaskEntry.COLUMN_NAME_STATUS + " INTEGER DEFAULT 0, " +
    TaskEntry.COLUMN_NAME_PROGRESS + " INTEGER DEFAULT 0, " +
    TaskEntry.COLUMN_NAME_FILE_NAME + " TEXT, " +
    TaskEntry.COLUMN_NAME_SAVED_DIR + " TEXT, " +
    TaskEntry.COLUMN_NAME_HEADERS + " TEXT, " +
    TaskEntry.COLUMN_NAME_MIME_TYPE + " VARCHAR(128), " +
    TaskEntry.COLUMN_NAME_RESUMABLE + " TINYINT DEFAULT 0, " +
    TaskEntry.COLUMN_NAME_SHOW_NOTIFICATION + " TINYINT DEFAULT 0, " +
    TaskEntry.COLUMN_NAME_OPEN_FILE_FROM_NOTIFICATION + " TINYINT DEFAULT 0, " +
    TaskEntry.COLUMN_NAME_TIME_CREATED + " INTEGER DEFAULT 0, " +
    TaskEntry.COLUMN_ALLOW_CELLULAR + " TINYINT DEFAULT 1" +
      ")";
  private static readonly SQL_DELETE_ENTRIES = `DROP TABLE IF EXISTS ${TaskEntry.TABLE_NAME}`;
  private rdbStore: relationalStore.RdbStore | null = null;

  constructor(context: Context) {
    if (TaskDbHelper.instance) {
      return TaskDbHelper.instance; // 单例模式
    }
    relationalStore.getRdbStore(context, {
      name: TaskDbHelper.DATABASE_NAME,
      securityLevel: relationalStore.SecurityLevel.S1
    }).then(rdbStore => {
      this.rdbStore = rdbStore;
      this.rdbStore.version = TaskDbHelper.DATABASE_VERSION;
      this.rdbStore.executeSql(TaskDbHelper.SQL_CREATE_ENTRIES);
      TaskDbHelper.instance = this; // 设置单例
    })
  }

  static getInstance(context?: Context): TaskDbHelper {
    if (!TaskDbHelper.instance) {
      TaskDbHelper.instance = new TaskDbHelper(context!);
    }
    return TaskDbHelper.instance;
  }

  getRdbStore(): relationalStore.RdbStore | null {
    return this.rdbStore;
  }
}