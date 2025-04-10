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

public without sharing class DX_DataCorruptionHelper {
    @TestVisible private DX_DML dml = new DX_DML();
    @TestVisible private Boolean isSandbox = [SELECT Id, IsSandbox FROM Organization LIMIT 1].isSandbox;
    @TestVisible private String sObjectApiName;
    @TestVisible private List<String> sObjectTextFields = new List<String>();
    @TestVisible private List<String> sObjectNumberFields = new List<String>();
    @TestVisible private List<String> sObjectFieldsToCorrupt = new List<String>{'Id'};
    @TestVisible private Set<String> sObjectAllFields;
    @TestVisible private Integer percentToCorrupt;
    @TestVisible private Boolean corruptByDeletion;
    @TestVisible private Boolean corruptByModification;

    @TestVisible private List<Result> modifiedRecords = new List<Result>();
    @TestVisible private List<Result> deletedRecords = new List<Result>();

    public void withMocks() {
        this.dml = (DX_DML) DX_MockUtil.createMock(DX_DML.class);
    }
    
    /**
     * @description: constructor
     * @param Data_Corruption_Object__mdt sObjectToCorrupt represents a custom metadata object for a given sObject
     */
    public DX_DataCorruptionHelper(Data_Corruption_Object__mdt sObjectToCorrupt) {
        try {
            this.sObjectApiName = sObjectToCorrupt.Custom_Object__c == false ? sObjectToCorrupt.MasterLabel : sObjectToCorrupt.MasterLabel + '__c';
            this.percentToCorrupt = Integer.valueOf(sObjectToCorrupt.Percent_To_Corrupt__c);

            this.corruptByDeletion = sObjectToCorrupt.Delete_Records__c;
            this.corruptByModification = sObjectToCorrupt.Modify_Records__c;

            if(this.corruptByModification == true) {
                //get all fields and verify sObject exists
                SObjectType type = ((SObject)(Type.forName('Schema.' + this.sObjectApiName).newInstance())).getSObjectType();
                this.sObjectAllFields = type.getDescribe().fields.getMap().keyset();

                if(sObjectToCorrupt.Number_Fields_To_Corrupt__c != null) {

                    //verify specified fields are on sObject
                    list<String> textFields = sObjectToCorrupt.Text_Fields_To_Corrupt__c.split(';', 0);

                    for(String textField : textFields) {
                        if(this.sObjectAllFields.contains(textField.toLowerCase())) {
                            this.sObjectTextFields.add(textField);
                        }
                    }
                }

                //add verified fields to corruption list
                this.sObjectFieldsToCorrupt.addAll(this.sObjectTextFields);

                //verify specified fields are on sObject
                if(sObjectToCorrupt.Number_Fields_To_Corrupt__c != null) {
                    List<String> numberFields = sObjectToCorrupt.Number_Fields_To_Corrupt__c.split(';', 0);

                    for(String numberField : numberFields) {
                        if(this.sObjectAllFields.contains(numberField.toLowerCase())) {
                            this.sObjectNumberFields.add(numberField);
                        }
                    }
                }

                //add verified fields to corruption list
                this.sObjectFieldsToCorrupt.addAll(this.sObjectNumberFields);
            }
        } catch(Exception e) {
            throw new DX_DataCorruptionQueueableChain.DataCorruptionException('There was an error provisioning the custom metadata ' + sObjectToCorrupt.MasterLabel + '. Please ensure that this sObject exists.');
        }
    }

    /**
 	 * @description: builds a dynamic SOQL query for each object to be corrupted
 	 * @return String - returns the dynamic SOQL query for use in the DX_DataCorruptionBatch class
 	 */
    public String buildQuery() {
        if(!this.isSandbox) {
            throw new DX_DataCorruptionQueueableChain.DataCorruptionException('This code should not be run in a production environment. This action will cause mass data loss.');
        }

        String corruptionQuery = 'SELECT ' + String.join(this.sObjectFieldsToCorrupt, ', ') + ' FROM ' + this.sObjectApiName;

        AggregateResult[] ars = Database.query('SELECT COUNT(Id)cnt FROM ' + this.sObjectApiName); 
        Integer totalCount = Integer.valueOf(ars[0].get('cnt'));

        Integer recordsToCorrupt = Math.round(this.percentToCorrupt * totalCount / 100);

        corruptionQuery += ' LIMIT ' + recordsToCorrupt;

        return corruptionQuery;
    }

    /**
    * @description corrupts data in Salesforce org by hard deleting or updating a field on specified records
    * @param List<sObject> records to process
    * @return None
    */
    public void corruptData(List<SObject> sObjectsToCorrupt) {
        if(!this.isSandbox) {
            throw new DX_DataCorruptionQueueableChain.DataCorruptionException('This code should not be run in a production environment. This action will cause mass data loss.');
        }
        
        List<SObject> sObjectsToDelete = new List<SObject>();
        List<SObject> sObjectsToUpdate = new List<SObject>();

        if(this.corruptByDeletion == true && this.corruptByModification == true && this.sObjectFieldsToCorrupt.size() > 0) {
            for(Integer ii = 0; ii < sObjectsToCorrupt.size(); ii++) {
                if(Math.mod(ii, 2) == 0) { //hard delete even records
                    sObjectsToDelete.add(sObjectsToCorrupt[ii]);
                } else { //update field on odd records
                    sObjectsToUpdate.add(sObjectsToCorrupt[ii]);
                }
            }
        } else if (this.corruptByModification && this.sObjectFieldsToCorrupt.size() > 0) {
            sObjectsToUpdate.addAll(sObjectsToCorrupt);
        } else if (this.corruptByDeletion) {
            sObjectsToDelete.addAll(sObjectsToCorrupt);
        } else{
            throw new DX_DataCorruptionQueueableChain.DataCorruptionException('No fields have been specified for modification on ' + this.sObjectApiName + '.');
        }


        if(sObjectsToDelete.size() > 0){
            deleteData(sObjectsToDelete);
        }

        if(sObjectsToUpdate.size() > 0){
            modifyData(corruptFields(sObjectsToUpdate));
        }
    }

    /**
    * @description corrupts data in Salesforce org by modifying fields and then updating specified records
    * @param List<sObject> records to process
    * @return List<sObject> records corrupted by modification
    */
    public List<sObject> corruptFields(List<SObject> sObjectsToCorrupt) {
        if(!this.isSandbox) {
            throw new DX_DataCorruptionQueueableChain.DataCorruptionException('This code should not be run in a production environment. This action will cause mass data loss.');
        }
        
        List<sObject> corruptedSObjects = new List<sObject>();

        for(SObject sobj : sObjectsToCorrupt) {
            //update text and number fields on specified sObject using put method of sObject class
            for(String fieldToUpdate : this.sObjectFieldsToCorrupt) {
                if(this.sObjectTextFields.contains(fieldToUpdate)) {
                    sObj.put(fieldToUpdate, 'CORRUPTED FIELD');
                } else if(this.sObjectNumberFields.contains(fieldToUpdate)) {
                    sObj.put(fieldToUpdate, 0);
                }
            }

            corruptedSObjects.add(sObj);
        }

        return corruptedSObjects;
    }

    /**
    * @description corrupts data in Salesforce org by hard deleting specified records
    * @param List<sObject> records to delete
    * @return none
    */
    public void deleteData(List<SObject> sObjectsToDelete) {
        List<Database.DeleteResult> deleted = this.dml.deleteRecords(sObjectsToDelete);
        Database.emptyRecycleBin(sObjectsToDelete);

        for(Database.DeleteResult dr : deleted) {
            Result res = new Result(dr.getId(), dr.isSuccess());

            this.deletedRecords.add(res);
        }
    }

    /**
    * @description corrupts data in Salesforce org by updating fields on specified records
    * @param List<sObject> records to update
    * @return None
    */
    public void modifyData(List<SObject> corruptedSObjects) {
        List<Database.SaveResult> modified = this.dml.updateRecords(corruptedSObjects);

        for(Database.SaveResult sr : modified) {
            Result res = new Result(sr.getId(), sr.isSuccess());

            this.modifiedRecords.add(res);
        }
    }

    /**
     * @description: wrapper for Database.XXResult mocking
     */
    public class Result {
        public String id;
        public Boolean success;

        /**
         * @description: constructor for Database.XXResult mocking
         * @param Boolean success
         * @param String id
         */
        public Result(String id, Boolean success) {
            this.id = id;
            this.success = success;
        }
    }
}