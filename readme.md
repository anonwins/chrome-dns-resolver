# Browser Resolver v2.2

A Windows batch script that allows you to force Chrome or Brave to resolve domain names to specific IP addresses. Perfect for testing websites before DNS propagation or for local development scenarios.

## Features

- Works with both Google Chrome and Brave Browser
- Supports mapping specific domains or all domains (*) to an IP address
- Creates desktop shortcuts for frequently used mappings
- Automatically detects browser installation paths
- Ensures browser is closed before applying changes

## Usage

1. Run the `Chrome Resolver v2.bat` script
2. Enter the host name (domain) you want to map
   - Use `*` to map ALL domains to the specified IP address
3. Enter the IP address you want the domain to resolve to
4. Choose whether to create a desktop shortcut
5. Choose whether to launch the browser immediately

## Examples

- Map a specific domain:
  ```
  Enter the host name: example.com
  Enter the IP address: 192.168.1.100
  ```

- Map all domains:
  ```
  Enter the host name: *
  Enter the IP address: 127.0.0.1
  ```

## Desktop Shortcuts

When you create a shortcut, it will be saved to your desktop with either:
- The domain name as the shortcut name (for specific domains)
- `all-to-[IP]` as the shortcut name (when using *)

Double-click the shortcut anytime to launch the browser with your specified DNS mapping.

## Requirements

- Windows operating system
- Google Chrome or Brave Browser installed
- Administrative privileges are not required
