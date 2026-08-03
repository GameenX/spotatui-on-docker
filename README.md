# spotatui-on-docker
The famous music player TUI in docker

## Install Guide
1. Clone this repository
2. Build image

    ```docker
    docker compose build
    ```

3. Run docker

    ```docker
    docker compose run --rm music-hub
    ```

4. Inside the docker, execute ``spotatui``

    ```
    spotatui
    ```

5. When asked for logging method, choose option 2.

6. When asked for port, type ``8888``. The process will try to authenticate through a browser, but will fail, then indicate you to manually open the browser with the corresponding link.

7. Open your browser on your host and log into your spotify account.

8. Paste the URL copied from the step 6 in the url bar.

9. Accept the device.

10. Copy the url from the URL bar (ignore the connection error).

11. Open another CLI and paste the following CMD replacing the ``SPOTIFY_URL`` field with the URL copied previously.

    ```
    docker exec -it $(docker ps -q -f ancestor=alpine-music-hub) curl "SPOTIFY_URL"
    ```

12. Wait until Spotatui launches (will take 1 minute approx.)