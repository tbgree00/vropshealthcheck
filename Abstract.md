# Reduce Mean Time to Innocence with vRealize Operations Heath Check Script

It's 4:55pm on Friday when a coworker arrives at your door tasking "Can you check out this VM for me?". Whether the issue is poor performance, a hung service, or an application error, VMware vSphere is a great place to find authoritative data and logging. VMware vRealize Operations Manager (vROps) is a powerful tool for monitoring, optimizing, and right sizing an environment but sometimes navigating the interface can take longer than you want to wait. To combat this assault on my weekends, I developed the vROps health check script. I was able to reduce the time to gather usage statistics, configuration, and event logs from 30 minutes into seconds using only PowerCLI and Powershell. With PowerCLI 10.0, vROps 6.6, and vRealize Log Insight the process becomes even more efficient. When the weekend is moments away, every second counts.

## Key Takeaways

* Use PowerCLI and vRealize Operations Manager to quickly diagnose trouble VMs
* Standardize your troubleshooting methodology With a simple starting point
* Create easily repeatable reports that clearly outline next steps
* Reduce Mean Time to Innocence by troubleshooting smarter, not harder
