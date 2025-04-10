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

public without sharing class DX_DataCorruptionQueueableChain {
    @TestVisible private String emailAddress;

    @TestVisible private DX_QueueableJobChain chain;

    /**
     * @description: constructor
     * @param String emailAddress, the email to send an alert to when each job completes
     */
    public DX_DataCorruptionQueueableChain(String emailAddress) {
        DX_DataCorruptionChecker.canRun();

        this.chain = new DX_QueueableJobChain();
        this.emailAddress = emailAddress;
    }
    
    /**
     * @description: runs the corruption job
     */
    public void runJob() {
        DX_DataCorruptionChecker.canRun();

        if(!DX_DataCorruptionChecker.isSandbox) {
            throw new DataCorruptionException('This code should not be run in a production environment. This action will cause mass data loss.');
        } else { //if in sandbox, chain jobs
            List<Data_Corruption_Object__mdt> objectsToCorrupt = new DX_CustomMetadataSelector().selectActiveDataCorruptionObjects();

            for(Data_Corruption_Object__mdt objMdt : objectsToCorrupt) {
                this.chain.chainLast(new DX_DataCorruptionQueueable(this.chain, objMdt, this.emailAddress));
            }

            //chained jobs cannot run in tests
            if(!DX_DataCorruptionChecker.isRunningTest) {
                this.chain.runNext();
            }
        }
    }

    public class DataCorruptionException extends Exception {}
}