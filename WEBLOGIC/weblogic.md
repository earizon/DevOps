# WebLogic Random Admin Notes

```
Admin Server:  
URL: <http://127.0.0.1:7001> user: weblogic; Pass: weblogic
     <http://127.0.0.1:7001/console/console.portal?_nfpb=true&_pageLabel=HomePage1>
```

## WLST (weblogic scripting tool) admin cli 

REFs:
* <http://docs.oracle.com/cd/E15523_01/nav/wls.htm>
* Introduction: <http://docs.oracle.com/cd/E15523_01/web.1111/e13752/toc.htm>

* System administration of a WebLogic Server environment includes 
  tasks such as:
  * creating WebLogic Server domains:
    * Domain: logically related group of server resources managed as a unit.
      * Server Resources include: 1+ WebLogic Servers, 0+ WebLogic Server clusters.
      * One of the server-instances in the Domain is configured as an
        Administration Server, providing a central point for managing the 
        domain and hosting the Administration Console.
      * All other server-instances in a domain are called Managed Servers.
      * If there is only a single WebLogic Server instance, it functions both 
        as Administration Server and Managed Server. 

  * deploying applications.
  * migrating domains from development to production environments.
  * monitoring and configuring the performance of the WebLogic Server domain.
  * diagnosing and troubleshooting problems.

Sys.Admin tools includes:

1. Web browser-based Administration Console, frequently used to:
   1. Configure, start, and stop Server instances and Server clusters
   1. Configure Server services, such as database connectivity (JDBC) and messaging (JMS)
   1. Configure security parameters, including managing users, groups, and roles.
   1. Configure and deploy your applications.
   1. Monitor server and application performance.
   1. View server and domain log files.
   1. View application deployment descriptors.
   1. Edit selected run-time application deployment descriptor elements.
2. WebLogic Scripting Tool (WLST). for automation.
   * based on Jython

3. SNMP, the Configuration Wizard,
4. Command-line utilities. 


```
Domain name: base_domain
Domain location: C:\Oracle\Middleware\user_projects\domains
user name: weblogic (Default administrator)
user passwd: ...

c:\Oracle\Middleware\jrockit_160_14_R27.6.5-32             <·· JRockit SDK 1.6.0_14
c:\Oracle\Middleware\wlserver_10.3\comon\templates\wls.jar <·· Template for Basic "Server-Domain"
C:\Oracle\Middleware\user_projects\domains\base_domain     <·· Domain Location. 
└─────────────────────┬──────────────────────────────────┘
Ref: http://docs.oracle.com/cd/E15523_01/web.1111/e13752/toc.htm
```

* Development Mode (Utilize boot.propertires for username and password
  and poll for applications to deploy)


## Enable/Disable Web Admin. Console with WLST


  ```python
  | Example 1. enable/disable the Console
  |   connect("username","password")
  |   edit()
  |   startEdit()
  |   cmo.setConsoleEnabled(true)         // <·· enable / disable
  |   save()
  |   activate()
  |   | > The following attribute(s) have been changed on MBeans which require server re-start.
  |   | > MBean Changed : com.bea:Name=mydomain,Type=Domain Attributes changed : 
  |   | > ConsoleEnabled
  |   | > Activation completed
  |   disconnect()
  |   exit()
  ```

[[{doc_has.comparative]]
## war vs ear deployment?

* <https://stackoverflow.com/questions/1364273/when-is-it-appropriate-to-use-an-ear-and-when-should-your-apps-be-in-wars>

* package multiple WARs into an EAR when ...
  you have a common set of library JARs with similar "deployment life cycle"
  shared by different WARs, specially if they are "big" JARs.

* Package as isolated WARs for "micro-service" like deployments (with
  WARs having different "deployment life cycles".<br/>
  NOTE: Ussually "shared" configuration complexity in a single EARs 
  is "moved" to extra configuration complexity by the application server
  (that will need to pre-setup and configure JDBC/... jars that 
   an EAR commonly pre-packages).<br/>
  **PROBLEM**: When avoiding EARs, a standard application server 
  cannot be used, needing for system side customizations ...  the
  web application is bleeding all over the system. The person
  who maintains the Application server, now MUST also know 
  application specific details... in an enterprise environment, 
  this presents a very clear problem ...  developers can then take
  on system responsibility, but they still need to meet deadlines.
   They inevitably bleed all over the OS as well, and suddenly the
   developers are the only possible admins...  If an admin doesn't
  know what the application is using system side, they can very much
  cause major problems. These unclear lines always end in fingers 
  pointing in both directions, unknown system states, and team 
  isolation.
[[{PM.RISK}]]

[[doc_has.comparative}]]

 
## WLST by Examples: Restarting 24 x 7 Domain with WLST
 
* <http://wlstbyexamples.blogspot.com.es/2010/02/restarting-24-x-7-domain-with-wlst.html#.Vx4qKbGNiCo>

... what all servers need to stop? when to stop?  ... only a few sites requires 24x7 HA. 

... strategy:  every time you run few servers can be stopped from different physical locations.
...  when starting them up then only next round of managed servers can be stopped.
... 2 scripts ... 2 phases one by one can be done with user input. 
This module named as 'regularStop()', which supports 24x7 HA domain.

most of the Production deployments are in nostage mode: a new version release of
application code requires complete domain down option requirement ...  This is
another module ('releaseStop()') take cares where it will stop all clusters in 
the domain should be passed.
...then I found that there is need of server state or cluster state when it
is given shutdown command. 
.. Finally by performing releaseStop() or RegularStop() we can go for stopping
the Admin Server.
<!-- { -->
  ```python

  | # To be run with weblogic.jar in the CLASSPATH, like
  | # $ java weblogic.WLST StopWLDomain.py
  | #====================================
  | #====================================
  | # Script File: StopWLDomain.py
  | # This module is for 24x7  Domainºººº
  | # First phase stops few managed servers of few sites
  | # Second phase will be used for stop remaining servers
  | # Note that Second phase allowed only when you press 'y'
  | # before that you need to Start all the Phase 1 stopped servers.
  | #====================================
  | def conn():
  |  try:
  |   connect(user, passwd, adminurl)
  |  except ConnectionException,e:
  |   print '\033[1;31m Unable to find admin server...\033[0m'
  |   exit()
  |  
  | #====================================
  | # Stop all instances of a Cluster
  | #====================================
  | def stopClstr(clstrName):
  |  try:
  |   shutdown(clstrName,"Cluster")
  |   state(clstrName,"Cluster")
  |  except Exception, e:
  |   print 'Error while shutting down cluster ',e
  |   dumpStack()
  |   return
  |  
  | #====================================
  | # All the instances of all Clusters will be down for release
  | #====================================
  | def releaseStop():
  |  clstrList=["webclstr1", "webclstr2'..."ejbclstr"]
  |  for clstr in clstrList:
  |   stopClstr(clstr)
  |  
  | #====================================
  | # Stop a instances given as parameter
  | #====================================
  | def stopInst(iservr):
  |  try:
  |   state(str(iservr))
  |   shutdown(str(iservr), 'Server',force="true")
  |   state(str(iservr))
  |  except Exception, e:
  |   print iservr, 'is having error in shutting down'
  |   pass
  |  
  | #====================================
  | # Regular Rstart is 24x7 supported for :SITE1, SITE2, SITE3
  | #====================================
  | def regularStop():
  |  clstrList=["non247clstr1", "non247clstr2"]
  |  for clstr in clstrList:
  |   stopClstr(clstr)
  |  servrList=servrList=["app1","app2","app3"... "web1","web2"] #sitewise list of servers need to stop
  |  for inst in servrList:
  |   stopInst(inst)
  |  print 'Now, please start the instances exclude the phase 2 instances ...'
  |  phase2=raw_input("Want to proceed for Phase 2...(y/n)")
  |  if phase2 == 'y':
  |   serverList=["app4","web3"...] # remaining Managed Servers to stop after phase servers UP n Running
  |   for inst in serverList:
  |    stopInst(inst)
  |  
  | #====================================
  | # Exiting the script
  | #====================================
  | def quit():
  |  disconnect()
  |  exit()
  |  
  | #====================================
  | # The main script starts here...
  | #====================================
  | if __name__ == "main":
  |  conn()
  |  print ' 1. Regular Stop (24x7)\n 2. Release Stop\n 0. Quit\n'
  |  sAns=raw_input('Enter your choice: ')
  |  if int(sAns) == 1:
  |  regularStop()
  |  elif int(sAns) == 2:
  |  releaseStop()
  |  elif int(sAns)== 0:
  |  quit()
  |  else:
  |  print 'Warning: Invalid option...'
  |  exit()
  |  print 'Finally stopping admin now...'
  |  shutdown()
  |  
  | #========WLST=BY=EXAMPLES==============
  ```python
<!-- } -->
