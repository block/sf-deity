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

public abstract class DX_ChainedQueueable implements Queueable{
    protected DX_QueueableJobChain chain;
    
    /**
     * @description: constructor
     * @param DX_QueueableJobChain chain, the chain of queueables being operated on
     */
    public DX_ChainedQueueable(DX_QueueableJobChain chain) {
        this.chain = chain;
    }

    /**
     * @description: if there is a next queueable in the chain, run it
     */
    protected void executeNext() {
        if(this.isChained()) {
            this.chain.runNext();
        }
    }

    /**
     * @description: sets the chain value
     * @param DX_QueueableJobChain chain, the chain of queueables being operated on
     */
    public void setChain(DX_QueueableJobChain chain) {
        this.chain = chain;
    }

    /**
     * @description: constructor
     * @param QueueableContext qc, overrides the execute method of the Queueable class
     */
    public virtual void execute(QueueableContext qc) {
        this.executeNext();
    }

    /**
     * @description: determines if there are chain elements
     */
    protected boolean isChained() {
        return this.chain != null;
    }
}