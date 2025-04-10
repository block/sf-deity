# sf-deity
`sf-deity` is a data-recovery testing solution presented by the Cash App Salesforce Team at Block. This tool allows a Salesforce team to simulate data loss at a massive scale to determine necessary remediation steps in the event of catastrophe. This tool introduces the use of a Queueable Jobs Framework (provided by `DX_QueueableJobChain.cls` and `DX_ChainedQueueable.cls`) that allows a developer flexibility surrounding the limits of the Queueable Interface provided by Salesforce by enqueueing the next job when the current job is completed.

## Recovery Simulation

### Disclaimer
This code will cause mass data loss through modification and hard deletion, and, as a result, there are failsafes to keep it from running in a production environment. This code should never be deployed to production. If you do run it in prod, like is the case with all Salesforce development, there will be a paper trail and there will likely be hefty consequences. That being said, make sure you have a backup solution in place before this code is run in a sandbox environment or be prepared to refresh from production. This code is recommended for use in a full or partial copy sandbox where development work is not completed so that it does not disrupt day to day operations.

### Tips and Lessons Learned
- Related sObjects and child sObjects will be corrupted if there are Master-Detail relationships or roll-up summary fields. This is expected.

- There may be automations or validations that prevent some records from being modified or deleted. **THIS IS A GOOD THING!** If you don't see exactly the number of records corrupted that you specified, it means your org is doing its job to prevent data loss.

- In order to fully restore records from a backup, all automations and validations will need to be turned off. This is achievable through a [hierarchical custom setting](https://help.salesforce.com/s/articleView?id=000384686&language=en_US&type=1). This remediation should be completed before running this tabletop exercise on a large scale.

- If there are picklist values on an sObject that are no longer used, they should be Deactivated rather than Deleted. This is so a backup service can restore historical data. If these picklist values are deleted, there will be an error on restore attempt.

- There are some sObjects, such as `FeedItem`, that do not allow for [aggregate queries](https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql_select_agg_functions.htm) per [SOQL Object Limits and Limitations](https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql_limits.htm). This functionality relies on an aggregate query, so these items are not corruptable.

- **NOT EVERYTHING CAN BE RESTORED.** Check with your backup provider to ensure that the sObjects you are testing against can be restored.

### How To Do It
After taking remediation steps, such as adding bypasses for automations and validation rules for the bot-user that your backup tool utilizes, you are ready to complete your tabletop exercise.

In order to complete this exercise, the running user must have Setup access in Sandbox, as well as the Author Apex permission to ensure Apex and necessary components can be deployed.

To deploy the code to a Sandbox environment, complete the following steps:

1. Ensure that [Git](https://git-scm.com/downloads), [Visual Studio Code](https://code.visualstudio.com/), the [Salesforce Extension Pack for VSCode](https://marketplace.visualstudio.com/items?itemName=salesforce.salesforcedx-vscode-expanded), and the [Salesforce CLI](https://developer.salesforce.com/tools/salesforcecli) and the Salesforce are installed and configured for Apex development.

2. Clone the repository via the following command in the desired directory, likely a directory away from your internal codebase to ensure that the code will not be promoted to production:
```
git clone https://github.com/block/sf-deity.git
```

3. Connect your VSCode to your desired Salesforce Sandbox via `CMD+ ShiFT + P` (`CTRL + SHIFT + P` on Windows) and selecting `SFDX: Authorize An Org`. The project will default to using `test.salesforce.com` as the default login.

4. Login to your desired Sandbox.

5. Run a validated deployment by issuing the following command:
```
sf project deploy validate --source-dir force-app
```

6. Depending on the size of your org and the average time to Run All Tests, this may take a while! As written, this code is designed to fail tests in Production, meaning this validation will fail in a Developer Edition Org.

7. If all goes well, there should be 11 Test Failures off the bat - this is expected. This is because we have not deployed and assigned the permissions necessary to run this code successfully. This is to ensure that there are multiple layers of protection against deploying and running this code in a production environment. The errors you should see should be along the lines of:
```
You do not have the permissions necessary to complete this action.
```

8. If you see an error about not running in prod: do not pass go, do not collect $200, stop what you're doing. This action can cause irreversible data loss, even if you have a backup solution.

9. Once you have validated and ensured that the only test failures are due to permissions, you are good to deploy with the following command:
```
sf project deploy start  --source-dir force-app
```

10. Assign the Permission Set `Corrupt Data Via SF-Deity` to the user that will be running the code (likely yourself) in the Salesforce UI. I recommend assigning with an expiration date of 1 week.

11. Revalidate with the following command to ensure that the 11 failed tests are now passing:
```
sf project deploy validate --source-dir force-app
```

12. Et voila. You are ready to configure!

13. Through the use of Salesforce Custom Metadata records on the `Data Corruption Object` CMDT, a developer can specify a number of Standard or Custom sObjects to corrupt, Standard or Custom number or text fields to corrupt on each sObject, whether to corrupt by deletion, modification, or a 50-50 split of each, and a percentage of each sObject to corrupt.
![Screenshot of Data Corruption Object custom metadata page.](https://github.com/user-attachments/assets/82ae40af-b6e6-47bb-ad9b-d048fc84a101)

14. For example, in the sample data as deployed, there are three Standard sObjects (`Account`, `Case`, and `Contact`) and one Custom sObject (`My_Custom_Object__c`). Note that the CMDT record requires leaving `__c` off of the custom sObject label per Salesforce API name requirements, so it is appended in the code based on whether the Custom Object box is checked. Also note that the `__c` is required on a custom field, as is indicated in the example metadata record.

15. Each of the example sObjects is currently specified to be corrupted by deletion and modification at 100% (with a 50-50 split between deletion and modification, as both options are selected). Only objects with the Active box checked will be corrupted, and they will be corrupted in the order specified in the Corruption Order field on the CMDT records, with nulls being corrupted last. After you have examined and noted the format of the example metadata records, you can modify or delete them.

16. Once you have deployed the folder structure and configured your Custom Metadata records, the code is ready to run.

17. In order to run the code, you will enter the following Anonymous Apex snippet, substituting your own email address:

```
new DX_DataCorruptionQueueableChain('your-email-address@yourcompany.com').runJob();
```
![Screenshot of Anonymous Apex Snippet.](https://github.com/user-attachments/assets/72b99a50-8843-449d-a68f-0b77a7eb0671)

18. Once each job is complete, you will receive an email notifying you that the job is complete so you don't have to keep checking your Apex Job Logs. In order to receive this email, ensure deliverability is on and there is a verified org-wide email address set. There is a risk of sending emails out when running any job, so ensure your org is compatible with turning on deliverability for the duration of this exercise.

19. Once the final job is complete, you are good to test your recovery tooling.

## Recognition
This project was recognized by [Own Company](https://www.owndata.com/) for their [Inaugural Innovator of the Year award in 2024](https://www.owndata.com/newsroom/own-company-honors-excellence-in-customer-saas-data-protection-and-activation-at-dreamforce-2024). It has since been iterated on and improved upon so other teams can prepare their orgs for the worst.

## Project Resources

| Resource                                   | Description                                                                    |
| ------------------------------------------ | ------------------------------------------------------------------------------ |
| [CODEOWNERS](./CODEOWNERS)                 | Outlines the project lead(s)                                                   |
| [CODE_OF_CONDUCT.md](./CODE_OF_CONDUCT.md) | Expected behavior for project contributors, promoting a welcoming environment  |
| [CONTRIBUTING.md](./CONTRIBUTING.md)       | Developer guide to build, chat, discuss, contribute, and file issues           |
| [LICENSE](./LICENSE)                       | Apache License, Version 2.0                                                    |
