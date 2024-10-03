# Linux Administration Advanced

[[{storage.file_system,linux.101,02_doc_has.standards,01_PM.backlog]]
## Linux FS Hierarchy  
- Full FS Hierarchy
<https://www.tldp.org/LDP/Linux-Filesystem-Hierarchy/html/index.html>
- /etc
<http://www.tldp.org/LDP/Linux-Filesystem-Hierarchy/html/etc.html>
[[{storage.file_system}]]

## Tracing Systems and how they fit together
* <https://jvns.ca/blog/2017/07/05/linux-tracing-systems/> (Julia Evans)

## Foreman Server Lifecycle Mng. [[{]]
* <https://theforeman.org/introduction.html>
* <https://github.com/theforeman/foreman_bootdisk>
[[}]]

# FreeIPA Central Authentication
<https://www.freeipa.org/page/Main_Page>
- Manage Linux users and client hosts in your realm from one central location
  with CLI, Web UI or RPC access. Enable Single Sign On authentication for all
  your systems, services and applications.
- Policy
- Define Kerberos authentication and authorization policies for your
  identities. Control services like DNS, SUDO, SELinux or autofs.
- Trusts
- Create mutual trust with other Identity Management systems like Microsoft
  Active Directory.
</pre>

# SystemD Timers (alterantive to cron)

* <https://www.maketecheasier.com/use-systemd-timers-as-cron-replacement/>

# KVM/Qemu

Working with Virtual Machines <https://www.linux-kvm.org/>
- Managing Libvirt and KVM
- Installing a Virtual Machine
- Using virsh
- Using virt-manager
- Understanding KVM Networking
- Managing KVM Networking
- Importing OVF Virtual Machine Files
- KVM live migration <https://www.linux-kvm.org/page/Migration>
[[{security.backups]]

## Shared Lib management

* Linux Commands For Shared Library Management and Debugging Problems:
* <http://www.cyberciti.biz/tips/linux-shared-library-management.html>

# Ksplice
* <https://en.wikipedia.org/wiki/Ksplice>
See also:
 - kexec, a method for loading a whole new kernel from a running system
 - kGraft, kpatch and KernelCare, other Linux kernel live patching
   technologies developed by SUSE, Red Hat and CloudLinux, respectively





## KVM weekly backup, the easy way

* WARN: maybe oudated.

* PRESETUP: Start the KVM instance with the option -monitor telnet:127.0.0.1:9942 so that we can control 
  kvm through sockets.
  ```
  |#!/bin/bash
  | 
  | # Redirect stdout/stderr to custom log.
  | exec 1>> /var/log/custom_$(basename ${0}).$(whoami).$(date '+%Y%m%d').log 2>⅋1
  | pushd /media/backup/MyServer1/
  | # Keep copies of the VM for the last 4 weeks.
  | mv kvm.qemu.gz.1 kvm.qemu.gz.2
  | mv kvm.qemu.gz.0 kvm.qemu.gz.1
  | mv kvm.qemu.gz kvm.qemu.gz.0
  | 
  | # Stop KVM instance through telnet.
  | # KVM has to be started with the option:
  | # -monitor telnet:127.0.0.1:9942,server,nowait
  | echo "stop" | nc -q 10 127.0.0.1 9942 # Freeze KVM instance
  | 
  | #Here we do the real backup of the KVM instance
  | cat /VM_Images/kvm.qemu | gzip > /media/backup/MyServer1/kvm.qemu.gz
  | if [ $? != 0 ]; then
  | echo "WARN: KVM backup failed"
  | fi
  | echo "c" | nc -q 10 127.0.0.1 9942 # Continue KVM instance
  | popd
  ```
[[security.backups}]]

## Reference script to start KVM in /etc/rc.local:

  ```
  /etc/rc.local:
  | # Setting up the bridge (tip: apt-get install bridge-utils)
  | brctl addbr ofi1
  | brctl addif ofi1 eth1
  | ifconfig eth1 0.0.0.0 promisc up
  | ifconfig ofi1 192.168.2.100 netmask 255.255.0.0 up
  | ifconfig ofi1:1 172.16.1.3
  | 
  | ...
  | kvm -net nic,macaddr=52:54:00:19:34:56 \
  | -net tap,script=/etc/qemu-ifup -hda /VM-Images/kvm.qemu \
  | -boot c -vnc :5 1>/var/log/custom_kvm.qemu.log \
  | -monitor telnet:127.0.0.1:9942,server,nowait 2>⅋1 ⅋
  | ...
  | # ionice/renice down our virtual machine
  | PID=$(sof /VM-Images/kvm.qemu | grep -v ^COMMAND | while read cmd pid staff; do echo $pid; done)
  | ionice -c 3 -p ${PID} ⅋
  | renice 10 -p ${PID} ⅋
  | 
  | /etc/qemu-ifup:
  | #!/bin/sh
  | # ofi1 is the choosen name in /etc/rc.local
  | /usr/sbin/brctl addif ofi1 $1 ;
  | ifconfig $1 0.0.0.0 up;
  ```


## Spice Virtual Desktops

* <http://fedoraproject.org/wiki/Features/Spice>

  Spice aims to provide a complete open source solution
for interaction with virtualized desktops.

[[{scalability.storage]]
## block multi-queue
- kernel 3.13+
- block layer "blk-mq" introduces block multi-queue support,
  intended to meet the high IOPS requirements of SSDs:
  Cite (Jens Axobe):
  """the classic request_fn based driver doesn't work well enough
  (for big IOPS)
  Axboe The design is centered around per-cpu queues for queueing IO,
  which then funnel down into x number of hardware submission queues
[[scalability.storage}]]


## sharedroot

* <http://fedoraproject.org/wiki/Features/Opensharedroot>

The open sharedroot project provides abilities to boot multiple linux systems
with the same root filesystem providing a single system filesystem based
cluster. (NFS, GFS,...)

[[{storage.file_system.debug]]
## debugfs

* <https://linux.die.net/man/8/debugfs>
* ext2/ext3/ext4 file system debugger.
- It can be used to examine and change the state of an ext2, ext3, or 
  ext4 file system.
[[storage.file_system.debug}]]


[[{monitoring.storage,security.storage,troubleshooting.storage]]
## File Integrity Monitoring at scale

* <https://www.rsaconference.com/writable/presentations/file_upload/csv-r14-fim-and-system-call-auditing-at-scale-in-a-large-container-deployment.pdf>
[[monitoring.storage}]]



## Assign new IP to chrooted env

* <https://unix.stackexchange.com/questions/98808/how-to-assign-an-additional-ip-hostname-to-a-chrooted-environment>

## Hidding processes to other Users
* <http://www.cyberciti.biz/faq/linux-hide-processes-from-other-users/>

The hidepid option in the procfs defines how much info
about processes we want to be available for non-owners.

  ```
  hidepid=0 : (default old behavior), anybody may read
              all world-readable /proc/PID/* files</li>
  hidepid=1 : users may not access any /proc/ / directories,
              but their own.
              Sensitive files like cmdline, sched*, status
              are NOW protected against other users

  hidepid=2 : equals to hidepid=1 plus :
              - /proc/PID/  will be invisible to other users.
                It complicates intruder's task of gathering info
                about running processes, whether some daemon
                runs with elevated privileges, whether another user
                runs some sensitive program, whether other users run any
                program at all, etc.Linux kernel protection.
  ```
Example:
  ```
  | $ mount -o remount,rw,hidepid=2 /proc
  | Alternatively edit /etc/fstab:
  | proc  /proc  proc defaults,hidepid=2  0   0
  ```



[[{monitoring.latency]]
## DeviceKit-powerlatency control
* <https://blogs.gnome.org/hughsie/2008/11/06/devicekit-power-latency-control/>
Use cases:
* I want my IM application to request 0.5s latency for messages.
* I’m running an OpenGL simulation and want maximum performance, even 
  on battery.
* I’m running an SQL server for a credit card company, and want the 
  server to request low latency CPU and network as any delay costs 
  money.
* I’m an admin, and want to change the power consumption vs. latency 
from cron scripts so it uses high latency during the night for 
maximum power saving, and low latency during business hours.
* I want high throughput when copying files, but want low throughput 
for downloading updates in the background.
* I want my power manager to set all latencies to lowest when on AC 
power
* I don’t want my users messing with latency settings
* I’m and admin and I want to be able to override all latency 
  settings on my machines.
[[monitoring.latency}]]

[[{monitoring.energy]]
## uPower
* <https://upower.freedesktop.org/>

 UPower is an abstraction for enumerating power devices, listening to 
device events and querying history and statistics. Any application or 
service on the system can access the org.freedesktop.UPower service 
via the system message bus. Some operations (such as suspending the 
system) are restricted using PolicyKit.

  UPower was once called DeviceKit-power. UPower aims to make a large 
chunk of HAL redundant, as HAL is officially deprecated.

UPower is also useful to control the latency of different operations 
on your computer, which enables you to save significant amounts of 
power. Nothing much uses this interface yet, but this is a classic 
chicken and egg scenario, and I think it's important to encourage the 
egg to lay a chicken. Please report any problems to the Freedesktop 
bugzilla or send a mail to the DeviceKit mailing list for discussion.
[[monitoring.energy}]]

## Monit: Ligthweight watchdog
* <https://mmonit.com/monit/>
(Service Monitoring)
- With all features needed for system monitoring and error recovery. It's like
- How to install Monit and monitor the performance of your linux server:
  https://techarena51.com/blog/how-to-install-monit-monitoring-service-on-your-linux-vps-server/
- having a watchdog with a toolbox on your server

[[{monitoring.timechart]]
## Timechart: Zoom into OS (by Intel)
[[monitoring.timechart}]]
* <http://www.linux-magazine.com/Online/News/Timechart-Zoom-in-on-Operating-System>

Van de Ven, who also worked on the energy-saving tool Powertop, wants to
enhance tools such as Oprofile, LatencyTOP and Perf with Timechart.

  The new program provides graphical results, reminiscent of Bootchart,
in fact going beyond the boot process analysis tool used as its model by 
tying in all the other processes on the system.

## psmisc
* <http://psmisc.sf.net/>

## fuser
* identifies processes that are using files or sockets

## peekfd:
* shows data traveling over file descriptor

## prtstat: explain /proc/<pid>/stat

 ```
 | $ sudo prtstat 2192                            │ $ sudo prtstat -r 2192 
 |  Process: firefox    State: S (sleeping)       │         pid: 2192           comm: firefox
 |    CPU#:  2          TTY: 4:2    Threads: 66   │       state: S              ppid: 1682
 |  Process, Group and Session IDs                │        pgrp: 1362        session: 1362
 |    Process ID: 2192        Parent ID: 1682     │      tty_nr: 1026          tpgid: 1362
 |      Group ID: 1362       Session ID: 1362     │       flags: 404100       minflt: 1724794
 |    T Group ID: 1362                            │     cminflt: 1732825      majflt: 696
 |                                                │     cmajflt: 172           utime: 54521
 |  Page Faults                                   │       stime: 9116         cutime: 18023
 |    This Process    (minor major):  1724534 696 │      cstime: 3596       priority: 20
 |    Child Processes (minor major):  1732825 172 │        nice: 0       num_threads: 65
 |  CPU Times                                     │ itrealvalue: 0         starttime: 12236
 |    This Process    (user system guest blkio):  │       vsize: 94642585        rss: 100095
 |                       545.13  91.09 0.00 0.38  │ 
 |    Child processes (user system guest):        │      rsslim: 18446744  startcode: 94493428105216
 |   180.23  35.96 0.00                           │      rsslim: 18446744  startcode: 94493428105216
 |  Memory                                        │     endcode: 94493428 startstack: 140730047695840
 |    Vsize:       9464 MB                        │     kstkesp: 0           kstkeip: 0
 |    RSS:          410 MB                        │       wchan: 0             nswap: 0
 |    RSS Limit: 18446744073709 MB                │       wchan: 0             nswap: 0
 |    Code Start:  0x55f0f7374000                 │      cnswap: 0       exit_signal: 17
 |    Code Stop:  0x55f0f739ff5d                  │      cnswap: 0       exit_signal: 17
 |    Stack Start: 0x7ffe44808be0                 │   processor: 1       rt_priority: 0
 |    Stack Pointer (ESP):  0                     │      policy: 0 delayaccr_blkio_ticks: 38
 |    Inst Pointer (EIP):   0                     │  
 |  Scheduling                                    │  guest_time: 0       cguest_time: 0
 |    Policy: normal                              │
 |    Nice:   0          RT Priority: 0 (non RT)  │
 ```

[[{security.forensic]]
## Dump process memory in real time
* <http://www.forensicswiki.org/wiki/Tools%3aMemory_Imaging#Linux>
[[security.forensic}]]

[[{troubleshooting.locks]]
## flock: Check locked files
* <http://www.linuxask.com/questions/how-to-check-if-a-file-is-locked-in-linux>
* Suppose a file test.txt is being locked by a program, e.g. using the 
  flock system call, how can we know if this file is really being 
  locked?
* man 2 flock
  ```
  $ sudo lsof test.txt
  COMMAND  PID USER  FD TYPE DEVICE SIZE NODE NAME
  perl    5654 john 3uW REG     8,1    1 9837 test.txt
                      ^
  W means the file is currently held by an exclusive lock.
  ```
[[troubleshooting.locks}]]

### File locks per directory

* <http://unix.stackexchange.com/questions/22120/how-to-trace-file-locks-per-directory>

  Make sure that the auditd daemon is started, then use auditctl to 
configure what you want to log. For ordinary filesystem accesses, you 
would do:

  ```
  $ auditctl -w /path/to/directory
  $ auditctl -a exit,always \
    -S fnctl -S open -S flock -F dir=/path/to/directory
  ```

The -S option can be used to restrict the logging to specific syscalls.

The logs appear in /var/log/audit/audit.log on Debian, and probably on Fedora as well.


[[{desktop.GUI_stack]]
## A tour of the Linux Graphics Stack
* <http://cworth.org/talks/lca_2009/html/lca-2009-001.html>
[[desktop.GUI_stack}]]


[[{troubleshooting.sysrq]]
[[troubleshooting.sysrq}]]
## Magic SysRq Keyboard keys
* <http://en.wikipedia.org/wiki/Magic_SysRq_key>

The magic SysRq key is a key combination understood by the Linux kernel,
which allows the user to perform various low-level commands regardless of the
system's state. It is often used to recover from freezes, or to reboot a
computer without corrupting the filesystem.[1] Its effect is similar to the
computer's hardware reset button (or power switch) but with many more options
and much more control.


## ConsoleKit
ConsoleKit is a framework for keeping track of the various users, 
sessions, and seats present on a system. It provides a mechanism for 
software to react to changes of any of these items or of any of the 
metadata associated with them.


[[{security.backups]]
## Data Recovery
- Using TCT To Recover Lost Data On Linux Or Unix:
<http://linuxshellaccount.blogspot.com/2009/05/using-tct-to-recover-lost-data-on-linux.html>
[[security.backups}]]

## Attach Interrupt to CPU, Real-time processes

* <https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_MRG/1.3/html/Realtime_Tuning_Guide/sect-Realtime_Tuning_Guide-General_System_Tuning-Interrupt_and_Process_Binding.html>

[[{monitoring.memory]]
## smem: Accurate physical memory usage

  ```
  | $ sudo slabtop
  | $ sudo apt-get install smem python-matplotlib python-tk # deb like
  | $ sudo yum install smem python-matplotlib               # rpm like
  | $ sudo smem     # -u to view per-user memory.
  ```
* <Ref: http://xmodulo.com/visualize-memory-usage-linux.html>

  In the presence of virtual memory abstraction, accurately 
quantifying physical memory usage of a process is actually not 
straightforward:
1. virtual memory size of a process is not meaningful. It does
   not tell how much of it is actually allocated physical memory.
2. Resident set size (RSS), as reported by top, is a  popular
   metric to capture what portion of a process's reported memory
   is residing in RAM.<br/>
   However, aggregating RSS of existing processes can easily
   overestimate the overall physical memory usage of the Linux
   system because the same physical memory page can be shared 
   by different processes.
3. Proportional set size (PSS) is a more accurate measurement of
   effective memory usage of Linux processes since PSS properly
   discounts the memory page shared by more than one process.
4. Unique set size (USS) of a process is a subset of the
   process' PSS, which is not shared by any other processes.

`smem` tool can generate a variety of reports related to memory 
PSS/USS usage by pulling information from /proc.
  It comes with built-in graphical chart generation

[[monitoring.memory}]]

## Linux input ecosystem
* <http://joeshaw.org/2010/10/01/681>

[[{profiling.blocking,troubleshooting.locks]]
## Monit uninterruptible(blocking) system calls

- KISS script to list any process that could have trouble beeing 
  blocked by an uninterruptible system call.

  ```
  | while true; do ps -e fo stat,cmd | grep ^D && echo "-------"; sleep 0.1 ; done
  |
  | D< └─ [scsi_eh_0]
  | D      └─ hald─addon─storage: polling /dev/sr0 (every 2 sec)
  |     
  | D      └─ hald─addon─storage: polling /dev/sr0 (every 2 sec)
  |     
  | D< └─ [md0_raid1]
  | D< └─ [kjournald]
  |     
  | D< └─ [md0_raid1]
  |     
  | D< └─ [md0_raid1]
  |     
  | D< └─ [md0_raid1]
  | 
  | output in this example is normal [md0_raid1],kjournald and syslogd are 
  | making frequent disk writes.
  ```
[[profiling.blocking,troubleshooting.locks}]]

## About futexes (Fast mutex)
* <https://opensourceforu.com/2013/12/things-know-futexes/>

## linux bft filters kernwl 4.14+

## Netlink
* <https://en.wikipedia.org/wiki/Netlink>

## jls09
* <https://events.static.linuxfound.org/images/stories/slides/jls09/jls09_ikeda.pdf>

## Linux-5.2 Turning On GCC9 for Live patching.

* <https://www.phoronix.com/scan.php?page=news_item&px=Linux-5.2-Turning-On-GCC9-LP>

Linux 5.2 To Enable GCC 9's Live-Patching Option, Affecting Performance In Select Cases


[[{performance.network.BBR,network.tunning]]
## Increase server speed with kernel TCP BBR

* <https://www.reddit.com/r/linuxadmin/comments/bapwd4/increase_server_speed_with_kernel_tcp_bbr/>

* This CRAZY kernel feature increased the wget average of my VPS from 
  349KB/s to 1.47MB/s! Increase your Linux server Internet speed with 
  TCP BBR congestion control.

* <https://www.cyberciti.biz/cloud-computing/increase-your-linux-server-internet-speed-with-tcp-bbr-congestion-control/>

p.s. Here's a simple bash script for easy setup of TCP BBR:

* <https://gist.github.com/sammdu/668070b486832f47f3b0da2200a7954f>
[[performance.network.BBR}]]

[[{peformance.101]]
## Linux Performance Tunning 101
Look for:
- wrong I/O scheduler
- wrong filesystem
- wrong journaling
[[peformance.101}]]


[[{PM.low_code,configuration.boot.cobbler]]
## Cobbler "Advanced PXE" network installs

* PXE: most common way to do network booting.
* PXE requires setup of a TFTP server and DHCP configuration.
* PXE is not viable in some situations due to external constraints
  (no control over DHCP, home installations, ...)
* For virtualization technology (Xen, KVM), other fully automatic
  installation solutions are required.


* Cobbler: universal boot server that sets up everything you need 
for software installation–PXE, reinstalls, and virtualization.

* You can set up a Cobbler boot server for your favorite distros in just a 
few minutes. 
[[PM.low_code}]]

[[{]]
## Set up PXE boot for UEFI hardware

* <https://www.redhat.com/sysadmin/pxe-boot-uefi>
 Setting up a PXE system will streamline new system installs, but the
process is lengthy and requires attention to detail. This part one of
two articles walks you through the process.
[[}]]

[[{virtualization.101]]
## What is Hypervisor Memory Ballooning? 
https://www.enterprisestorageforum.com/storage-hardware/memory-ballooning.html

By Sean Michael Kerner

Memory ballooning is all about enabling virtual machine memory
to scale up if there is a requirement to do so. 

"balloon drivers" runs across virtual machines and enable a 
hypervisor to reallocate memory from one virtual machine to another.

With memory ballooning, memory is taken from virtual machines that 
aren’t currently using all available memory, with the unused memory 
reallocated to a virtual machine that requires the additional 
resources.

ballooning problems that can occur is high utilization. 
... If multiple running virtual machines request balloon memory simultaneously,
there can be a CPU and physical disk usage spikes
[[virtualization.101}]]


[[{scalability.logging.eBPF,scalability.monitoring,kernel.eBPF]]
## How Netflix uses eBPF flow logs at scale for network insight

* <https://netflixtechblog.com/how-netflix-uses-ebpf-flow-logs-at-scale-for-network-insight-e3ea997dca96>

  Netflix has developed a network observability sidecar called Flow
Exporter that uses eBPF tracepoints to capture TCP flows at near real
time. At much less than 1% of CPU and memory on the instance, this
highly performant sidecar provides flow data at scale for network
insight.
[[scalability.logging.eBPF}]]
