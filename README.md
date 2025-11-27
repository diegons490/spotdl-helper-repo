# 🎵 SpotDL Helper

An interactive Bash interface to simplify the use of [spotDL](https://github.com/spotDL/spotify-downloader), a powerful tool to download Spotify songs, albums, and playlists (using external sources like YouTube).

> ⚠️ SpotDL Helper **does not download directly from Spotify**. It uses Spotify metadata (track name, artist, album, cover art, etc.) and downloads the audio from platforms like YouTube.

---

## 📌 What is SpotDL Helper?

SpotDL Helper is a **command-line (CLI) frontend** that makes using spotDL easier through menus, shortcuts, and configurable options. It’s ideal for users who prefer convenience and don’t want to memorize long commands.

---

## 🎬 Preview

![screenshot](/preview.png?raw=true)

---

## 🚀 Features

- 🔹 **Download songs, albums, and playlists** by simply pasting a Spotify link.
- 🔹 **Manage multiple links** in one session.
- 🔹 **Set a default download directory**.
- 🔹 **Compatible with multiple terminals** (Konsole, GNOME Terminal, Xfce Terminal, etc.).
- 🔹 **Multilingual support**: Portuguese (pt_BR), English (en_US), Spanish (es_ES).

---
## 🛠️ How to Install

### Recommended: Install via terminal (one-liner)

You can install SpotDL Helper directly from the terminal using the official installation script hosted on GitHub:

### With curl:
```bash
curl -fsSL https://raw.githubusercontent.com/diegons490/spotdl-helper-repo/main/install.sh | bash
```
### Or with wget:
```
wget -qO- https://raw.githubusercontent.com/diegons490/spotdl-helper-repo/main/install.sh | bash
```
### Alternative: Manual installation from GitHub repository:
##### If you prefer, you can clone the repository and run the installer script manually:
```
git clone https://github.com/diegons490/spotdl-helper-repo
cd spotdl-helper
chmod +x install.sh
./install.sh
```
---

## 📦 Requirements

- `spotdl`
- `bash`
- `ffmpeg`
- `jq`
- `wget` or `curl`
- A supported terminal (`konsole`, `gnome-terminal`, `xfce4-terminal`, etc.)

> All requirements are checked automatically.
---

> ⚠️ **Important Notice:**
> This version uses the **repository version** of the application.
---

## 🧩 Credits

This project is just a helper interface for the excellent:

### ➤ [spotDL – spotify-downloader](https://github.com/spotDL/spotify-downloader)

> spotDL is maintained by [@spotDL](https://github.com/spotDL) and its community.
>
> Licensed under the MIT License.

---

## 🛠️ License

This project is licensed under the [MIT License](LICENSE).

---

## 📣 Contributions

Contributions are welcome! Feel free to open issues, submit pull requests, or suggest improvements.

---

*Crafted with care by [Diego N.S.](https://github.com/diegons490) — a helper for those who just want to enjoy their music effortlessly.*
