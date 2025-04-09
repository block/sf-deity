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

 public without sharing class DX_DataCorruptionBatch implements Database.Batchable<SObject> {
    
    @TestVisible private Boolean isSandbox = [SELECT Id, IsSandbox FROM Organization LIMIT 1].isSandbox;
    @TestVisible private Boolean isTesting = Test.isRunningTest();
    
    @TestVisible private String corruptionQuery;
    @TestVisible private Data_Corruption_Object__mdt sObjectToCorrupt;
    @TestVisible private String emailAddress;
    public Integer defaultBatchSize = 200;

    @TestVisible private DX_DataCorruptionHelper helper;
    @TestVisible private DX_QueueableJobChain chain;

    /**
     * @description: constructor
     * @param DX_QueueableJobChain chain, the chain of queueables being operated on
     * @param Data_Corruption_Object__mdt sObjectToCorrupt, the metadata representing the sObject to be corrupted
     * @param String emailAddress, the email to send an alert to when each job completes
     */
    public DX_DataCorruptionBatch(DX_QueueableJobChain chain, Data_Corruption_Object__mdt sObjectToCorrupt, String emailAddress) {
        if(!this.isSandbox) {
            throw new DX_DataCorruptionQueueableChain.DataCorruptionException('This code should not be run in a production environment. This action will cause mass data loss.');
        }

        this.helper = new DX_DataCorruptionHelper(sobjectToCorrupt);

        if(this.isTesting) {
            this.helper.withMocks();
        }

        this.chain = chain;
        this.sObjectToCorrupt = sObjectToCorrupt;
        this.emailAddress = emailAddress;
        this.corruptionQuery = helper.buildQuery();
    }

    /**
     * @description: batchable start method
     * @param Database.BatchableContext BC
     * @return Database.QueryLocator
     */
    public Database.QueryLocator start(Database.BatchableContext BC) {
        try {
            return Database.getQueryLocator(this.corruptionQuery);
        } catch(Exception e) {
            throw new DX_DataCorruptionQueueableChain.DataCorruptionException('There was an error provisioning the custom metadata ' + this.sObjectToCorrupt.MasterLabel + '. Please ensure that this sObject exists.');
        }
    }
    
    /**
     * @description: batchable execute method
     * @param Database.BatchableContext BC
     * @param List<sObject> sObjectsToCorrupt
     */
    public void execute(Database.BatchableContext BC, List<sObject> sObjectsToCorrupt){
        this.helper.corruptData(sObjectsToCorrupt);
    }
    
    /**
     * @description: batchable finish method
     * @param Database.BatchableContext BC
     */
    public void finish(Database.BatchableContext BC){
        String sObjName = this.sObjectToCorrupt.Masterlabel;
        String subject = sObjName + ' corruption batch complete.';
        String body = 'The DX_DataCorruptionBatch class has been completed at ' + this.sObjectToCorrupt.Percent_To_Corrupt__c + '% for the following query: ' + this.corruptionQuery;

        sendEmail(subject, body);

        if(!this.isTesting) { //if in sandbox and not running a test, run next chained job
            this.chain.runNext();
        }
    }

    /**
     * @description: sends an email to the specified email address
     * @param String subject
     * @param String body
     */
    public void sendEmail(String subject, String body) {
        OrgWideEmailAddress orgWideEmail = [SELECT Id, Address FROM OrgWideEmailAddress LIMIT 1];

        Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();

        emailToSend.setOrgWideEmailAddressId(orgWideEmail.Id);
        emailToSend.setReplyTo(orgWideEmail.Address);
        emailToSend.setToAddresses(new List<String>{this.emailAddress});
        emailToSend.setSubject(subject);
        emailToSend.setPlainTextBody(body);

        Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{emailToSend}, false);
    }
}