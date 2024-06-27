import datetime


class StatisticsHandler:
    def __init__(self) -> None:
        self.people_dict = {}
        self.current_day = datetime.now().strftime("%d-%m-%Y")

    def get_people() -> dict:
        pass
