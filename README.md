# Homade Script
*My first experience in scripting*
## Context
After 2 months of my cybersecurity training at BeCode, I wanted to try to make a little script. As you know, for security reasons, when you go away from your computer, you have to lock it. It's a practice that everyone should learn. In fact, we have made a little game between us, and when someone leaves the room and forgets to lock their computer, we can mess up with it. So, I wanted a little tool that allows me to quickly mess with my peers.

## Mitre Att&ck

First of all, I needed to find a vulnerability that I can exploit. So, I found this topic on MITRE:

### [OS Credential Dumping](https://attack.mitre.org/techniques/T1003/)

This allows obtaining account login and credential material, normally in the form of a hash or a clear text password. Looking further into the topic, we can find a subtopic called:

### [Security Account Manager](https://attack.mitre.org/techniques/T1003/002/)

From the description, it seems pretty easy to exploit:

> Adversaries may attempt to extract credential material from the Security Account Manager (SAM) database either through in-memory techniques or through the Windows Registry where the SAM database is stored. The SAM is a database file that contains local accounts for the host, typically those found with the `net user` command. Enumerating the SAM database requires SYSTEM level access.

They also provide the commands to retrieve those files and the tools to use for reading them:

Commands:
-   `reg save HKLM\sam sam`
-   `reg save HKLM\system system`

Tools:
-   pwdumpx.exe
-   gsecdump
-   Mimikatz
-   secretsdump
## The Goal

So here, I want to be able to connect my USB stick to the unlocked device of one of my fellows, run the script, obtain the credentials, and leave. The point is not to stay behind his computer for too long. After retrieving the credentials, I aim to remotely connect to his device.


## The SCRIPT

 _Disclaimer_: Currently, the script needs to be launched manually as an administrator on an unlocked computer. Therefore, I store it on a USB stick.

The script is commented, so check it if you want more information.

**BASE SCRIPT**

1.  **Get the credential**: I use a USB stick to store both the SAM and SYSTEM files. To achieve this, I've written a script that creates a folder on the USB stick and copies the content of both files into it.
    
2.  **Get the IPconfig**: To enable a remote connection, I need to obtain the IP information and store it on the USB stick.
    

After a few tests, I discovered that I needed to make other changes on the device to gain remote access to it.

**ADD-ON**

 1.  **Firewall**:
    
    -   Disable the firewall
    -   Disable Firewall notifications (to avoid alerting the target)
    -   Open port 5985 (used for Windows Remote Management)
 2.  **Internet**: I found that if the internet setting on the device is set to PUBLIC, the script doesn't work. As a result, the script changes that parameter to PRIVATE.
    
 3.  **Allow remote Admin**
    
## In practice
**Physical**
 1. Plug USB stick
 2. Drag and drop the script on the desktop
 3. Run as admnistrator
 4. Delete the script from the device
 5. Unplug the USB stick

**Software**
_Now that I have the credentials, I need to exploit them. For that, I will use a Kali Linux device._

1. Use impacket with secretdump to read the content of the SAM and SYSTEM file. That gonna give the USER and the hashe PASSWORD associate to it.

   `impacket-secretsdump -sam sam.save -system system.save LOCAL`
    green = User | red = Hashe password

   ![](https://github.com/Mahgnislaw/OS-Credentials-Dumping/blob/main/img/Impacket.png)

3. Now with the hashe and the user it's possible to connect to the device for that we need to use evil-winrm.

	`evil-winrm -i "ipOfTheDevice" -u "userName" -H "hashePassword"`

And voila, normally you should be on the target device.

## Issues

1. In fact, there is a problem in the Physical part. To use WinRM, we have to activate Windows Remote Management on the target device. I tried to implement this step in my script to automate it, but I encountered an error when the script had to send an input to confirm with "Y". So, for the moment, I have to do it manually.

- Open a prompt as administrator
- run this command `winrm quickconfig`
- then press "y" and "y" again

2. When the script is launch from the USB stick it seems to corrupt the retrieve data
3. When the device is reboot the WinRM is disabled  
## 

