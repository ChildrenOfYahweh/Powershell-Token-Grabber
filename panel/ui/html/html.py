from typing import List

map_html = """
    <div style="width: 100%; height: 100%; position: relative;">
        <link rel="stylesheet" href="https://unpkg.com/leaflet@1.7.1/dist/leaflet.css" />
        <script src="https://unpkg.com/leaflet@1.7.1/dist/leaflet.js"></script>
        <script src="https://cdnjs.cloudflare.com/ajax/libs/moment.js/2.29.1/moment.min.js"></script>
        <script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/3.7.0/chart.min.js"></script>

        <style>
            body,
            html {
                margin: 0;
                padding: 0;
                height: 100%;
                overflow: hidden;
                background-color: #1c1c1c;
                color: #e0e0e0;
            }

            #container {
                display: flex;
                flex-direction: column;
                height: 100%;
            }

            #map {
                flex: 1;
                height: 100%;
            }

            .pulse {
                border-radius: 50%;
                cursor: pointer;
                opacity: 0.8;
            }
        </style>

        <div id="container">
            <div id="map"></div>
        </div>

        <script>
            const map = L.map('map', {
                center: [0, 0],
                zoom: 2,
                zoomControl: false,
                attributionControl: false
            });

            let locations = [
                //REPLACE_ME_WITH_DATA
            ];

            L.tileLayer('https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png', {
                subdomains: 'abcd',
                maxZoom: 20
            }).addTo(map);

            map.getContainer().style.background = '#1c1c1c';

            function clearMap() {
                map.eachLayer(layer => {
                    if (layer instanceof L.Marker) {
                        map.removeLayer(layer);
                    }
                });
            }

            function getMagnitudeColor(magnitude) {
                if (magnitude < 3.0) return '#90EE90'; // Light Green
                if (magnitude < 4.0) return '#FFFF00'; // Yellow
                if (magnitude < 5.0) return '#FFA500'; // Orange
                if (magnitude < 6.0) return '#FF0000'; // Red
                return '#8B0000'; // Dark Red
            }

            function createLocation(location) {
                const [lat, lng] = location.coordinates;
                const magnitude = location.magnitude;
                const name = location.name;
                const size = Math.max(magnitude * 3, 5);
                const color = getMagnitudeColor(magnitude);

                // Calculate the pulse size based on magnitude (scaled up)
                const pulseSize = Math.min(magnitude * 3, 30); // Increased scale, limit max size to 30px

                // Create a custom CSS class for this specific location
                const customPulseClass = `pulse-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;
                const randomDelay = Math.random() * 2; // Random delay between 0 and 2 seconds
                const style = document.createElement('style');
                style.textContent = `
    .${customPulseClass} {
    animation: ${customPulseClass} 2s infinite;
    animation-delay: ${randomDelay}s;
    }
    @keyframes
     ${customPulseClass} {
    0% {
    box-shadow: 0 0 0 0 ${color}66;
    }
    70% {
    box-shadow: 0 0 0 ${pulseSize}px ${color}00;
    }
    100% {
    box-shadow: 0 0 0 0 ${color}00;
    }
    }
    `;
                document.head.appendChild(style);

                const pulsingIcon = L.divIcon({
                    className: `pulse ${customPulseClass}`,
                    iconSize: [size, size],
                    html: `<div style="background-color: ${color}; width: ${size}px; height: ${size}px; border-radius: 50%; opacity: 0.8;"></div>`
                });

                const marker = L.marker([lat, lng], { icon: pulsingIcon }).addTo(map);

                marker.bindPopup(`
    <strong>Name:</strong> ${name}<br>
    <strong>Magnitude:</strong> ${magnitude.toFixed(1)}
    `);
            }

            function updateLocations() {
                clearMap();
                locations.forEach(createLocation);
            }

            updateLocations();
        </script>
    </div>
"""


class html_handler:
    def __init__(self, data: List[dict]):
        """Initializes the html_handler class.

        Args:
            data (dict): Data to be used in the html.
        """
        self.data = data

    def get_html(self) -> str:
        """Gets the html with the data.

        Returns:
            str: Returns the html with the data.
        """
        if len(self.data) == 0:
            return map_html.replace("//REPLACE_ME_WITH_DATA", r"{}")
        else:
            new_str = ""
            for item in self.data:
                new_str += f"""
                    {{
                        name: '{item['hostname']}',
                        coordinates: [{item['latitude']}, {item['longitude']}],
                        magnitude: 1
                    }},
                """

            return map_html.replace("//REPLACE_ME_WITH_DATA", new_str)
