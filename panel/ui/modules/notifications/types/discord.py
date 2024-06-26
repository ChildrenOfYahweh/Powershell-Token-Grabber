import requests

from discord_webhook import DiscordWebhook, DiscordEmbed


class Discord:
    """Discord class to send messages to a Discord webhook."""

    def __init__(self, webhook: str) -> None:
        """Initializes the Discord class.

        Args:
            webhook (str): Webhook URL
        """
        self.webhook_url = webhook

    def check_webhook(self) -> bool:
        """Check if the webhook is valid.

        Returns:
            bool: True if the webhook is valid, False otherwise
        """
        r = requests.get(self.webhook_url)
        return r.status_code == 200

    def send_message(self, title: str, message: str) -> int:
        """Send a message to a Discord webhook.

        Args:
            title (str): The title of the message
            message (str): Description of the message

        Returns:
            int: Response code of the request
        """
        if not self.check_webhook():
            raise ValueError("Invalid webhook URL")

        webhook = DiscordWebhook(url=self.webhook_url, username="NOTIFICATION")
        embed = DiscordEmbed()

        embed.set_footer(text="Kematian fr fr")
        embed.set_color(242424)
        embed.set_description(message)
        embed.set_title(title)
        embed.set_timestamp()
        embed.set_thumbnail(
            url="https://private-user-images.githubusercontent.com/96607632/334191927-345004a3-756a-43a6-9a27-8f09884bdc3e.png?jwt=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbSIsImtleSI6ImtleTUiLCJleHAiOjE3MTg0MjMxNjcsIm5iZiI6MTcxODQyMjg2NywicGF0aCI6Ii85NjYwNzYzMi8zMzQxOTE5MjctMzQ1MDA0YTMtNzU2YS00M2E2LTlhMjctOGYwOTg4NGJkYzNlLnBuZz9YLUFtei1BbGdvcml0aG09QVdTNC1ITUFDLVNIQTI1NiZYLUFtei1DcmVkZW50aWFsPUFLSUFWQ09EWUxTQTUzUFFLNFpBJTJGMjAyNDA2MTUlMkZ1cy1lYXN0LTElMkZzMyUyRmF3czRfcmVxdWVzdCZYLUFtei1EYXRlPTIwMjQwNjE1VDAzNDEwN1omWC1BbXotRXhwaXJlcz0zMDAmWC1BbXotU2lnbmF0dXJlPWI4MGZlOWEyYjRmZGRhNTdjMmZkZmY4ZWRjN2JiOTAyOGU0MjY3YjUyZmI4NGVkNjU5ZWI2YjQ4MzVjYzgzNDcmWC1BbXotU2lnbmVkSGVhZGVycz1ob3N0JmFjdG9yX2lkPTAma2V5X2lkPTAmcmVwb19pZD0wIn0.dOGwsSMffhjps1nNveoZhEQVJPrvmMjrRrM8eVkh7rk"
        )
        embed.set_author(name="KDot227", url="https://sped.lol")
        embed.set_provider(name="Kematian-Stealer")

        webhook.add_embed(embed)

        resp = webhook.execute()
        return resp.status_code


if __name__ == "__main__":
    webhook = input("Enter the webhook URL: ")
    discord = Discord(webhook=webhook)
    discord.send_message("Title", "Message")
