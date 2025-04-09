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
private class DX_DataCorruption_Test {
    
    /**
     * @description: wrapper class for mocked cases
     */
    private class Mocking {
        List<Case> mockedCases;
    }

    static Mocking returnMock() {
        Mocking result = new Mocking(); 

        result.mockedCases = new List<Case>();

        for(Integer ii=0; ii < 100; ii++) {
            Case mockCase = new Case();
            mockCase.Description = 'Mocked Case';
            mockCase.Id = (Id) DX_IdMocker.getMockId(mockCase);
            result.mockedCases.add(mockCase);
        }

        return result;
    }

    @isTest
    static void testSObjectCorruption_buildQuery() {
        Data_Corruption_Object__mdt testingMetadata = new Data_Corruption_Object__mdt();
        testingMetadata.Masterlabel = 'Case';
        testingMetadata.Active__c = true;
        testingMetadata.Number_Fields_To_Corrupt__c = null;
        testingMetadata.Text_Fields_To_Corrupt__c = 'Description';
        testingMetadata.Custom_Object__c = false;
        testingMetadata.Delete_Records__c = true;
        testingMetadata.Modify_Records__c = true;
        testingMetadata.Percent_To_Corrupt__c = 1;

        Test.startTest();
            DX_DataCorruptionHelper helper = new DX_DataCorruptionHelper(testingMetadata);
            String query = helper.buildQuery();
        Test.stopTest();

        Assert.isTrue(query.contains('Case'), 'Expected to have Case in query.');

    }

    @isTest
    static void testSObjectCorruption_testChaining() {
        Data_Corruption_Object__mdt testingMetadata = new Data_Corruption_Object__mdt();
        testingMetadata.Masterlabel = 'Case';
        testingMetadata.Active__c = true;
        testingMetadata.Number_Fields_To_Corrupt__c = null;
        testingMetadata.Text_Fields_To_Corrupt__c = 'Description';
        testingMetadata.Custom_Object__c = false;
        testingMetadata.Delete_Records__c = true;
        testingMetadata.Modify_Records__c = true;
        testingMetadata.Percent_To_Corrupt__c = 1;

        DX_Query.setMock(new QueryMock(new List<Data_Corruption_Object__mdt>{testingMetadata}));

        Test.startTest();
            DX_DataCorruptionQueueableChain job = new DX_DataCorruptionQueueableChain('testing@yourcompany.com');
            job.runJob();
        Test.stopTest();

        Assert.areEqual(1, job.chain.getSize(), 'Expected there to be one chain in the jobs chain.');
    }

    @isTest
    static void testSObjectCorruption_testBatchStart() {
        Data_Corruption_Object__mdt testingMetadata = new Data_Corruption_Object__mdt();
        testingMetadata.Masterlabel = 'Case';
        testingMetadata.Active__c = true;
        testingMetadata.Number_Fields_To_Corrupt__c = null;
        testingMetadata.Text_Fields_To_Corrupt__c = 'Description';
        testingMetadata.Custom_Object__c = false;
        testingMetadata.Delete_Records__c = true;
        testingMetadata.Modify_Records__c = true;
        testingMetadata.Percent_To_Corrupt__c = 1;

        DX_DataCorruptionBatch batch = new DX_DataCorruptionBatch(new DX_QueueableJobChain(), testingMetadata, 'testing@yourcompany.com');
        batch.helper.withMocks();

        Mocking mock = returnMock();

        Test.startTest();
            batch.start(null);
        Test.stopTest();

        Assert.isTrue(batch.corruptionQuery.contains('Case'), 'Expected to have Case in query.');
    }

    @isTest
    static void testSObjectCorruption_testBatchExecute() {
        Data_Corruption_Object__mdt testingMetadata = new Data_Corruption_Object__mdt();
        testingMetadata.Masterlabel = 'Case';
        testingMetadata.Active__c = true;
        testingMetadata.Number_Fields_To_Corrupt__c = null;
        testingMetadata.Text_Fields_To_Corrupt__c = 'Description';
        testingMetadata.Custom_Object__c = false;
        testingMetadata.Delete_Records__c = true;
        testingMetadata.Modify_Records__c = true;
        testingMetadata.Percent_To_Corrupt__c = 1;

        DX_DataCorruptionBatch batch = new DX_DataCorruptionBatch(new DX_QueueableJobChain(), testingMetadata, 'testing@yourcompany.com');
        batch.helper.withMocks();

        Mocking mock = returnMock();

        Test.startTest();
            batch.execute(null, mock.mockedCases);
        Test.stopTest();

        Assert.areEqual(50, batch.helper.modifiedRecords.size(), 'Expected there to be 50 cases left after 50% deletion for 100% corruption.');
        Assert.areEqual(50, batch.helper.deletedRecords.size(), 'Expected there to be 50 cases left after 50% deletion for 100% corruption.');
    }

    @isTest
    static void testSObjectCorruption_testBatchFinish() {
        Data_Corruption_Object__mdt testingMetadata = new Data_Corruption_Object__mdt();
        testingMetadata.Masterlabel = 'Case';
        testingMetadata.Active__c = true;
        testingMetadata.Number_Fields_To_Corrupt__c = null;
        testingMetadata.Text_Fields_To_Corrupt__c = 'Description';
        testingMetadata.Custom_Object__c = false;
        testingMetadata.Delete_Records__c = true;
        testingMetadata.Modify_Records__c = true;
        testingMetadata.Percent_To_Corrupt__c = 1;

        DX_DataCorruptionBatch batch = new DX_DataCorruptionBatch(new DX_QueueableJobChain(), testingMetadata, 'testing@yourcompany.com');
        batch.helper.withMocks();

        Mocking mock = returnMock();

        Test.startTest();
            batch.finish(null);
        Test.stopTest();

        List<EmailMessage> emails = [SELECT Id FROM EmailMessage];

        Assert.areEqual(1, emails.size(), 'Expected there to be one email sent.');
    }

    @isTest
    static void testSObjectCorruption_testDeleteAndCorrupt() {
        Data_Corruption_Object__mdt testingMetadata = new Data_Corruption_Object__mdt();
        testingMetadata.Masterlabel = 'Case';
        testingMetadata.Active__c = true;
        testingMetadata.Number_Fields_To_Corrupt__c = null;
        testingMetadata.Text_Fields_To_Corrupt__c = 'Description';
        testingMetadata.Custom_Object__c = false;
        testingMetadata.Delete_Records__c = true;
        testingMetadata.Modify_Records__c = true;
        testingMetadata.Percent_To_Corrupt__c = 1;

        DX_DataCorruptionHelper helper = new DX_DataCorruptionHelper(testingMetadata);

        helper.withMocks();

        Mocking mock = returnMock();

        Test.startTest();
            helper.corruptData(mock.mockedCases);
        Test.stopTest();

        Assert.areEqual(50, helper.modifiedRecords.size(), 'Expected there to be 50 cases left after 50% modification for 100% corruption.');
        Assert.areEqual(50, helper.deletedRecords.size(), 'Expected there to be 50 cases left after 50% deletion for 100% corruption.');
    }

    @isTest
    static void testSObjectCorruption_testDelete() {
        Data_Corruption_Object__mdt testingMetadata = new Data_Corruption_Object__mdt();
        testingMetadata.Masterlabel = 'Case';
        testingMetadata.Active__c = true;
        testingMetadata.Number_Fields_To_Corrupt__c = null;
        testingMetadata.Text_Fields_To_Corrupt__c = 'Description';
        testingMetadata.Custom_Object__c = false;
        testingMetadata.Delete_Records__c = true;
        testingMetadata.Modify_Records__c = false;
        testingMetadata.Percent_To_Corrupt__c = 1;

        DX_DataCorruptionHelper helper = new DX_DataCorruptionHelper(testingMetadata);

        helper.withMocks();

        Mocking mock = returnMock();

        Test.startTest();
            helper.corruptData(mock.mockedCases);
        Test.stopTest();

        Assert.areEqual(0, helper.modifiedRecords.size(), 'Expected there to be 0 cases left after 100% deletion for 100% corruption.');
        Assert.areEqual(100, helper.deletedRecords.size(), 'Expected there to be 100 cases deleted for 100% corruption.');
    }

    @isTest
    static void testSObjectCorruption_testModify() {
        Data_Corruption_Object__mdt testingMetadata = new Data_Corruption_Object__mdt();
        testingMetadata.Masterlabel = 'Case';
        testingMetadata.Active__c = true;
        testingMetadata.Number_Fields_To_Corrupt__c = null;
        testingMetadata.Text_Fields_To_Corrupt__c = 'Description';
        testingMetadata.Custom_Object__c = false;
        testingMetadata.Delete_Records__c = false;
        testingMetadata.Modify_Records__c = true;
        testingMetadata.Percent_To_Corrupt__c = 1;
        
        DX_DataCorruptionHelper helper = new DX_DataCorruptionHelper(testingMetadata);

        helper.withMocks();

        Mocking mock = returnMock();

        Test.startTest();
            helper.corruptData(mock.mockedCases);
        Test.stopTest();

        Assert.areEqual(100, helper.modifiedRecords.size(), 'Expected there to be 100 modified cases left after 0% deletion for 100% corruption.');
        Assert.areEqual(0, helper.deletedRecords.size(), 'Expected there to be 0 cases deleted.');
    }

    class QueryMock extends DX_Query.Service
    {
        final List<SObject> records;
        QueryMock(List<SObject> records)
        {
            this.records = records;
        }

        protected override List<SObject> passThrough(List<SObject> toIgnore)
        {
            return records;
        }
    }
}