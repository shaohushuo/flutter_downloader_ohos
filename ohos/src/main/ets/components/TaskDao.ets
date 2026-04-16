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

import { DownloadStatus } from './DownloadStatus';
import { TaskDbHelper } from './TaskDbHelper';
import { TaskEntry } from './TaskEntry';
import { relationalStore, ValuesBucket } from '@kit.ArkData';
import { BusinessError } from '@kit.BasicServicesKit';
import Logger from './Logger';
import { DownloadTask } from './DownloadTask';
import { getMimeType } from './FileUtils';

const TAG = 'TaskDao';

export class TaskDao {
  private dbHelper: TaskDbHelper | null = null;
  private projection: string[] = [
    TaskEntry.COLUMN_NAME_ID,
    TaskEntry.COLUMN_NAME_TASK_ID,
    TaskEntry.COLUMN_NAME_PROGRESS,
    TaskEntry.COLUMN_NAME_STATUS,
    TaskEntry.COLUMN_NAME_URL,
    TaskEntry.COLUMN_NAME_FILE_NAME,
    TaskEntry.COLUMN_NAME_SAVED_DIR,
    TaskEntry.COLUMN_NAME_HEADERS,
    TaskEntry.COLUMN_NAME_MIME_TYPE,
    TaskEntry.COLUMN_NAME_RESUMABLE,
    TaskEntry.COLUMN_NAME_OPEN_FILE_FROM_NOTIFICATION,
    TaskEntry.COLUMN_NAME_SHOW_NOTIFICATION,
    TaskEntry.COLUMN_NAME_TIME_CREATED,
    TaskEntry.COLUMN_ALLOW_CELLULAR,
  ];
  private syncData: Map<string, ValuesBucket> = new Map();

  constructor(dbHelper: TaskDbHelper) {
    this.dbHelper = dbHelper; // 将 dbHelper 作为实例变量保存
  }

  async insertOrUpdateNewTask(
    taskId: string,
    url: string,
    status: DownloadStatus,
    progress: number,
    filename: string,
    savedDir: string,
    headers: string,
    showNotification: boolean,
    openFileFromNotification: boolean,
    allowCellular: boolean,
  ): Promise<void> {
    let db = this.dbHelper!.getRdbStore();
    if (db == null) {
      return;
    }
    let values: ValuesBucket = {};
    values[TaskEntry.COLUMN_NAME_TASK_ID] = taskId;
    values[TaskEntry.COLUMN_NAME_URL] = url;
    values[TaskEntry.COLUMN_NAME_STATUS] = status;
    values[TaskEntry.COLUMN_NAME_PROGRESS] = progress;
    values[TaskEntry.COLUMN_NAME_FILE_NAME] = filename;
    values[TaskEntry.COLUMN_NAME_SAVED_DIR] = savedDir;
    values[TaskEntry.COLUMN_NAME_HEADERS] = headers;
    values[TaskEntry.COLUMN_NAME_MIME_TYPE] = getMimeType(filename);
    values[TaskEntry.COLUMN_NAME_SHOW_NOTIFICATION] = showNotification ? 1 : 0;
    values[TaskEntry.COLUMN_NAME_OPEN_FILE_FROM_NOTIFICATION] = openFileFromNotification ? 1 : 0;
    values[TaskEntry.COLUMN_NAME_RESUMABLE] = 0;
    values[TaskEntry.COLUMN_NAME_TIME_CREATED] = Date.now();
    values[TaskEntry.COLUMN_ALLOW_CELLULAR] = allowCellular ? 1 : 0;
    db.beginTransaction();
    try {
      let rows = await db.insert(TaskEntry.TABLE_NAME, values,
        relationalStore.ConflictResolution.ON_CONFLICT_REPLACE);
      Logger.info(TAG, `insertOrUpdateNewTask row count: ${rows}`);
      db.commit();
    } catch (e) {
      let err: BusinessError = e as BusinessError
      Logger.error(TAG, `insertOrUpdateNewTask failed, err.code: ${err.code}, err.message: ${err.message}`);
      return Promise.reject(e);
    }
    return Promise.resolve();
  }

  async loadAllTasks(): Promise<Array<DownloadTask>> {
    let db = this.dbHelper!.getRdbStore();
    let result = new Array<DownloadTask>();
    if (db != null) {
      try {
        let predicates = new relationalStore.RdbPredicates(TaskEntry.TABLE_NAME);
        let resultSet = await db.query(predicates, this.projection);
        Logger.info(TAG, `ResultSet row count: ${resultSet.rowCount}`);
        while (resultSet.goToNextRow()) {
          result.push(this.parseResultSet(resultSet));
        }
        // 释放数据集的内存
        resultSet.close();
      } catch (e) {
        let err: BusinessError = e as BusinessError
        Logger.error(TAG, `loadAllTasks failed, err.code: ${err.code}, err.message: ${err.message}`);
        Promise.reject(e);
      }
    }
    Logger.info(TAG, `ResultSet: ${JSON.stringify(result)}`);
    return Promise.resolve(result);
  }

  loadTasksWithRawQuery(query: string): Array<DownloadTask> {
    let db = this.dbHelper!.getRdbStore();
    let result = new Array<DownloadTask>();
    if (db != null) {
      try {
        let resultSet = db.querySqlSync(query);
        Logger.info(TAG, `ResultSet row count: ${resultSet.rowCount}`);
        while (resultSet.goToNextRow()) {
          result.push(this.parseResultSet(resultSet));
        }
        // 释放数据集的内存
        resultSet.close();
      } catch (e) {
        let err: BusinessError = e as BusinessError;
        Logger.error(TAG, `loadTasksWithRawQuery failed, err.code: ${err.code}, err.message: ${err.message}`);
      }
    }
    return result;
  }

  getSyncData(taskId: string) {
    return this.syncData.get(taskId);
  }

  loadTask(taskId: string): DownloadTask | null {
    let db = this.dbHelper!.getRdbStore();
    let result: DownloadTask | null = null;
    if (db != null) {
      try {
        let predicates = new relationalStore.RdbPredicates(TaskEntry.TABLE_NAME);
        predicates.equalTo(TaskEntry.COLUMN_NAME_TASK_ID, taskId);
        predicates.orderByDesc(TaskEntry.COLUMN_NAME_ID);
        predicates.limitAs(1);
        let resultSet = db.querySync(predicates);
        while (resultSet.goToNextRow()) {
          result = this.parseResultSet(resultSet);
        }
        // 释放数据集的内存
        resultSet.close();
      } catch (e) {
        let err: BusinessError = e as BusinessError;
        Logger.error(TAG, `loadTasksWithRawQuery failed, err.code: ${err.code}, err.message: ${err.message}`);
      }
    }
    return result;
  }

  async updateTask(taskId: string, values: ValuesBucket): Promise<void> {
    this.syncData.set(taskId, values);
    let db = this.dbHelper!.getRdbStore();
    if (db == null) {
      return;
    }
    db.beginTransaction();
    try {
      let predicates = new relationalStore.RdbPredicates(TaskEntry.TABLE_NAME);
      predicates.equalTo(TaskEntry.COLUMN_NAME_TASK_ID, taskId);
      let rows = await db.update(values, predicates);
      Logger.info(TAG, `Updated row count: ${rows}`);
      db.commit();
    } catch (e) {
      let err: BusinessError = e as BusinessError
      Logger.error(TAG, `updateTask err, err.code: ${err.code}, err.message: ${err.message}`);
      return Promise.reject(`updateTask failed`);
    }
    return Promise.resolve();
  }

  async deleteTask(taskId: string): Promise<void> {
    this.syncData.delete(taskId);
    let db = this.dbHelper!.getRdbStore();
    if (db == null) {
      return;
    }
    db.beginTransaction();
    try {
      let predicates = new relationalStore.RdbPredicates(TaskEntry.TABLE_NAME);
      predicates.equalTo(TaskEntry.COLUMN_NAME_TASK_ID, taskId);
      let rows = await db.delete(predicates);
      Logger.info(TAG, `Deleted row count: ${rows}`);
      db.commit();
    } catch (e) {
      let err: BusinessError = e as BusinessError
      Logger.error(TAG, `deleteTask err, err.code: ${err.code}, err.message: ${err.message}`);
      return Promise.reject(`deleteTask failed`);
    }
    return Promise.resolve();
  }

  private parseResultSet(resultSet: relationalStore.ResultSet): DownloadTask {
    const primaryId = resultSet.getLong(resultSet.getColumnIndex(TaskEntry.COLUMN_NAME_ID));
    const task_id = resultSet.getString(resultSet.getColumnIndex(TaskEntry.COLUMN_NAME_TASK_ID));
    const status = resultSet.getLong(resultSet.getColumnIndex(TaskEntry.COLUMN_NAME_STATUS));
    const progress = resultSet.getLong(resultSet.getColumnIndex(TaskEntry.COLUMN_NAME_PROGRESS));
    const url = resultSet.getString(resultSet.getColumnIndex(TaskEntry.COLUMN_NAME_URL));
    const filename = resultSet.getString(resultSet.getColumnIndex(TaskEntry.COLUMN_NAME_FILE_NAME));
    const savedDir = resultSet.getString(resultSet.getColumnIndex(TaskEntry.COLUMN_NAME_SAVED_DIR));
    const headers = resultSet.getString(resultSet.getColumnIndex(TaskEntry.COLUMN_NAME_HEADERS));
    const mimeType = resultSet.getString(resultSet.getColumnIndex(TaskEntry.COLUMN_NAME_MIME_TYPE));
    const resumable = resultSet.getLong(resultSet.getColumnIndex(TaskEntry.COLUMN_NAME_RESUMABLE));
    const showNotification = resultSet.getLong(resultSet.getColumnIndex(TaskEntry.COLUMN_NAME_SHOW_NOTIFICATION));
    const clickToOpenDownloadedFile =
      resultSet.getLong(resultSet.getColumnIndex(TaskEntry.COLUMN_NAME_OPEN_FILE_FROM_NOTIFICATION));
    const timeCreated = resultSet.getLong(resultSet.getColumnIndex(TaskEntry.COLUMN_NAME_TIME_CREATED));
    const allowCellular = resultSet.getLong(resultSet.getColumnIndex(TaskEntry.COLUMN_ALLOW_CELLULAR));

    let task: DownloadTask = {
      primaryId: primaryId,
      taskId: task_id,
      status: status,
      progress: progress,
      url: url,
      filename: filename,
      savedDir: savedDir,
      headers: headers,
      mimeType: mimeType,
      resumable: resumable == 1,
      showNotification: showNotification == 1,
      openFileFromNotification: clickToOpenDownloadedFile == 1,
      timeCreated: timeCreated,
      allowCellular: allowCellular == 1
    }
    return task;
  }
}