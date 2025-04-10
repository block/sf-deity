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

public with sharing class DX_DataCorruptionQueueable extends DX_ChainedQueueable {
    @TestVisible private Data_Corruption_Object__mdt sObjectToCorrupt;
    @TestVisible private String emailAddress;

    @TestVisible private DX_QueueableJobChain chain;
    
    /**
     * @description: constructor
     * @param DX_QueueableJobChain chain, the chain of queueables being operated on
     * @param Data_Corruption_Object__mdt sObjectToCorrupt, the metadata representing the sObject to be corrupted
     * @param String emailAddress, the email to send an alert to when each job completes
     */
    public DX_DataCorruptionQueueable(DX_QueueableJobChain chain, Data_Corruption_Object__mdt sObjectToCorrupt, String emailAddress) {
        super(chain); //must be first statement in constructor
        this.chain = chain;

        this.sObjectToCorrupt = sObjectToCorrupt;
        this.emailAddress = emailAddress;

        DX_DataCorruptionChecker.canRun();
    }

    /**
     * @description: overridden queueable execute method
     * @param QueueableContext qc
     */
    public override void execute(QueueableContext qc) {
        DX_DataCorruptionChecker.canRun();
        
        DX_DataCorruptionBatch batch = new DX_DataCorruptionBatch(this.chain, this.sObjectToCorrupt, this.emailAddress);
        Database.executeBatch(batch, batch.defaultBatchSize);
    }
}