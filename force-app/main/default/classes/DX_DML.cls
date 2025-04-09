/*
 * Copyright (c) 2025 Block, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

public virtual class DX_DML {
    public virtual List<Database.SaveResult> insertRecords(List<SObject> recordsToInsert) {
        return Database.insert(recordsToInsert, false);
    }

    public virtual List<Database.SaveResult> updateRecords(List<SObject> recordsToUpdate) {
        return Database.update(recordsToUpdate, false);
    }

    public virtual List<Database.UpsertResult> upsertRecords(List<SObject> recordsToUpsert, String externalIdField) {
        SObjectField sObjFieldForId = recordsToUpsert[0].getSObjectType().getDescribe().fields.getMap().get(externalIdField);
        
        return Database.upsert(recordsToUpsert, sObjFieldForId, false);
    }

    public virtual List<Database.DeleteResult> deleteRecords(List<SObject> recordsToDelete) {
        return Database.delete(recordsToDelete, false);
    }
}