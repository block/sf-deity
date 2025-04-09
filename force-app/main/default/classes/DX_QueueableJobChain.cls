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

public without sharing class DX_QueueableJobChain {
    private List<DX_ChainedQueueable> chain;

    /**
     * @description: constructor
     */
    public DX_QueueableJobChain() {
        this.chain = new List<DX_ChainedQueueable>();
    }

    /**
     * @description: adds first item to chain
     * @param DX_ChainedQueueable cq
     */
    public void chainFirst(DX_ChainedQueueable cq) {
        if(this.hasNext()) {
            this.chain.add(0, cq);
        } else {
            this.chainLast(cq);
        }
    }

    /**
     * @description: adds last item to chain
     * @param DX_ChainedQueueable cq
     */
    public void chainLast(DX_ChainedQueueable cq) {
        this.chain.add(cq);
    }

    /**
     * @description: determines if there is another chained item
     */
    public Boolean hasNext() {
        return this.chain.size() > 0;
    }

    /**
     * @description: enqueues the next job in the chain
     */
    public void runNext() {
        if(this.hasNext()) {
            DX_ChainedQueueable cq = this.chain.remove(0);
            cq.setChain(this);
            System.enqueueJob(cq);
        }
    }

    /**
     * @description: gets the size of the chain
     */
    public Integer getSize() {
        return this.chain.size();
    }
}