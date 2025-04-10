public with sharing class DX_DataCorruptionChecker {
    @TestVisible public static Boolean isSandbox = [SELECT Id, IsSandbox FROM Organization LIMIT 1].isSandbox;
    @TestVisible public static Boolean isRunningTest = Test.isRunningTest();
    @TestVisible public static Boolean hasPermission = FeatureManagement.checkPermission('Corrupt_Data');

    /**
     * @description: checks if user has requisite perms and ensures code is in sandbox
     */
    public static Boolean canRun() {
        if(!isSandbox) {
            throw new DX_DataCorruptionQueueableChain.DataCorruptionException('This code should not be run in a production environment. This action will cause mass data loss.');
        }
                
        if(!hasPermission) {
            throw new DX_DataCorruptionQueueableChain.DataCorruptionException('You do not have the permissions necessary to complete this action.');
        }

        return isSandbox && hasPermission;
    }
}