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
public without sharing class DX_IdMocker {
	private static Integer idsGenerated = 0;

    /**
     * @description: gets a mock id for a given sobject
     * @param SObject sObj
     */
    public static Id getMockId(SObject sObj) {
        return getMockId(sObj.getSObjectType());
    }

    /**
     * @description: gets a mock id for a given sobject type
     * @param SObjectType sObjType
     */
    public static Id getMockId(SObjectType sObjType) {
        idsGenerated++;
        String keyPrefix = String.valueOf(sObjType.getDescribe().getKeyPrefix());
        String idsGenStr = String.valueOf(idsGenerated);

        return Id.valueOf(keyPrefix + '0'.repeat(12-idsGenStr.length()) + idsGenStr);
    }
}