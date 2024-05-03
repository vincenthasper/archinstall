# archinstall

A simple Arch Linux install script, made to quickly get Arch Linux up and running.

Please keep in mind that I created this script based on my own preferences and system setup. Also be aware that this script will completely wipe out the selected disk without any confirmation prompt.

To use it, connect to the internet and run the following command within the Arch ISO environment:

```bash
bash <(curl -L https://raw.githubusercontent.com/vincenthasper/archinstall/main/archinstall.sh)
```

You will be prompted to select your disk for installation, enter a hostname, set a root password, specify a username, and create a user password. That's it, and you're good to go.
