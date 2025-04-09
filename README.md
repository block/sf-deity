# sf-deity
`sf-deity` is a data-recovery testing solution presented by the Cash App Salesforce Team at Block. This tool allows a Salesforce team to simulate data loss at a massive scale to determine necessary remediation steps in the event of catastrophe. This tool introduces the use of a Queueable Jobs Framework (provided by `DX_QueueableJobChain.cls` and `DX_ChainedQueueable.cls`) that allows a developer flexibility surrounding the limits of the Queueable Interface provided by Salesforce by enqueueing the next job when the current job is completed.

## Recovery simulation

### Disclaimer
This code will cause mass data loss through modification and hard deletion, and, as a result, there are failsafes to keep it from running in a production environment. This code should never be deployed to production. If you do run it in prod, like is the case with all Salesforce development, there will be a paper trail and there will likely be hefty consequences. That being said, make sure you have a backup solution in place before this code is run in a sandbox environment or be prepared to refresh from production. This code is recommended for use in a full or partial copy sandbox where development work is not completed so that it does not disrupt day to day operations.

### Tips and Lessons Learned
- Related sObjects and child sObjects will be corrupted if there are Master-Detail relationships or roll-up summary fields. This is expected.
- There may be automations or validations that prevent some records from being modified or deleted. THIS IS A GOOD THING! If you don't see exactly the number of records corrupted that you specified, it means your org is doing its job to prevent data loss.
- In order to fully restore records from a backup, all automations and validations will need to be turned off. This is achievable through a [hierarchical custom setting](https://help.salesforce.com/s/articleView?id=000384686&language=en_US&type=1). This remediation should be completed before running this tabletop exercise.
- If there are picklist values on an sObject that are no longer used, they should be Deactivated rather than Deleted. This is so a backup service can restore historical data. If these picklist values are deleted, there will be an error on restore attempt.
- There are some sObjects, such as `FeedItem`, that do not allow for [aggregate queries](https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql_select_agg_functions.htm) per [SOQL Object Limits and Limitations](https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql_limits.htm). This functionality relies on an aggregate query, so these items are not corruptable.
- NOT EVERYTHING CAN BE RESTORED. Check with your backup provider to ensure that the sObjects you are testing against can be restored.

### How To Do It
After taking remediation steps, such as adding bypasses for automations and validation rules for the bot-user that your backup tool utilizes, you are ready to complete your tabletop exercise.

Through the use of Salesforce Custom Metadata records on the `Data Corruption Object` CMDT, a developer can specify a number of Standard or Custom sObjects to corrupt, Standard or Custom number or text fields to corrupt on each sObject, whether to corrupt by deletion, modification, or a 50-50 split of each, and a percentage of each sObject to corrupt.

![Screenshot of Data Corruption Object custom metadata page.](https://github.com/user-attachments/assets/82ae40af-b6e6-47bb-ad9b-d048fc84a101)

For example, in the sample data as deployed, there are three Standard sObjects (`Account`, `Case`, and `Contact`) and one Custom sObject (`My_Custom_Object__c`). Note that the CMDT record requires leaving `__c` off of the custom sObject label per Salesforce API name requirements, so it is appended in the code based on whether the Custom Object box is checked. Each of these sObjects is currently specified to be corrupted by deletion and modification at 100% (with a 50-50 split between deletion and modification, as both options are selected). Only objects with the Active box checked will be corrupted, and they will be corrupted in the order specified in the Corruption Order field on the CMDT records, with nulls being corrupted last.

Once you have deployed the folder structure and configured your Custom Metadata records, the code is ready to run.

In order to run the code, you will enter the following Anonymous Apex snippet, substituting your own email address:

```
new DX_DataCorruptionQueueableChain('your-email-address@yourcompany.com').runJob();
```

![Screenshot of Anonymous Apex Snippet.](https://github.com/user-attachments/assets/72b99a50-8843-449d-a68f-0b77a7eb0671)

Once each job is complete, you will receive an email notifying you that the job is complete so you don't have to keep checking your Apex Job Logs.

## Recognition
This project was recognized by [Own Company](https://www.owndata.com/) for their [Inaugural Innovator of the Year award in 2024](https://www.owndata.com/newsroom/own-company-honors-excellence-in-customer-saas-data-protection-and-activation-at-dreamforce-2024). It has since been iterated on and improved upon so other teams can prepare their orgs for the worst.

## Project Resources

| Resource                                   | Description                                                                    |
| ------------------------------------------ | ------------------------------------------------------------------------------ |
| [CODEOWNERS](./CODEOWNERS)                 | Outlines the project lead(s)                                                   |
| [CODE_OF_CONDUCT.md](./CODE_OF_CONDUCT.md) | Expected behavior for project contributors, promoting a welcoming environment  |
| [CONTRIBUTING.md](./CONTRIBUTING.md)       | Developer guide to build, chat, discuss, contribute, and file issues           |
| [LICENSE](./LICENSE)                       | Apache License, Version 2.0                                                    |
