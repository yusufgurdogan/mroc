# mroc

A fork of [croc](https://github.com/schollz/croc) with a custom relay server.

## About

`mroc` is a tool that allows any two computers to simply and securely transfer files and folders.

- Allows **any two computers** to transfer data (using a relay)
- Provides **end-to-end encryption** (using PAKE)
- Enables easy **cross-platform** transfers (Windows, Linux, Mac)
- Allows **multiple file** transfers
- Allows **resuming transfers** that are interrupted
- No need for local server or port-forwarding
- **IPv6-first** with IPv4 fallback
- Can **use a proxy**, like Tor

## Install

Download [the latest release](https://github.com/yusufgurdogan/mroc/releases/latest), or install from the command-line:

```bash
curl -sL https://raw.githubusercontent.com/yusufgurdogan/mroc/main/install.sh | bash
```

### Windows

Run in PowerShell:

```powershell
irm https://raw.githubusercontent.com/yusufgurdogan/mroc/main/install.ps1 | iex
```

Or download the `.zip` file directly from [the releases page](https://github.com/yusufgurdogan/mroc/releases/latest).

### Build from Source

```bash
go install github.com/yusufgurdogan/mroc@latest
```

Or clone and build:

```bash
git clone https://github.com/yusufgurdogan/mroc.git
cd mroc
go build -o mroc
```

## Usage

To send a file:

```bash
mroc send [file(s)-or-folder]
```

To receive:

```bash
mroc [code-phrase]
```

The code phrase is used to establish password-authenticated key agreement ([PAKE](https://en.wikipedia.org/wiki/Password-authenticated_key_agreement)) which generates a secret key for the sender and recipient to use for end-to-end encryption.

### Using `mroc` on Linux or macOS

On Linux and macOS, the sending and receiving process is slightly different to avoid leaking the secret via the process name. You will need to run `mroc` with the secret as an environment variable:

```bash
MROC_SECRET=*** mroc
```

For single-user systems, the default behavior can be permanently enabled by running:

```bash
mroc --classic
```

### Custom Code Phrase

You can send with your own code phrase (must be more than 6 characters):

```bash
mroc send --code [code-phrase] [file(s)-or-folder]
```

### Send Text

```bash
mroc send --text "hello world"
```

### Send Multiple Files

```bash
mroc send [file1] [file2] [file3] [folder1]
```

### Show QR Code

```bash
mroc send --qr [file(s)-or-folder]
```

### Use Pipes

```bash
cat [filename] | mroc send
```

```bash
mroc --yes [code-phrase] > out
```

### Use a Proxy

```bash
mroc --socks5 "127.0.0.1:9050" send SOMEFILE
```

## Self-host Relay

You can run your own relay:

```bash
mroc relay
```

By default, it uses TCP ports 9009-9013. You can customize the ports:

```bash
mroc relay --ports 1111,1112
```

To send files using your relay:

```bash
mroc --relay "myrelay.example.com:9009" send [filename]
```

### Relay with Docker

```bash
docker run -d -p 9009-9013:9009-9013 -e MROC_PASS='YOURPASSWORD' yusufgurdogan/mroc
```

### Relay as a Systemd Service

```bash
sudo cp mroc.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable mroc
sudo systemctl start mroc
```

## Environment Variables

| Variable | Description |
|----------|-------------|
| `MROC_RELAY` | Address of the relay server |
| `MROC_RELAY6` | IPv6 address of the relay server |
| `MROC_PASS` | Password for the relay |
| `MROC_SECRET` | Code phrase for sending/receiving |
| `MROC_CONFIG_DIR` | Custom config directory |

## Acknowledgements

This is a fork of [croc](https://github.com/schollz/croc) by [@schollz](https://github.com/schollz). All credit for the original implementation goes to them.

## License

MIT
