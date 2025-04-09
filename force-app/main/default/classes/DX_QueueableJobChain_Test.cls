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

@isTest
private class DX_QueueableJobChain_Test {
    @isTest
    static void testQueueableJobChain_chainFirst() {
        Data_Corruption_Object__mdt testingMetadata = new Data_Corruption_Object__mdt();
        testingMetadata.Masterlabel = 'Case';
        testingMetadata.Active__c = true;
        testingMetadata.Number_Fields_To_Corrupt__c = null;
        testingMetadata.Text_Fields_To_Corrupt__c = 'Description';
        testingMetadata.Custom_Object__c = false;
        testingMetadata.Delete_Records__c = false;
        testingMetadata.Modify_Records__c = true;

        DX_QueueableJobChain chain = new DX_QueueableJobChain();
        
        test.startTest();
            chain.chainFirst(new DX_DataCorruptionQueueable(chain, testingMetadata, 'testing@yourcompany.com'));
        test.stopTest();

        System.assertEquals(1, chain.getSize(), 'Verify that there is one item in the chain.');
    }

    @isTest
    static void testQueueableJobChain_chainLast() {
        Data_Corruption_Object__mdt testingMetadata = new Data_Corruption_Object__mdt();
        testingMetadata.Masterlabel = 'Case';
        testingMetadata.Active__c = true;
        testingMetadata.Number_Fields_To_Corrupt__c = null;
        testingMetadata.Text_Fields_To_Corrupt__c = 'Description';
        testingMetadata.Custom_Object__c = false;
        testingMetadata.Delete_Records__c = false;
        testingMetadata.Modify_Records__c = true;

        DX_QueueableJobChain chain = new DX_QueueableJobChain();
        
        test.startTest();
            chain.chainLast(new DX_DataCorruptionQueueable(chain, testingMetadata, 'testing@yourcompany.com'));
        test.stopTest();

        System.assertEquals(1, chain.getSize(), 'Verify that there is one item in the chain.');
    }

    @isTest
    static void testQueueableJobChain_chainFirstLast() {
        Data_Corruption_Object__mdt testingMetadata = new Data_Corruption_Object__mdt();
        testingMetadata.Masterlabel = 'Case';
        testingMetadata.Active__c = true;
        testingMetadata.Number_Fields_To_Corrupt__c = null;
        testingMetadata.Text_Fields_To_Corrupt__c = 'Description';
        testingMetadata.Custom_Object__c = false;
        testingMetadata.Delete_Records__c = false;
        testingMetadata.Modify_Records__c = true;
        
        DX_QueueableJobChain chain = new DX_QueueableJobChain();
        
        test.startTest();
            chain.chainLast(new DX_DataCorruptionQueueable(chain, testingMetadata, 'testing@yourcompany.com'));
            chain.chainFirst(new DX_DataCorruptionQueueable(chain, testingMetadata, 'testing@yourcompany.com'));
        test.stopTest();

        System.assertEquals(2, chain.getSize(), 'Verify that there is one item in the chain.');
    }

    @isTest
    static void testQueueableJobChain_runNext() {
        DX_QueueableJobChain chain = new DX_QueueableJobChain();
        
        test.startTest();
            chain.runNext();
        test.stopTest();

        System.assertEquals(0, chain.getSize(), 'Verify that there are no items in the chain.');
    }

}