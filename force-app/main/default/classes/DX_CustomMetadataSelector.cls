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

public without sharing class DX_CustomMetadataSelector {
    /**
     * @description: selects and sorts active Data_Corruption_Object__mdt records
     */
    public List<Data_Corruption_Object__mdt> selectActiveDataCorruptionObjects() {
       return DX_Query.records([SELECT Masterlabel,
                DeveloperName,
                Number_Fields_To_Corrupt__c,
                Text_Fields_To_Corrupt__c,
                Custom_Object__c,
                Corruption_Order__c,
                Delete_Records__c,
                Hard_Delete_Records__c,
                Modify_Records__c,
                Percent_To_Corrupt__c
            FROM Data_Corruption_Object__mdt
            WHERE Active__c = true
            ORDER BY Corruption_Order__c ASC NULLS LAST]);
    }
}