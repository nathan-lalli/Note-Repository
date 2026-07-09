---
tags:
  - reaver
  - bully
  - wpspin
  - default-wps-pin
  - wps-pin
  - nmk
  - oneshot
  - wpa_cli
  - mdk4
  - wps
---
## Overview

WPS is susceptible to online PIN cracking and offline PIN cracking methods. WPS utilizes a series of EAP messages exchanged between a station (enrollee) and an access point (registrar). During this process, valuable information is disclosed; information that can be exploited for these attack methods. While traditional online PIN cracking takes hours to complete, offline PIN cracking can be as quick as a few minutes when the access point is vulnerable.

WPS utilizes HMAC-SHA-256, which is considered a fairly secure hashing function. However, due to the lack of possible PIN combinations, randomness in nonce values, and information disclosed in the communications between the access point and the client, we are able to crack these PINs relatively quickly and retrieve the PSK for normal WPA communications.

When assessing wireless access points, it is always important to check for WPS vulnerabilities. As such, possessing the skills to test for WPS-related vectors is crucial for all wireless penetration testers.

### WPS Connection Methods

There are four methods to connect to a WPS-enabled access point. Each of them is detailed below:

|Method|Description|
|---|---|
|`Push Button Configuration (PBC)`|This is the most common method and involves pressing a physical or virtual button on the router and the client device. Once the button is pressed on both devices, they automatically exchange the necessary information to establish a secure connection.|
|`PIN Entry`|Each WPS-enabled device has an 8-digit PIN code, either provided by the manufacturer or displayed on the device. Users enter this PIN on their router or access point’s configuration page to connect the device to the network.|
|`Near-field communication method`|Some devices support NFC, allowing users to tap the device on the router to establish a connection. This method is less common but offers an additional level of convenience.|
|`USB Flash Drive`|Involves transferring configuration settings via a USB drive from the router to the client device. This method is rarely used due to the inconvenience compared to other methods.|

### Benefits of WPS

- `Ease of Use`: Simplifies the process of adding new devices to a wireless network, making it accessible even for non-technical users.
- `Convenience`: Eliminates the need to remember or enter long and complex passwords.

### Security Concerns

While WPS was designed to make network connections simpler, it has notable security vulnerabilities:

- `PIN Method Vulnerability`: The 8-digit PIN can be cracked relatively easily through brute-force attacks due to the way the protocol verifies the PIN in two halves.
- `Physical Security Risks`: The PBC method relies on physical security, meaning an unauthorized person within range could potentially push the button and connect to the network.

## How WPS Works

WPS works by establishing authentication through a series of [Extensible Authentication Protocol (EAP)](https://en.wikipedia.org/wiki/Extensible_Authentication_Protocol) messages. Some of the information communicated includes Public Keys, PINs, and nonce values. Essentially, after some checks and balances between the access point and the connected client, the access point (registrar) shares the WPA pre-shared key, which allows the connected client (enrollee) to ensure communications as normal with WPA. It should also be noted that when WPS (Wi-Fi Protected Setup) is used to configure an access point, the roles of the access point (AP) and the client device can switch. In this case, the AP may act as the Enrollee, while the client device assumes the role of the Registrar, which is responsible for [configuring the AP](https://android.googlesource.com/platform/external/wpa_supplicant_8/+/master/wpa_supplicant/README-WPS#36).

There are several methods for WPS to begin the series of EAP messages. Commonly these are through the PIN method initiated by the client, and the push button method initiated manually on the access point. There are other methods as well such as the Near-field communication method through the usage of RFID among many other WPS-related technologies.

### WPS PIN Anatomy

The WPS PIN is eight digits in length and consists of two primary portions. The first portion is used in the M4 and M5 EAP messages, and the second portion is used in the M6 and M7 EAP messages. Each of these portions is four digits in length. Most would assume that there would be 100,000,000 (108) possible digit combinations, but in the case of WPS, this is not true. There are only 11,000 possible combinations.

![[wps_pin.png]]

This is due to how the PIN functions. The first half only has 104 possible combinations and the second half has only 103 possible combinations. The last digit of the second half is used as a checksum and can be easily calculated. Therefore, there are only 10,000 (104) + 1,000(103) possible digit combinations, which is 11,000 total combinations.

### WPS EAP Messages

| Name                        | Definition                                                                                                                          |
| --------------------------- | ----------------------------------------------------------------------------------------------------------------------------------- |
| `PKe`                       | This is the Enrollee's (Access Point's) Diffie-Hellman public key.                                                                  |
| `PKr`                       | This is the Registrar's (Station's/Client's) Diffie-Hellman public key.                                                             |
| `PSK1`                      | First four-digit portion of the PIN (10,000 possible combinations).                                                                 |
| `PSK2`                      | Second four-digit portion of the PIN (1,000 possible combinations). The last digit is used as the checksum.                         |
| `KDK (Key Derivation Key)`  | This is a key used in derivation for the auth key.                                                                                  |
| `KWK (Key Wrap Key)`        | Used in the process of encrypting messages with AES.                                                                                |
| `E-S1`                      | This is a secret 128-bit enrollee (AP) nonce value used in derivation for E-Hash1.                                                  |
| `E-S2`                      | This is a secret 128-bit enrollee (AP) nonce value used in derivation for E-Hash2.                                                  |
| `R-S1`                      | This is a secret 128-bit registrar (client/station) nonce value used in derivation for R-Hash1.                                     |
| `R-S2`                      | This is a secret 128-bit registrar (client/station) nonce value used in derivation for R-Hash2.                                     |
| `E-Hash1 (Enrollee Hash1)`  | Comprised of the E-S1 nonce value, PSK1, PKe, and PKr values. Created through the HMAC-SHA-256 hashing function using the Auth Key. |
| `E-Hash2 (Enrollee Hash2)`  | Comprised of the E-S2 nonce value, PSK2, PKe, and PKr values. Created through the HMAC-SHA-256 hashing function using the Auth Key. |
| `R-Hash1 (Registrar Hash1)` | Comprised of the R-S1 nonce value, PSK1, PKe, and PKr values. Created through the HMAC-SHA-256 hashing function using the Auth Key. |
| `R-Hash2 (Registrar Hash2)` | Comprised of the R-S2 nonce value, PSK2, PKe, and PKr values. Created through the HMAC-SHA-256 hashing function using the Auth Key. |
| `Auth Key`                  | Derived from the KDK, PSK1, and PSK2 values.                                                                                        |
| `WPA-PSK`                   | This is the final disclosed pre-shared key (aka password) used to authenticate the client.                                          |

The series of EAP messages from a high level looks like the following:

![[eap_message_series.png]]

Each of these messages is responsible for disclosing different information, and they conduct the following.

|Message|Description|
|---|---|
|`EAPOL-Start`|The connected client initiates the series of EAP messages.|
|`EAP Request Identity`|The access point requests the connected client's identity.|
|`EAP Response Identity`|The client sends the access point its identity as requested.|
|`EAP M1 Message`|The access point sends the client their Diffie-Hellman public key (PKe).|
|`EAP M2 Message`|The client then sends the Access point the their Diffie-Hellman public key (PKr).|
|`EAP M3 Message`|The access point sends the client the E-Hash1 and E-Hash2 values.|
|`EAP M4 Message`|The client then sends the access point the R-Hash1, R-Hash2, and R-S1 nonce value encrypted with AES.|
|`EAP M5 Message`|The access point sends the client the E-S1 nonce value encrypted with AES.|
|`EAP M6 Message`|The client sends the access point the R-S2 nonce value encrypted with AES.|
|`EAP M7 Message`|If the PIN is correct, the access point sends the client the E-S2 value and the WPA-PSK encrypted with AES.|
|`EAP M8 Message`|The client then sends the WPA-PSK back to the access point to begin the WPA handshake process.|

## WPS Reconnaissance

In order to analyze a target network, we need to view its WPS information. We can do so with several different tools. Some of the information we hope to attain is the MAC address of the access point and which WPS version it is using. The MAC address is useful because an easy vendor lookup may allow us to find that the access point's vendor may or may not be susceptible to different kinds of WPS attacks. This can easily be done with a bit of research, and later we will explore custom PIN generation based on this information. Additionally, we want to find which version of WPS is running, along with which mode it is in, as it will help us narrow down which attack techniques to employ. If an access point is running WPS version 2.0 it is unlikely that we will be able to use any vector beyond pixie dust attacks, possibly null pin attacks, and brute forcing attempts with very long reattempt periods. This is due to a few factors, such as a locking feature built into most access points. After a certain amount of incorrectly guessed PINs the access point locks and requires either a reboot or timeout for additional PIN guesses.

### Scanning WPS Networks with Airodump-ng

List interfaces

```bash
sudo iwconfig
```

Start monitor mode

```bash
sudo airmong-ng start wlan0
```

Begin searching for networks with WPS

```bash
sudo airodump-ng --wps --ignore-negative-one wlan0mon
```

`--wps` specifies to display WPS information
`--ignore-negative-one` removes -1 PWR error messages

Narrow down our scan to just our network

```bash
sudo airodump-ng --wps --ignore-negative-one -c 8 --bssid XX:XX:XX:XX:XX:XX
```

With Airodump-ng, we can obtain solid information about the WPS version and the mode it is using to operate. WPS includes several different modes, and Airodump-ng uses the following acronyms to represent them.

|Acronym|Description|
|---|---|
|`DISP`|The Access Point generates a PIN in its administrative setup portal, and the PIN can be found there.|
|`ETHER`|A rare mode that allows enrollees and registrars to undergo setup over Ethernet.|
|`EXTNFC`|WPS using Near Field Communication.|
|`INTNFC`|WPS using Near Field Communication.|
|`KPAD`|Keypad PIN method configuration. Enrollees connect by entering the WPS PIN into a keypad on the client device.|
|`LAB`|The PIN is displayed on a label attached to the access point itself.|
|`Locked`|WPS is locked. This can occur from too many incorrect guesses.|
|`NFCINTF`|WPS using Near Field Communication.|
|`PBC`|Push Button Configuration. Allows clients to join by pressing the WPS button on both the access point and the client device.|
|`USB`|Data is transferred between the access point and the client through a USB interface.|

### Scanning WPS Networks with Wash

Wash is another great tool for scanning networks with WPS. We can employ a simple command with wash to display all networks with WPS and their respective versions.

```bash
sudo wash -i wlan0mon
```

Display more verbose information

```bash
sudo wash -j -i wlan0mon
```

It is important to check the `wps_locked` status from wash. If it is set to 2, it means WPS is not in a locked state. 

Additionally, we can find out which vendor is associated with the access point with the following command, specifying the beginning of the MAC address.

```bash
grep -i "XX-XX-XX" /var/lib/ieee-data/oui.txt
```


> [!INFO] Things to be wary of
> - `The WPS version`.
> - `wps_locked status`: We want to ensure that clients can join the network.
> - `The WPS Mode`: If we need to press a button to join the network, chances are we are not cracking the PIN this way.
> - `Max PIN Attempts Locking`: If the access point locks after a few incorrectly guessed PINs, we likely will not be able to get through all 11,000 possible combinations.

## Online PIN Brute-Forcing

One of the ways that we can attempt to retrieve the correct WPS pin for a target network is through online PIN brute-forcing. This can be conducted with a few different tools, but popularly it is done with either `Reaver` or `Bully`.

Online brute-forcing works by trying all possible digit combinations and sending them to the access point for verification. By doing this, we go through the series of EAP messages for each possible PIN. In the M4 message, the client sends the access point the R-Hash1 and R-Hash2 values, along with the R-S1 nonce values encrypted with AES. During this message, the access point computes the received R-Hash1 and R-Hash2 values to verify if the PIN we sent is correct. If it is, the remaining messages are exchanged. If it is not, we receive a NACK.

In online brute-forcing attacks, we already know some values and generate others. These are as follows:

- We know the PKe and generate the PKr ourselves. This allows us to generate the proper response for the R-Hash1 and R-Hash2 values.
- We generate the R-S1 and R-S2 nonce values ourselves.
- We receive the E-Hash1 and E-Hash2 values from the access point during the M3 message.

However, during these attacks we do not know:

- The true PIN (PSK1 and PSK2 values). We guess this through the 11,000 combinations.
- The E-S1 and E-S2 nonce values. We receive these from the access point in the M5 and M7 message. Of course, only if we guess the PIN correctly.
- The WPA-PSK. This is the resulting success during the M7 message upon guessing the correct PIN.

Due to us not knowing either of the 128-bit E-S1 and E-S2 nonce values, and the fact that they are random, we are left guessing the PIN. However, these are not always randomly generated. Depending on the vendor, we might be able to employ the usage of an offline pixie dust attack to retrieve the WPA-PSK.

## Brute-Forcing with Reaver


> [!INFO] It is recommended to enable monitor mode using iw to utilize reaver.


[Reaver](https://github.com/t6x/reaver-wps-fork-t6x) is an excellent tool for conducting online password cracking attempts. It offers various options, including Null PIN attacks, custom PIN associations, Pixie Dust Attacks, and general brute-forcing. We will explore Pixie Dust Attacks in detail in the later section. In this section, we will focus on brute-forcing WPS PINs using reaver.

Usage

```bash
reaver -i [interface] -b [bssid] -c [channel]
```

|**Option**|**Description**|
|---|---|
|`-i`|Name of the monitor-mode interface to use|
|`-b`|BSSID of the target AP|
|`-c`|Set the 802.11 channel for the interface|
|`-p`|Use the specified pin|
|`-d`|Set the delay between pin attempts|
|`-l`|Set the time to wait if the AP locks WPS pin attempts|
|`-g`|Quit after num pin attempts|
|`-r`|Sleep for y seconds every x pin attempts|
|`-t`|Set the receive timeout period|
|`-L`|Ignore locked state reported by the target AP|
|`-K, -Z`|Run pixiedust attack|
|`-O`|Write packets of interest into pcap file|

### Brute-Forcing WPS PIN

To begin, we need to enable monitor mode. We can use the `iw` command to add a new interface named `mon0` and set its type to monitor mode, as demonstrated below. Due to a known bug, setting the interface to monitor mode using `airmon-ng` can cause `Reaver` to malfunction. Therefore, it is recommended to use the `iw` command for this purpose.

```bash
sudo iw dev wlan0 interface add mon0 type monitor
sudo ip link set mon0 up
iwconfig
```

Once we've added an interface with monitor mode enabled, we can use `airodump-ng` to enumerate WPS enabled Wi-Fi networks.

```bash
sudo airodump-ng mon0 --wps
```

Now we can start brute-forcing using Reaver. To begin, we need to specify the interface with the `-i` argument, the BSSID with the `-b` argument, and the channel with the `-c` argument. Reaver will then automatically begin brute-forcing every possible PIN, which totals `11,000` possible PINs.

```bash
sudo reaver -i mon0 -b XX:XX:XX:XX:XX:XX -c 1
```

### Brute-Forcing Using Half Known WPS PIN

If we know the first four digits of the WPS PIN, we can use Reaver to bruteforce the remaining four digits. We can provide the known half PIN using the `-p` option followed by the first four digits. For example, if the known first half of the PIN is 1234, we would use `-p 1234`.

```bash
sudo reaver -i mon0 -b XX:XX:XX:XX:XX:XX -c 1 -p 1234
```

### Testing for Null PIN

Suppose neither of these succeed, we could also attempt a `Null PIN` attack. Some access points are vulnerable to Null PIN attacks and will even disclose the WPA-PSK when no PIN is sent. We can do so by employing the following command, specifying the Null PIN with `-p ""` or `-p " "`.

```bash
sudo reaver -b XX:XX:XX:XX:XX:XX -c 1 -i mon0 -p " "
```

### Retrieving WPA-PSK Using Reaver with a Known PIN

If one of our brute forcing attempts succeeds, we can use the following command to verify the captured PIN. In this command, `-p` specifies the PIN, and `-b` specifies the BSSID of the target Wi-Fi network:

```bash
sudo reaver -i mon0 -b XX:XX:XX:XX:XX:XX -p 88766197
```

## Secured Access Points

Traditionally, online brute-forcing attempts have been utilized in retrieving the WPS PIN and WPA-PSK. However, in recent years, manufacturers have become wiser to these attacks. As such, locking has been utilized to prevent these traditional brute-forcing techniques. The most recent vendors only allow up to 3 incorrect attempts. After each incorrect attempt, the AP will lock for 60 seconds. After 10 incorrect attempts, the AP will lock for 365 days.

Let's first enable monitor mode using the `iw` command and add a new interface named `mon0` in monitor mode.

```bash
sudo iw dev wlan0 interface add mon0 type monitor
sudo ip link set mon0 up
iwconfig
```

Then, we can use `airodump-ng` to continuously scan for the WPS status of nearby networks.

```bash
sudo airodump-ng mon0 --wps -c 1
```

In a new terminal, we can start the brute-force attempt on the available Wi-Fi network.

```bash
sudo reaver -i mon0 -c 1 -b XX:XX:XX:XX:XX:XX
```

After three incorrect attempts, the AP will enter a `Locked` state for `60 seconds`. Each subsequent wrong PIN attempt will cause the AP to lock for another 60 seconds. However, after 10 incorrect attempts, the AP will lock for `365 days`.

We can observe in the `airodump-ng` output that the access point goes into a `Locked` state.

In some cases, vendors might have not implemented strict lock mechanisms, allowing us to continue brute-forcing using Reaver. The tool can be fine-tuned with additional advanced switches to optimize the brute-force process, for example:

|**Option**|**Description**|
|---|---|
|`-L, --ignore-locks`|Ignore locked state reported by the target AP|
|`-N, --no-nacks`|Do not send NACK messages when out of order packets are received|
|`-d, --delay=<seconds>`|Set the delay between pin attempts [1]|
|`-T, --m57-timeout=<seconds>`|Set the M5/M7 timeout period [0.40]|
|`-r, --recurring-delay=<x:y>`|Sleep for y seconds every x pin attempts|

With the latest models from certain vendors, when the access point reaches the 10th incorrect PIN attempt, it will lock for 365 days, preventing any further brute-force attempts.

This leads us to ask the following questions when employing these brute-forcing techniques:

- Will the access point lock after 3 incorrect attempts?
- How long does the access point stay locked? (Different vendors have different locking time.)
- Would PIN generation algorithms allow us to refine the total amount of guesses? (Covered in the next section.)

If the access point (AP) locks after three incorrect attempts, using PIN generation algorithms to narrow down the total number of guesses and create a custom wordlist can be beneficial. However, in some cases, we might get lucky and find the correct PIN within the first 10 brute-force attempts, before the AP locks indefinitely. Gathering information on these questions through research and enumeration allows us to craft better attacks towards WPS services for access points. The better technique that we utilize, the lower our chances are of failure when attempting to retrieve the PSK through WPS.

## Using Multiple Pre-Defined PINs

While it is possible to brute-force the WPS PIN using `Reaver`, we can also use a custom wordlist of potential PINs. We can generate possible PINs for a Wi-Fi network using `wpspin` and then create a custom bash script to brute-force the access point with these PINs.

### Using Python WPSPin to Generate Default PINs

The [WPSPin](https://github.com/epicdev420/WPSPin) tool is a powerful tool that includes many different PIN generation algorithms. This tool allows us to once again provide the BSSID of our target network and receive a list of possible default PINs.

To begin, we can install the tool from the source.

```bash
git clone https://github.com/nathan-lalli/wpspin.git
```

Then, we navigate into the tool's cloned directory and run the setup script to install WPSPin.

```bash
cd wpspin
sudo python setup.py install
```

Once WPSPin is installed, we can employ the following command to generate possible default PINs. We specify our `BSSID` and `-A` to generate any and all possible PINs.

```bash
wpspin -A XX:XX:XX:XX:XX:XX
```

WPSPin outputs a variety of possible PINs for valid BSSIDs. To retrieve the WPA-PSK from a known PIN, we can use the following command.

```bash
sudo reaver --max-attempts=1 -l 100 -r 3:45 -i mon0 -b XX:XX:XX:XX:XX:XX -c 1 -p 73834410
```

In the above command, -l sets the time to wait if the access point locks WPS PIN attempts, which is set to 100 seconds. The -r option specifies the recurring delay, meaning the command will sleep for 45 seconds every 3 attempts. The --max-attempts=1 specifies that the tool will only attempt the PIN one time. This option ensures that the PIN is tested just once, rather than multiple attempts.

However, doing this with a list of pre-defined PINs is not very efficient, as we have to re-execute this command for every potential PIN. Luckily, a bit of bash scripting can enable us to conduct a hands off approach for every PIN we generated.

We can extract only the pins from the wpspin output using a combination of grep and tr commands:

```bash
wpspin -A XX:XX:XX:XX:XX:XX | grep -Eo '\b[0-9]{8}\b' | tr '\n' ' '
```

This command filters and displays the 8-digit pins from the output file, separating them with spaces. We can now store this output in a variable of a bash script and use it for brute-forcing WPS, as shown below.

```bash
cat > pinguess.sh << 'EOF'
#!/bin/bash

#We add generated PINs into this list - CHANGE BASED ON MAC
PINS='73834410 94229882 73834410 06490959 11184812 63311501 11184812 36499373 63313604 99956042 95661469 89478486 11184812 11184812 95755212 20854836 20144326 33946153 13142452 74163052 51875350 43977680 56587340 95719115 48563710 92148659 05294176 89532331 68175542 71412252 80652847 76229909 46264848 82799427 20233921 31957199 10864111 62327145 30432031 90970948 22369628 33554433 34259283 35611530 20172527 67958146 12345670 74244973'

for PIN in $PINS
do
    echo Attempting PIN: $PIN
    #CHANGE THE MAC BELOW
    sudo reaver -v --max-attempts=1 -l 100 -r 3:45 -i mon0 -b XX:XX:XX:XX:XX -c 1 -p $PIN
done
echo "PIN Guesses Complete"
EOF
chmod +x pinguess.sh
```

With this script, we execute the same Reaver command for every PIN in the provided list. While it could be refined or built onto, the basic functionality is as follows:

- For each generated PIN attempted, the script will try the PIN only once, and then wait for 100 seconds if the access point (AP) locks
- Additionally, for every three attempts made, it will pause for 45 seconds.
- The script iterates through all the PINs in the list, which can be seen in action in the example below:

```bash
sudo ./pinguess.sh
```

### Performing Vendor Lookup

If the access point is secured and locks after a few attempts, in some cases we can perform a vendor lookup to refine our list of potential PINs. This can be done using the `oui.txt` file included in Linux distributions. The `oui.txt` file contains information about the organizations that own different MAC address prefixes.

To perform a vendor lookup, we can use the following `grep` command, specifying the first portion of the target network’s BSSID:

```bash
grep -i "XX-XX-XX" /var/lib/ieee-data/oui.txt
```

By performing a vendor lookup and refining our PIN list, we can increase the likelihood of discovering the correct WPS PIN for the target access point. This method leverages known vendor defaults and vulnerabilities to enhance our brute-forcing efforts. If successful, this approach can help us retrieve the WPA-PSK and gain access to the secured network.

## Using PIN Generation Tools

When crafting an online brute-forcing attempt, it can be cumbersome to guess all 11,000 possible PINs especially considering most access points are utilizing default PINs. Luckily, over the years many different libraries and tools have been developed to generate these default PINs. Some of these include the Arcadyan, Vodafone EasyBox, and ComputePIN default generation algorithms.

### Using Vodafone EasyBox Default WPS PIN Algorithm

In 2013, a vulnerability was discovered in DSL home gateways manufactured by Arcadyan Networks and rebranded for Vodafone Germany known as [Vodafone EasyBox Default WPS Pin Algorithm](https://seclists.org/fulldisclosure/2013/Aug/51). These devices had Wi-Fi access points enabled by default and could be accessed using the default WPS PIN (PIN External Registrar) printed on the back of the device. The algorithm used to generate the default WPS PIN is entirely based on the MAC address (BSSID) and the serial number of the device. The serial number can be derived from the MAC address.

To begin, we can use a tool called [Default-wps-pin](https://github.com/eye9poob/Default-wps-pin), and start by cloning it from GitHub.

```bash
git clone https://github.com/eye9poob/Default-wps-pin
```

Then, to use the tool, we simply employ the following command. We specify our BSSID, then observe as possible PINs are outputted into the terminal.

```bash
python2 /opt/Default-wps-pin/default-wps-pin.py XX:XX:XX:XX:XX:XX
```

### Using WPS-PIN to Generate Default PIN

We can also use another script called [WPS-PIN](https://github.com/linkp2p/WPS-PIN) to generate the WPS PIN from the BSSID.

```bash
git clone https://github.com/linkp2p/WPS-PIN.git
cd WPS-PIN
chmod +x WPSPIN.sh
```

Running this script will open an interactive CLI that will generate the PIN

```bash
./WPSPIN.sh
```

### Using Naranja MekaniK (nmk) to Generate WPS PIN

[Naranja MekaniK (nmk)](https://github.com/kcdtv/nmk) is a tool kit that proposes different ways to generate the default WPS PIN for:

- Arcadyan ARV7519RW22
- Arcadyan ARV7520CW22
- Arcadyan VRV9510KWAC23

The first two models are also known as `Livebox 2.1`, and the third one is known as `Livebox Next`.

We need to enter the last four digits of the BSSID (from the 2.4GHz network) and the last four digits of the serial number. The serial number can be found on a sticker attached to the back of the router.

```bash
git clone https://github.com/kcdtv/nmk.git
```

Run the tool will the last 4 of the BSSID and the last 4 of the serial

```bash
python2 nmk/orangen.py XXXX ####
```

## Pixie Dust Attack 

Some vendors such as Ralink, Realtek, MediaTek, and Broadcom are susceptible to offline bruteforcing techniques through the `Pixie Dust Attack`. This is due to bad randomization during nonce generation. The E-S1 and E-S2 nonce values are 128-bits. As such, if we were to try to blindly bruteforce the hash values through variable brute force, this would take a very long time. Due to certain vendors having bad/predictable nonce value generation, we can retrieve these values, which makes bruteforcing on the E-Hash1 and E-Hash2 values much quicker. This helps eliminate the need to conduct online bruteforcing through every iteration of a possible PIN.

If we recall, during the M1 and M2 messages, the PKe and PKr values are shared between the enrollee (client) and registrar (AP), respectively. Additionally, during the M3 message, we receive the E-Hash1 and E-Hash2 values. Simply put, the E-Hash1 and E-Hash2 values are structured as shown below.

- `E-Hash1 = (E-S1 nonce value | PSK1 | PKe | PKr)`
- `E-Hash2 = (E-S2 nonce value | PSK2 | PKe | PKr)`

During the initial message exchange with the access point, we already know the PKe and PKr values. To crack these HMAC-SHA-256 hashes, we need to guess the E-S1 and E-S2 nonce values, as the resulting values will form both portions of our PIN (the PSK1 and PSK2 values).

In order to elaborate on Pixie Dust attacks and bad random nonce generation, these next few examples will help, but are not exhaustive.

1. Certain Ralink and Mediatek chipsets contain the same zero nonce generation issue for WPS. This means that the nonce values are never generated, and instead are always set to zero. As such, we know all values except the PSK1 and PSK2 values respectively.

- `E-Hash1 = (E-S1 (0) | PSK1 | PKe (known) | PKr (known) )`
- `E-Hash2 = (E-S2 (0) | PSK2 | PKe (known) | PKr (known) )`

2. Certain Broadcom chipsets use the same random number generation algorithm to generate the nonce values, as well as other values such as the N1 enrollee nonce or PKe. Since these values are generated using the same algorithm, bruteforcing looks like the following.

- `We guess all seed values until we find the correct ones that generated the N1 enrollee nonce or PKe value, then generate the respective E-S1 and E-S2 nonce values.`
- `We are then able to retrieve the PSK1 and PSK2 values.`

3. Similarly, certain Realtek chipsets have issues with how they generate seeds for random values. These vulnerable chipsets utilize Unix timestamps from the WPS EAP message exchange as seed values for generating the E-S1, E-S2, and PKe enrollee values. With most timing-based attacks, depending on the delay and speed of message delivery, these values are often identical or differ by only a small increment. Overall, the process looks like the following:

- `E-S1 = E-S2 = PKe or E-S1 = E-S2 = PKe + N`
- `Due to the weak random (Unix timestamp) seed, the E-S1, E-S2, and PKe values are often identical, or incrementally different by a small value, N.`
- `We increment through guesses of the seed values that were used to generate the PKe. This then allows us to guess the E-S1 and E-S2 values, respectively.`
- `We are then able to retrieve the PSK1 and PSK2 values respectively.`

Not all Pixie Dust attacks are equal, but generally they are much quicker to conduct than traditional online brute-forcing techniques. This is due to us guessing the nonce values, rather than guessing one of the possible 11,000 PIN combinations. By doing so, we can retrieve the correct PIN within a few seconds to a couple hours, as opposed to waiting several hours for an online attempt to potentially succeed. Another advantage of Pixie Dust attacks is the low number of PIN guesses required. For access points with locking mechanisms, this can be tremendously beneficial when attempting to avoid being locked out.

### Using Reaver

To perform a Pixie Dust attack with `Reaver`, we require a network interface running in monitor mode. We can create a new interface `mon0` and enable monitor mode using the following commands.

```bash
sudo iw dev wlan0 interface add mon0 type monitor
sudo ip link set mon0 up
iwconfig
```

Once the interface is in monitor mode, we scan for available Wi-Fi networks with `airodump-ng`.

```bash
sudo airodump-ng mon0 --wps
```

We can use Reaver to perform a Pixie Dust attack against it, specifying the `-K` (or `--pixie-dust`) option.

```bash
sudo reaver -K 1 -vvv -b XX:XX:XX:XX:XX:XX -c 1 -i mon0
```

If the Pixie Dust attack was successful, and the PIN was recovered. We can subsequently use this PIN to obtain the PSK (Pre-Shared Key) for the Wi-Fi network.

```bash
sudo reaver -b XX:XX:XX:XX:XX:XX -c 1 -p ###### -i mon0
```

### Using Oneshot

Installing OneShot

whole repo
```bash
git clone https://github.com/fulvius31/OneShot.git
```

just the script
```bash
wget https://raw.githubusercontent.com/fulvius31/OneShot/master/oneshot.py
```

To perform a Pixie Dust attack using [OneShot](https://github.com/fulvius31/OneShot/tree/master), we again require our interface to be in monitor mode.

```bash
sudo airmon-ng start wlan0
```

To perform the attack we will use the `-K` (or `--pixie-dust`) argument. 

```bash
sudo
python3 /opt/OneShot/oneshot.py -b 86:FC:9F:5D:67:4E -i wlan0mon -K
```

## Push Button Configuration

`Push Button Configuration (PBC)` is a simple and user-friendly method for connecting devices to a wireless network using Wi-Fi Protected Setup (WPS). It’s particularly useful for users who want to avoid entering complex passwords. PBC is a feature of WPS that allows users to connect devices to a Wi-Fi network by simply pressing a physical button on the router/AP and the connecting device, instead of entering a password.

### How Does PBC Work?

- `Physical Button Press`: Most routers and access points have a WPS button that triggers PBC.
- `Automatic Pairing`: After pressing the button, the router will listen for new device requests to connect for a set time (usually two minutes). During this period, any device that requests access can connect without needing a password.
- `Device Side Interaction`: The connecting device (e.g., smartphone, smart TV, etc.) typically has an option to connect via WPS. After selecting this, the device searches for routers or access points in PBC mode and establishes a connection. The connection is established without the need to enter a password manually.

Push Button Configuration is commonly used to connect printers and other devices to Wi-Fi networks without requiring a password.

### Enumeration

Put interface into monitor mode

```bash
sudo airmon-ng start wlan0
```

We can use `airodump-ng` to check if the Wi-Fi network is in Push Button Configuration (PBC) mode.

```bash
sudo airodump-ng wlan0mon -c 1 --wps
```

The output of the above will show `PBC` under WPS if push button mode is enabled.

### Performing the Attack

Consider a scenario where we are performing a wireless penetration test and discover an access point with WPS enabled. Since we're onsite at the client's office, we have direct access to the router. In this situation, we can physically press the WPS button on the back of the router, allowing us to connect to the access point without having to manually enter a password. We can achieve this by using tools such as `oneshot` for automated execution, or manually by utilizing `wpa_cli` to establish the connection.

#### Using wpa_cli

First, we need to scan for available access points to obtain their BSSID. This can be done using the `iwlist scan` command, as demonstrated below.

```bash
sudo iwlist wlan0 scan |  grep 'Cell\|Quality\|ESSID\|IEEE'
```

Alternatively, we can achieve the same result with `wpa_cli`.

```bash
sudo wpa_cli scan_results
```

Once we have identified our target BSSID, we immediately press the WPS button on the back of the router and execute following command.

```bash
sudo wpa_cli wps_pbc XX:XX:XX:XX:XX:XX
```

After a few seconds, we can check `wpa_supplicant` to verify that we've successfully connected to the Wi-Fi network.

```bash
sudo systemctl status wpa_supplicant
```

We can use `dhclient` followed by the interface name, such as `wlan0`, to obtain a valid IP address within the access point's subnet.

```bash
sudo dhclient wlan0
```

We can verify the connection, using `ip a` to confirm that we've successfully connected to the access point and received an IP address.

```bash
ip a
```

#### Using OneShot 

We can also use [Oneshot](https://github.com/fulvius31/OneShot/tree/master) to automate the exploitation of PBC. Oneshot will automatically generate the valid WPS PIN and WPA passphrase for the access point.

To use Oneshot, we first need to enable monitor mode on the `wlan0` interface by using `airmon-ng`.

```bash
sudo airmon-ng start wlan0
```

Once monitor mode is enabled, we can run Oneshot with the `--pbc` argument to connect using PBC mode.

```bash
sudo python3 oneshot.py -i wlan0mon --pbc
```

Oneshot will use the PBC method to connect to the access point and provide us with the WPA PSK for the network. We can then use these credentials to connect to the network.

## Crashing a Target AP with MDK4

> [!INFO] Crashing a target access point (AP) with MDK4 is a method that only works on very old routers. Recent routers are not vulnerable to this type of Denial-of-Service (DoS) attack.

During our efforts of retrieving the PIN and WPA-PSK, we are likely to encounter an access point locking at some point. In this section, we will demonstrate how flooding and crashing the AP can be used as a potential bypass.

The second kind of WPS lock is one that requires the AP to be reset, either through a power cycle or some other means, after too many incorrect PIN attempts. This can dissuade us as attackers from continuing WPS PIN retrieval techniques. However, `Authentication Denial-of-Service` and `EAPOL Start and Logoff` packet injection flooding attacks can grant us this access point reset. In some cases, this will remove the WPS lock. It is worth noting that not all access points are vulnerable to these two aggressive techniques, and `these techniques are truly a last resort`. In some instances, the access point will crash, while the WPS lock remains enabled.

### Bypassing the WPS Reset Lock Through MDK4

To begin this technique, we will need three terminals. In the first terminal, we will initiate the online brute-forcing attempt against the PIN.

```bash
sudo reaver -l 100 -r 3:45 -i wlan0mon -b XX:XX:XX:XX:XX:XX -c 11
```

In the second terminal, we can monitor our `WPS Locked` status with `airodump-ng` and the `--wps` filter. We also specify our BSSID and channel, to exclude any additional access points from our list.

```bash
airodump-ng --wps --bssid XX:XX:XX:XX:XX:XX -c 11 wlan0mon
```

Suppose our access point displays a locked status. This will halt all PIN attempts occurring in the first terminal. Luckily, [MDK4](https://github.com/aircrack-ng/mdk4) includes functionality in its attack modules for both Authentication Denial-of-Service and EAPOL Start and Logoff Packet Injection flooding. In our third terminal, we can employ the following command to test for Authentication Denial-of-Service flooding. We specify attack module `a` for `Authentication Denial-of-Service`, and our access point's MAC address with `-a`.

```bash
sudo mdk4 wlan0mon a -a XX:XX:XX:XX:XX:XX
```

`Authentication Denial-Of-Service` attacks will continue to spoof MAC addresses to authenticate to the network. This floods the access point's client list, and in many cases causes the access point to crash, thus resetting it. This can enable us to redeem an unlocked WPS status.

Alternatively, we could attempt this same attack with the `Intelligent Test` on the access point. The [Intelligent Test](https://manpages.debian.org/bookworm/mdk4/mdk4.2.en.html#i~2) connects clients against the AP and reinjects sniffed data to keep them alive.

```bash
sudo mdk4 wlan0mon a -i XX:XX:XX:XX:XX:XX
```

If our access point is still displaying a locked status in our second terminal, we could then attempt an `EAPOL Start and Logoff Packet Injection` attack.

In the third terminal, we have our choice of `EAPOL Start` or `EAPOL Logoff` messages. To use `EAPOL Start` messages, we run the following command.

```bash
sudo mdk4 wlan0mon e -t XX:XX:XX:XX:XX:XX
```

To use `EAPOL Logoff` messages to kick clients off the network, we can employ the command seen below.

```bash
sudo mdk4 wlan0mon e -t XX:XX:XX:XX:XX:XX -l
```

Alternatively, we could leave our `EAPOL Start` message MDK4 command running in our third terminal and begin the `EAPOL Logoff` messages in a fourth terminal. We can also utilize a de-authentication attack to kick clients.

By this point, our target access point should have crashed or reset if it is vulnerable to either of these DOS attacks. We can check on this in our second terminal through the `airodump-ng` output.

If all goes well, and our access point is reset, our Reaver session in the first terminal should be able to continue. This whole process could be scripted to take away from the need to manually crash the access point every time a lock is incurred. The general idea stays the same. Although this method is proven to cause resets among access points, it creates a noticeable amount of undesired detection for a penetration tester. If we need to keep a low profile, these Denial-of-Service methods would not be a good way to go.