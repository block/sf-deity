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
public class DX_DMLMockProvider implements System.StubProvider {
    /**
     * @description: constructor
     * @param Object stubbedObject
     * @param String stubbedMethodName
     * @param Type returnType
     * @param List<Type> listOfParamTypes
     * @param List<String> listOfParamNames
     * @param List<Object> listOfArgs
     * @return Object, the mocked object
     */
    public Object handleMethodCall(Object stubbedObject, String stubbedMethodName, Type returnType, List<Type> listOfParamTypes, List<String> listOfParamNames, List<Object> listOfArgs) {
        switch on stubbedMethodName {
            when 'updateRecords' {
                List<Case> casesInParams = (List<Case>) listOfArgs[0];
                List<Result> resultList = new List<Result>();

                for(Case cs : casesInParams) {
                    resultList.add(new Result(true, cs.Id));
                }
    
                transient List<Database.SaveResult> srList = (List<Database.SaveResult>) JSON.deserialize(JSON.serialize(resultList), List<Database.SaveResult>.class);
                return srList;
            } when 'deleteRecords' {
                List<Case> casesInParams = (List<Case>) listOfArgs[0];
                List<Result> resultList = new List<Result>();

                for(Case cs : casesInParams) {
                    resultList.add(new Result(true, cs.Id));
                }
    
                transient List<Database.DeleteResult> srList = (List<Database.DeleteResult>) JSON.deserialize(JSON.serialize(resultList), List<Database.DeleteResult>.class);
                return srList;
            } when else {
                return null;
            }
        }
    }

    /**
     * @description: wrapper for Database.XXResult mocking
     */
    private class Result {
        Private Boolean success;
        Private String id;

        private Result(Boolean success, String id) {
            this.success = success;
            this.id = id;
        }
    }
}