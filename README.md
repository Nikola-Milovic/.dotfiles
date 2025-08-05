# Intro

This is my personal NixOS flake configuration repository. It utilizes [snowfalllib](https://github.com/snowfallorg/lib) to configure my system, home, packages and so on. I'm constantly improving it but it's already my daily driver.

I have a highly customized setup that allows me to work comfortably for long hours at the computer. Port from my previous Ubuntu setup over at [**.dotfiles-old**](https://github.com/Nikola-Milovic/.dotfiles-old) repository.

## Hardware & Software

| **Category** | **Details** |
|--------------|-------------|
| **Processor** | 💻 Ryzen 9 9950X |
| **Memory** | 64GB DDR5 6000MHz |
| **Storage** | 2TB NVMe M.2 PCIe 4 SSD |
| **Operating System** | NixOS (Sway + Wayland) |
| **IDE** | Neovim |

- **Keyboard**  ⌨️ [Kinesis Advantage 2](https://kinesis-ergo.com/shop/advantage2/) - A durable and comfortable ergonomic keyboard without RGB. Highly recommended for anyone with wrist issues seeking a simple and effective solution.
- **Layout:** [Real-Programmer Dvorak](https://github.com/ThePrimeagen/keyboards) with modifications: `<Esc>` moved to `<Caps Lock>` for easier access, and `Home/End` swapped with `Page Up/Down`.

This setup has eliminated my wrist pain and discomfort entirely.

---

## [Impermanence](https://github.com/nix-community/impermanence)

Currently everything but `/nix`, `/boot` and `/persist` are wiped on every boot. Why...? I don't know really, it's probably not necessary but sounded fun to do. You have to explicitly state every directory and file that you want to persist, it gives you more control over your system so that it doesn't get filled up with junk files

---

# Inspirations & Credits

A big thanks to these amazing repositories that helped me set up my current environment:

- [jakehamilton/config](https://github.com/jakehamilton/config)
- [Khanelinix/khanelinix](https://github.com/khaneliman/khanelinix)
- [hmajid2301/nixicle](https://github.com/hmajid2301/nixicle)

---

# TODOs

- [ ] **Security Enhancements**
- [ ] **Explore [Looking Glass](https://looking-glass.io/)** as an alternative to dual booting
- [ ] **Set Up [YubiKey](https://github.com/drduh/YubiKey-Guide)**
- [ ] **Fix Sway Brightness Hotkeys**
- [ ] **Wrong audio device is used as default**
- [ ] BTRFS rollback not working

## Neovim

- [ ] [Open edit from lazyvim](https://github.com/kdheepak/lazygit.nvim/issues/67#issuecomment-3123381338)
- [ ] AI autocomplete, like [minuet](https://github.com/milanglacier/minuet-ai.nvim)
