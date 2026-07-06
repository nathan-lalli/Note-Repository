## Authentication Types

Main Authentication Types:
* WEP
* WPA
* WPA2
* WPA3

Authentication Sub-Types:
* WPA2-PSK/WPA2-Personal
* WPA2-Enterprise
	* EAP-TTLS/PAP
	* PEAP-MSCHAPv2
	* EAP-TLS
	* Certificate-Based Authentication
* WPA3-Enterprise
	* EAP-TLS
	* Certificate-Based Authentication
* WPA3-SAE/WPA3-Personal

WEP (Wired Equivalent Privacy): 
	The original Wi-Fi security protocol. Provides basic encryption but is outdated and easy to breach.

WPA (Wi-Fi Protected Access):
	An interim improvement over WEP. Offers better encryption through TKIP (Temporal Key Integrity Protocol). Still less secure than newer options.

WPA2 (Wi-Fi Protected Access 2): 
	Advancement of WPA. Uses AES (Advanced Encryption Standard) for robust security.

WPA3 (Wi-Fi Protected Access 3): 
	The latest standard. Enhances security with individualized data encryption and more robust password-based authentication. Most secure option currently available.

## Components to Testing

Four key components to Wi-Fi penetration testing:
* Assessing passphrases for strength and security
* Analyzing configuration settings to identify vulnerabilities
* Probing the network infrastructure for weaknesses
* Testing client devices for potential security flaws

Evaluating Passphrases:
	Assess the strength and security of Wi-Fi network passwords or passphrases. Employ techniques like dictionary attacks, brute force attacks, and password cracking tools.

Evaluating Configuration:
	Analyze the configuration settings of Wi-Fi routers and access points to identify potential security vulnerabilities. Includes scrutinizing encryption protocols, authentication methods, network segmentation, and other config parameters to ensure they are secure.

Testing the Infrastructure:
	Focuses on probing the robustness of the Wi-Fi network infrastructure. Comprehensive assessment to uncover weaknesses in network architecture, device configurations, firmware versions, and implementation flaws that could be exploited to compromise the network.

Testing the Clients:
	Evaluate the security posture of the Wi-Fi clients - laptops, smartphones, and IoT devices, that connect to the network. Test for vulnerabilities in the client software, operating systems, wireless drivers, and network stack implementations to identify possible entry points.

## 802.11 Frames and Types

Need to understand the different 802.11 frames and types to be able to craft/forge for attacks. 

### IEEE 802.11 MAC Frame

All 802.11 Frames utilize the MAC frame. It is the foundation for all other fields and actions. The MAC data frame consists of 9 fields.


| Field         | Description                                                                                                                                                                                            |
| ------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Frame Control | Contains information such as type, subtype, protocol version, to DS (Distribution System), from DS, Order, etc.                                                                                        |
| Duration/ID   | This ID clarifies the amount of time in which the wireless medium is occupied.                                                                                                                         |
| Address 1     | Clarifies the MAC addresses involved in the communication. Could mean different things depending on the origin of the frame. Tend to include the BSSID of the access point and the client MAC address. |
| Address 2     | Clarifies the MAC addresses involved in the communication. Could mean different things depending on the origin of the frame. Tend to include the BSSID of the access point and the client MAC address. |
| Address 3     | Clarifies the MAC addresses involved in the communication. Could mean different things depending on the origin of the frame. Tend to include the BSSID of the access point and the client MAC address. |
| Address 4     | Clarifies the MAC addresses involved in the communication. Could mean different things depending on the origin of the frame. Tend to include the BSSID of the access point and the client MAC address. |
| SC            | Sequence Control field, allows additional capabilities to prevent duplicate frames.                                                                                                                    |
| Data          | Responsible for the data that is transmitted from the sender to the receiver.                                                                                                                          |
| CRC           | Cyclical Redundancy Check, contains a 32-bit checksum for error detection.                                                                                                                             |

### IEEE 802.11 Frame Types

There are different categories for frames based on what they do and what actions that they are involved in.

Management (00):
	Used for management and control, allowing the access point and client to control the active connection.

Control (01):
	Used for managing the transmission and reception of data frames within the Wi-Fi networks. Basically quality control.

Data (10):
	Used to contain data for transmission.

#### Management Frame Sub-Types

Management frames are the main focus for Wi-Fi penetration testing. 

Beacon Frames:
	Primarily used by the access point to communicate its presence to the client or station.

Probe Requests and Responses:
	Process exists to allow the client to discover nearby access points.

Authentication Request and Response:
	Sent by the client to the access point to begin the connection process. Primary used to identify the client to the access point.

Association/Reassociation Requests:
	After sending an authentication request and undergoing the authentication process, the client sends an association request to the access point. The access point then responds with an association response to indicate whether the client is able to associate with it or not.

Disassociation/De-authentication Frames
	Sent from the access point to the client. Designed to terminate the connection between the access point and the client. Additionally contain what is known as a reason code, which indicates why the client is being disconnected from the access point. Utilize crafting these frames for many handshakes captures and denial of service based attacks.

## Connection Cycle

This cycle covers the basic WPA2 authentication, it may vary depending on the Wi-Fi standard in use.

1. Beacon Frames
2. Probe Request and Response
3. Authentication Request and Response
4. Association Request and Response
5. Some form of handshake or other security mechanism
6. Disassociation/De-authentication

### Wireshark Filters

Beacon Frame

```Wireshark
(wlan.fc.type == 0) && (wlan.fc.type_subtype == 8)
```

Probe Request Frame

```Wireshark
(wlan.fc.type == 0) && (wlan.fc.sub_type == 5)
```

Authentication Process

```Wireshark
(wlan.fc.type == 0) && (wlan.fc.sub_type == 11)
```

Station Association Request

```Wireshark
(wlan.fc.type == 0) && (wlan.fc.sub_type == 0)
```

Access Point Association Response

```Wireshark
(wlan.fc.type == 0) && (wlan.fc.sub_type == 1)
```

EAPOL (handshake) Frames

```Wireshark
eapol
```

Termination of the connection

```Wireshark
(wlan.fc.type == 0) && (wlan.fc.sub_type == 12)
```

```Wireshark
(wlan.fc.type == 0) && (wlan.fc.sub_type == 10)
```

## Authentication Methods

There are two primary authentication systems commonly used in Wi-Fi networks.
1. Open System Authentication
2. Shared Key Authentication

Open System Authentication:
	Straightforward and does not require any shared secret or credentials for initial access. Typically used in open networks where no password is needed, allowing any device to connect to the network.

Shared Key Authentication:
	Involved the use of a shared key. Both the client and the access point verify each other's  identities by computing a challenge-response mechanism based on the shared key.

Other methods do exist, especially in enterprise environments or with advanced protocols like WPA3 and Enhanced Open. 

### Open System Authentication

Connection Process:
1. The client (station) sends an authentication request to the access point to begin the authentication process.
2. The access point then sends the client back an authentication response, which indicates whether the authentication was accepted.
3. The client then sends the access point an association request.
4. The access point then responds with an association response to indicate whether the client can stay connected.

### Shared Key Authentication

Shared Key Authentication Methods:


|                       | WEP            | WPA           | 802.11i/WPA2  |
| --------------------- | -------------- | ------------- | ------------- |
| Authentication Method | Pre-Shared Key | PSK or 802.1x | PSK or 802.1x |
| Encryption            | RC4            | TKIP          | AES           |
| Message Integrity     | CRC-32         | MIC           | CCMP          |
| Security              | Weak           | Strong        | Stronger      |

Authentication Process with WEP:
1. Authentication request: Initially, as it goes, the client sends the access point an authentication request.
2. Challenge: The access point then responds with a custom authentication response which includes challenge text for the client.
3. Challenge Response: The client then responds with the encrypted challenge, which is encrypted with the WEP key.
4. Verification: The AP then decrypts this challenge and sends back either an indication of success or failure.

Authentication Process with WPA:
1. Authentication Request: The client sends an authentication request to the AP to initiate the authentication process.
2. Authentication Response: The AP responds with an authentication response, which indicates that it is ready to proceed with authentication.
3. Pairwise Key Generation: The client and the AP then calculate the PMK from the PSK (password).
4. Four-Way Handshake: The client and access point then undergo each step of the four way handshake, which involves nonce exchange, derivation, among other actions to verify that the client and AP truly know the PSK.

## Wi-Fi Interfaces

Wireless interfaces are a cornerstone of wi-fi penetration testing. We must consider many different aspects when choosing the right interface. If we choose too weak of an interface, we might not be able to capture data during our penetration testing efforts.

### How to Choose the Right Interface

One of the first things that we should consider is capabilities. If our interface is capable of 2.4G and not 5G, we might run into issues when attempting to scan higher band networks.

Need to make sure the interface meets the following:
1. IEEE 802.11ac or IEEE 802.11ax support`
2. Supports at least monitor mode and packet injection

### Interface Strength

Much of wi-fi penetration testing comes down to our physical positioning. As such, if a card is too weak, we might find that our efforts will be inadequate. We should always ensure that our card is strong enough to operate at larger and longer ranges.

Check Strength 

```bash
iwconfig
```

Default is set to the country specified in the OS. 
Check Region

```bash
iw reg get
```

With this, we can see all of the different txpower settings that we can do for our region. Most of the time, this might be DFS-UNSET, which is not helpful for us since it limits our cards to 20 dBm. We can change this of course to our own region, but we should abide by pertinent rules and laws when doing this, as it is against the law in different areas to push our card beyond the maximum set limit, and as well it is not always particularly healthy for our interface.

### Changing the Region

Change the region

```bash
sudo iw reg set US
```

Check/Verify

```bash
iw reg get
```

Check the txpower

```bash
iwconfig
```

### Changing the Power

In many cases, our interface will automatically set its power to the maximum in our region. However, sometimes we might need to do this ourselves.

Bring down the interface

```bash
sudo ifconfig wlan0 down
```

```bash
sudo ip link set wlan0 down
```

Set the desired power

```bash
sudo iwconfig wlan0 txpower 30
```

Bring the interface back up

```bash
sudo ifconfig wlan0 up
```

```bash
sudo ip link set wlan0 up
```

Check/Verify

```bash
iwconfig
```

### Check Driver Capabilities

As mentioned, one of the most important things for our interface, is its capabilities to perform different actions during wi-fi penetration testing. If our interface does not support something, in most cases we simply will not be able to perform that action, unless we acquire another interface. Luckily, we can check on these capabilities via the command line.

Check Capabilities

```bash
iw list
```

### Scanning Available Networks

To efficiently scan for available Wi-Fi networks, we can use the iwlist command along with the specific interface name. Given the potentially extensive output of this command, it is beneficial to filter the results to show only the most relevant information. This can be achieved by piping the output through grep to include only lines containing Cell, Quality, ESSID, or IEEE.

```bash
iwlist wlan0 scan | grep 'Cell\|Quality\|ESSID\|IEEE'
```

### Changing Channel and Frequency

View available channels

```bash
iwlist wlan0 channel
```

Bring down interface

```bash
sudo ip link set wlan0 down
```

Set the channel

```bash
sudo iwconfig wlan0 channel 64
```

Bring up the interface

```bash
sudo ip link set wlan0 up
```

Check/Verify

```bash
iwlist wlan0 channel
```

If we prefer to change the frequency directly rather than adjusting the channel, we have the option to do so as well.

Check

```bash
iwlist wlan0 frequency | grep Current
```

Disable the interface

```bash
sudo ip link set wlan0 down
```

Change Frequency

```bash
sudo iwconfig wlan0 freq "5.25G"
```

Enable the Interface

```bash
sudo ip link set wlan0 up
```

Check/Verify

```bash
iwlist wlan0 frequency | grep Current
```

## Interface Modes

There are many more pertinent modes we need to know for our wireless interfaces when we conduct wi-fi penetration testing. Each mode is responsible for different capabilities and roles when it comes down to the hierarchy of Wi-Fi communications.

### Managed Mode

Managed mode is when we want our interface to act as a client or a station. This mode allows us to authenticate and associate to an access point, basic service set, and others. In this mode, our card will actively search for nearby networks (APs) to which we can establish a connection.

In most cases, our interface will default to this mode, but suppose we want to set our interface to this mode. This could be helpful after setting our interface into monitor mode. We would run the following command.

```bash
sudo ip link set wlan0 down
sudo iwconfig wlan0 mode managed
```

Connect to a network

```bash
sudo iwconfig wlan0 essid HTB-Wifi
```

Check/Verify

```bash
sudo iwconfig
```

### Ad-hoc Mode

we could act in a decentralized approach with ad-hoc. This mode is peer to peer and allows wireless interfaces to communicate directly to one another. This mode is commonly found in most residential mesh systems for their backhaul bands. That is their band that is utilized for AP-to-AP communications and range extension. However, it is important to note, that this mode is not extender mode, as in most cases that is actually two interfaces bridged together.

Set interface to this mode

```bash
sudo iwconfig wlan0 mode ad-hoc
```

Connect

```bash
sudo iwconfig wlan0 essid HTB-Mesh
```

Check/Verify

```bash
sudo iwconfig
```

### Master Mode

On the flip side of managed mode is master mode (access point/router mode). However, we cannot simply set this with the iwconfig utility. Rather, we need what is referred to as a management daemon. This management daemon is responsible for responding to stations or clients connecting to our network. Commonly, in wi-fi penetration testing, we would utilize hostapd for this task. As such, we would first want to create a sample configuration.

Create hostapd configuration file

```bash
cat > open.conf << 'EOF'
interface=wlan0
driver=nl80211
ssid=HTB-Hello-World
channel=2
hw_mode=g
EOF
```

Activate hostapd with configuration file

```bash
sudo hostapd open.conf
```

### Mesh Mode

Mesh mode is an interesting one in which we can set our interface to join a self-configuring and routing network. This mode is commonly used for business applications where there is a need for large coverage across a physical space. This mode turns our interface into a mesh point. We can provide additional configuration to make it functional, but generally speaking, we can see if it is possible by whether or not we are greeted with errors after running the following commands.

```bash
sudo iw dev wlan0 set type mesh
```

Check/Verify

```bash
sudo iwconfig
```

### Monitor Mode

Monitor mode, also known as promiscuous mode, is a specialized operating mode for wireless network interfaces. In this mode, the network interface can capture all wireless traffic within its range, regardless of the intended recipient. Unlike normal operation, where the interface only captures packets addressed to it or broadcasted, monitor mode enables comprehensive network monitoring and analysis.

Enabling monitor mode typically requires administrative privileges and may vary depending on the operating system and wireless chipset used. Once enabled, monitor mode provides a powerful tool for understanding and managing wireless networks.

To enabled monitor mode:

Bring down interface

```bash
sudo ip link set wlan0 down
```

Set monitor mode

```bash
sudo iw wlan0 set monitor control
```

Bring interface up

```bash
sudo ip link set wlan0 up
```

Check/Verify

```bash
iwconfig
```

Overall, it is important to make sure our interface supports whatever mode is pertinent to our testing efforts. If we are attempting to exploit WEP, WPA, WPA2, WPA3, and all enterprise variants, we are likely sufficient with just monitor mode and packet injection capabilities. However, suppose we were trying to achieve different actions we might consider the following capabilities.

1. Employing a Rogue AP or Evil-Twin Attack: - We would want our interface to support master mode with a management daemon like hostapd, hostapd-mana, hostapd-wpe, airbase-ng, and others.
2. Backhaul and Mesh or Mesh-Type system exploitation: - We would want to make sure our interface supports ad-hoc and mesh modes accordingly. For this kind of exploitation we are normally sufficient with monitor mode and packet injection, but the extra capabilities can allow us to perform node impersonation among others.

## Connecting to Wi-Fi Networks

Connecting to Wi-Fi networks using Linux involves a few straightforward steps. First, we need to scan for available networks, which can be done using tools like `iwlist` or through a `graphical network manager`. Once we identify the target network, we can connect by configuring the appropriate settings.

### GUI

Connecting to a Wi-Fi network with a GUI is typically a straightforward process. Once we obtain the valid credentials (either a passphrase for WPA/WPA2-Personal, username/password for WPA/WPA2-Enterprise or key for WEP), we simply input them into the password prompt provided by the system's network manager.

Here’s a breakdown of how this process usually works using GUI:

1. `Scan for Networks`
2. `Select the Network`
3. `Enter Credentials`
4. `Connect`

### CLI

If we've obtained the correct password for a network or simply want to connect to one, we may not always have access to the graphical network manager. In such cases, we’ll need to connect to the wireless network using the terminal. Fortunately, there are several methods available to achieve this from the command line. To connect to a network via the command line, we would use `wpa_supplicant` along with a `configuration` file that contains the necessary network details. This allows us to authenticate and connect to the network directly from the terminal.

Typically, we would switch our interface to monitor mode to scan for nearby networks. However, if we're limited or our interface doesn't support monitor mode, we can use managed mode instead. In this case, we can utilize the iwlist tool along with some grep parameters to filter and display useful information like the cell, signal quality, ESSID, and IEEE version of the networks around us.

Scan for networks

```bash
sudo iwlist wlan0 s | grep 'Cell\|Quality\|ESSID\|IEEE'
```

#### Connecting to WEP Networks

If the target network is using WEP, connecting is straightforward. We just need to provide the `SSID`, the `WEP hex key`, and set the WEP key index using `wep_tx_keyidx` in a configuration file (e.g., wep.conf) to establish the connection. Additionally, we set `key_mgmt=NONE`, which is used for WEP or networks with no security.

Create config file

```bash
cat > wep.conf << 'EOF'
network={
	ssid="HackTheBox"
	key_mgmt=NONE
	wep_key0=3C1C3A3BAB
	wep_tx_keyidx=0
}
EOF
```

Once the configuration file is ready, we can use `wpa_supplicant` to connect to the network. We run the command with the `-c` option to specify the configuration file and the `-i` option to specify the network interface.

```bash
sudo wpa_supplicant -c wep.conf -i wlan0
```

After connecting, we can obtain an IP address by using the `dhclient` utility. This will assign an IP from the network's DHCP server, completing the connection setup.

```bash
sudo dhclient wlan0
```

Check IP

```bash
ip a
```

#### Connecting to WPA Personal Networks

If the target network uses WPA/WPA2, we'll need to create a wpa_supplicant configuration file (eg: wpa.conf) with the correct `PSK` (Pre-Shared Key) and `SSID`. This file will look like the following:

```bash
cat > wpa.conf << 'EOF'
network={
	ssid="HackMe"
	psk="password123"
}
EOF
```

Then we could initiate our wpa connection to the AP using the following command.

```bash
sudo wpa_supplicant -c wpa.conf -i wlan0
```

After connecting, we can obtain an IP address by using the dhclient utility. This will assign an IP from the network's DHCP server, completing the connection setup. However, if we have a previously assigned DHCP IP address from a different connection, we'll need to release it first. Run the following command to remove the existing IP address:

```bash
sudo dhclient wlan0 -r
```

We can now run the dhclient command. This will assign an IP from the network's DHCP server, completing the connection setup.

```bash
sudo dhclient wlan0
```

Check IP

```bash
ip a
```

If the network uses `WPA3` instead of WPA2, we would need to add `key_mgmt=SAE` to our wpa_supplicant configuration file to connect to it. This setting specifies the use of the `Simultaneous Authentication of Equals (SAE)` protocol, which is a key component of WPA3 security.

#### Connecting to WPA Enterprise

If the target network uses WPA/WPA2 Enterprise (MGT), we'll need to create a wpa_supplicant configuration file with the correct `identity`, `password`, `SSID` and `key_mgmt`. This file will look like this:

```bash
cat > wpa_enterprise.conf << 'EOF'
network={
	ssid="HTB-Corp"
	key_mgmt=WPA-EAP
	identity="HTB\Administrator"
	password="Admin@123"
}
EOF
```

Once the configuration file is ready, we can use `wpa_supplicant` to connect to the network. We run the command with the `-c` option to specify the configuration file and the `-i` option to specify the network interface.

```bash
sudo wpa_supplicant -c wpa_enterprise.conf -i wlan0
```

After connecting, we can obtain an IP address by using the `dhclient` utility. This will assign an IP from the network's DHCP server, completing the connection setup. However, if we have a previously assigned DHCP IP address from a different connection, we'll need to release it first. Run the following command to remove the existing IP address:

```bash
sudo dhclient wlan0 -r
```

Get new IP

```bash
sudo dhclient wlan0
```

Check IP

```bash
ip a
```

### Connect with Network Manager Utility

One of the ways that we can easily connect to wireless networks in Linux is through the usage of nmtui. This utility will give us a somewhat graphical perspective while connecting to these wireless networks.

Start the utility

```bash
sudo nmtui
```

Select 'Activate a connection'
Select the network from the given list
Enter credentials if prompted

## Finding Hidden SSIDs

In Wi-Fi networks, the Service Set Identifier (SSID) is the name that identifies a particular wireless network. While most networks broadcast their SSIDs to make it easy for devices to connect, some networks choose to hide their SSIDs as a security measure. The idea behind hiding an SSID is to make the network less visible to casual users and potential attackers. However, this method only provides a superficial layer of security, as determined attackers can still discover hidden SSIDs using various techniques.

Set interface to monitor mode 

```bash
sudo airmon-ng start wlan0
```

Scan for Wi-Fi network

```bash
sudo airodump-ng wlan0mon
```

The `<length: x>` notation indicates the length of the Wi-Fi network name, where x represents the number of characters in the SSID.

There are multiple ways to discover the name of a hidden SSID. If there are clients connected to the Wi-Fi network, we can use `aireplay-ng` to send de-authentication requests to the client. When the client reconnects to the hidden SSID, `airodump-ng` will capture the request and reveal the SSID. However, de-authentication attacks do not work on [WPA3](https://github.com/aircrack-ng/aircrack-ng/issues/2539) networks since WPA3 has 802.11w (Protected Management Frames, [PMF](https://www.wi-fi.org/beacon/philipp-ebbecke/protected-management-frames-enhance-wi-fi-network-security)) which authenticates the de-authentication. In such cases, we can attempt a brute-force attack to determine the SSID name.

### Detecting with Deauth

The first way to find a hidden SSID is to perform a de-authentication attack on the clients connected to the Wi-Fi network, which allows us to capture the request when they reconnect.

Start sniffing on the channel of the network

```bash
sudo airodump-ng -c 1 wlan0mon
```

Send de-auth attack against AP and Client

```bash
sudo aireplay-ng -0 10 -a B2:C1:3D:3B:2B:A1 -c 02:00:00:00:02:00 wlan0mon
```

After sending the deauthentication requests using `aireplay-ng`, we should see the name of the hidden SSID appear in `airodump-ng` once the client reconnects to the WiFi network. This process leverages the re-association request, which contains the SSID name, and allows us to capture and identify the hidden SSID.

### Brute Forcing Hidden SSID

Another way to discover a hidden SSID is to perform a brute-force attack. We can use a tool like [mdk3](https://github.com/charlesxsh/mdk3-master) to carry out this attack. With mdk3, we can either provide a wordlist or specify the length of the SSID so the tool can automatically generate potential SSID names.

Basic syntax

```bash
mdk3 <interface> <test mode> [test_options]
```

The `p` test mode argument in mdk3 stands for Basic probing and ESSID Brute force mode. It offers the following options:

|**Option**|**Description**|
|---|---|
|`-e`|Specify the SSID for probing.|
|`-f`|Read lines from a file for brute-forcing hidden SSIDs.|
|`-t`|Set the MAC address of the target AP.|
|`-s`|Set the speed (Default: unlimited, in Bruteforce mode: 300).|
|`-b`|Use full brute-force mode (recommended for short SSIDs only). This switch is used to show its help screen|

To bruteforce with all possible values, we can use `-b` as the `test_option` in mdk3. We can set the following options for it.

- upper case (u)
- digits (n)
- all printed (a)
- lower and upper case (c)
- lower and upper case plus numbers (m)

```bash
sudo mdk3 wlan0mon p -b u -c 1 -t A2:FF:31:2C:B1:C4
```

To brute force using a wordlist we can use `-f` as the `test_option` in mdk3 followed by the location of the wordlist.

```bash
sudo mdk3 wlan0mon p -f /opt/wordlist.txt -t D2:A3:32:13:29:D5
```

With the new discovery of the SSIDs, if we had the PSK or were able to gather it through some means, we would be able to connect to the network in question.

## Bypassing MAC Filtering

Bypassing MAC filtering in Wi-Fi networks is a technique used to circumvent a basic security measure that many wireless routers implement. MAC filtering involves allowing only devices with specific MAC (Media Access Control) addresses to connect to the network. While this adds a layer of security by restricting access to known devices, it is not foolproof. Skilled individuals can exploit weaknesses in this system to gain unauthorized access. This process typically involves MAC address spoofing, where an attacker changes their device's MAC address to match an allowed device, thereby gaining access to the network.

Suppose we're attempting to connect to a network with MAC filtering enabled. Knowing the password might not be sufficient if our MAC address is not authorized. Fortunately, we can usually overcome this obstacle through MAC spoofing, allowing us to bypass the filtering and gain access to the network.

First, we would want to scout out our network with airodump-ng

```bash
sudo airodump-ng wlan0mon
```

Suppose we have obtained the credentials for the `HTB-Wireless` WiFi network, with the password `Password123!!!!!!`. Despite having the correct login details, our connection attempts are thwarted by MAC filtering enforced by the network. This security measure restricts access to only authorized devices based on their MAC addresses. As a result, even with the correct password, our device is unable to establish a connection to the network.

To bypass the MAC filtering, we can spoof our MAC address to match one of the connected clients. However, this approach often leads to collision events, as two devices with the same MAC address cannot coexist on the same network simultaneously.

A more effective method would be to either forcefully disconnect the legitimate client through deauthentication attacks, thereby freeing up the MAC address for use, or to wait for the client to disconnect naturally. This strategy is particularly effective in "bring your own device" (BYOD) networks, where devices frequently connect and disconnect.

We can also check if there is a 5 GHz band available for the ESSID. If the 5 GHz band is available, we can attempt to connect to the network using that frequency, which would avoid collision events since most clients are connected to the 2.4 GHz band.

Scan for networks on 5GHz band

```bash
sudo airodump-ng wlan0mon --band a
```

If the network exists and no clients are currently connected to the 5 GHz band, we can spoof our MAC address using tools such as [macchanger](https://github.com/alobbs/macchanger) to match one of the clients connected to the 2.4 GHz band and connect to the 5 GHz network without any collision events.

Before changing our MAC address, let's stop the monitor mode on our wireless interface.

```bash
sudo airmon-ng stop wlan0mon
```

Let's check our current MAC address before changing it. We can do this by running the following command in the terminal.

```bash
sudo macchanger wlan0
```

 Let's use `macchanger` to change our MAC address to match one of the clients connected to the 2.4 GHz network, specifically `3E:48:72:B7:62:2A`. This process involves disabling the `wlan0` interface, executing the `macchanger` command to adjust the MAC address, and finally reactivating the `wlan0` interface. Following these steps will effectively synchronize our device's MAC address with the specified client's address on the 2.4 GHz network.

Disable the interface

```bash
sudo ip link set wlan0 down
```

Change the MAC address

```bash
sudo macchanger wlan0 -m 3E:48:72:B7:62:2A
```

Enable the interface

```bash
sudo ip link set wlan0 up
```

After bringing the wlan0 interface back up, we can utilize the `ip` command to confirm that our MAC address has indeed been modified. This step ensures that our device now adopts the new MAC address we specified earlier, aligning with the desired client's MAC address connected to the 2.4 GHz network.

```bash
ip a
```

Now that our MAC address has been changed to match one of the clients connected to the 2.4 GHz network, we can proceed to connect to the 5 GHz Wi-Fi network named `HTB-Wireless-5G`. This can be done either through the graphical user interface (GUI) of the system's network manager or via the command line using tools like NetworkManager's command-line interface (nmcli).

After successfully connecting to the 5 GHz network, we can verify the connection status by running the `ip` command once more. This time, we should observe that a DHCP-assigned IP address has been allocated by the Wi-Fi network.

```bash
ip a
```

Once connected to the WiFi network, we can scan for other clients connected to the same network within the IP range.

