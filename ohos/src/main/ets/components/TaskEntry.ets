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

export class TaskEntry {
  public static readonly TABLE_NAME = "task";
  public static readonly COLUMN_NAME_ID = "_id";
  public static readonly COLUMN_NAME_TASK_ID = "task_id";
  public static readonly COLUMN_NAME_STATUS = "status";
  public static readonly COLUMN_NAME_PROGRESS = "progress";
  public static readonly COLUMN_NAME_URL = "url";
  public static readonly COLUMN_NAME_SAVED_DIR = "saved_dir";
  public static readonly COLUMN_NAME_FILE_NAME = "file_name";
  public static readonly COLUMN_NAME_MIME_TYPE = "mime_type";
  public static readonly COLUMN_NAME_RESUMABLE = "resumable";
  public static readonly COLUMN_NAME_HEADERS = "headers";
  public static readonly COLUMN_NAME_SHOW_NOTIFICATION = "show_notification";
  public static readonly COLUMN_NAME_OPEN_FILE_FROM_NOTIFICATION = "open_file_from_notification";
  public static readonly COLUMN_NAME_TIME_CREATED = "time_created";
  public static readonly COLUMN_ALLOW_CELLULAR = "allow_cellular";
}