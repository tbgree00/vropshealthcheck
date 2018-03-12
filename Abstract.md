Purpose: Educating the audience on how to use vROps for time saving investigations of issues using automated manual troubleshooting with PowerCLI and/or custom reports.


## Automate Troubleshooting with vRealize Operations Manager

Imagine you are working on a project with a rapidly approaching deadline and you receive an alert. A critical VM has an issue that you must fix but will require investigation. VMware has developed VMware vRealize Operations Manager (vROps) to be a powerful tool for monitoring and troubleshooting. vROps becomes even more powerful when combined with PowerCLI, VMware's scripting language, and vRealize Log Insight, a tool to gather logs for quick analysis. In this session you will learn how to leverage vROps, Log Insight and PowerCLI to diagnose trouble VMs, how to transform your troubleshooting workflow into an automated runbook, and how to create an easy to consume report with clear results and suggestions to resolve the issue.

## Key Takeaways

* Use PowerCLI and vRealize Operations Manager to quickly diagnose trouble VMs
* Standardize your troubleshooting methodology with a simple starting point
* Create easily repeatable reports that clearly outline next steps
* Reduce time spent keeping the lights on by troubleshooting smarter, not harder




Notes and Reviewer FAQ (not for submission):

**Why did you use a script instead of built in tools?**
* I used a script because hyperic didn't suit my requirements at time of creation. With 6.6 the plugin is significantly better so I will investigate if the plugin and/or log insight can get event/application log and logs for linux if accepted.
* The script is also a way to leverage vRealize Operations Standard, since custom dashboards and reports aren't an option
