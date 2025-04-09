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

public virtual class DX_Query {
    @TestVisible static void setMock(Service mock) { instance = mock; }
    static Service instance = new Service();

    public static List<SObject> records(List<SObject> records)
    {
        return instance.passThrough(records);
    }

    public virtual class Service
    {
        protected virtual List<SObject> passThrough(List<SObject> records)
        {
            return records;
        }
    }
}