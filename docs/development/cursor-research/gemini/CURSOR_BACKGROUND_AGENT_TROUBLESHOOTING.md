# Cursor Background Agent Troubleshooting Guide

This guide provides solutions to common issues encountered while setting up and using a Docker-based background agent in Cursor.

---

## 1. Build & Connection Errors

### ❌ Issue: `chown: invalid user: ruser:ruser`

* **Meaning:** The Cursor agent tried to change the ownership of your project files inside the container to a user named `ruser`, but that user does not exist in your Docker image.
* **Solution:**
    1.  **Verify User Creation:** Ensure your `Dockerfile` contains commands to create a non-root user. Use the `Dockerfile.cursor-template` as a reliable reference.
    2.  **Match UID/GID:** The core of the problem is a permissions mismatch. You **must** pass your host machine's User ID (UID) and Group ID (GID) to the Docker build.
    3.  **Check `environment.json`:** Confirm that your `.cursor/environment.json` file has the `args` section correctly configured with your `HOST_UID` and `HOST_GID`.
        ```json
        "args": {
          "HOST_UID": "YOUR_UID_HERE",
          "HOST_GID": "YOUR_GID_HERE"
        }
        ```
    4.  Get your UID/GID by running `id -u && id -g` in your local terminal.

### ❌ Issue: Build fails with `Permission Denied` during `apt-get` or `npm install`

* **Meaning:** A command in your `Dockerfile` is being run as a non-root user that lacks the necessary permissions.
* **Solution:**
    * Ensure the command is run as `root` before you switch to the non-root user. Place package installation steps *before* the `USER cursor` line in your `Dockerfile`.
    * If you need to run a command as root *after* switching users, prefix it with `sudo`. Example: `RUN sudo apt-get install -y some-package`.

### ❌ Issue: Agent builds successfully but fails to connect

* **Meaning:** The container started but exited immediately, or the start command is incorrect.
* **Solution:**
    1.  **Check the Start Command:** Your `start` command in `environment.json` must be a long-running process that keeps the container alive. A blocking command is required.
    2.  **Recommended Start Command:** Use `"start": "tail -f /dev/null"`. This is a simple, reliable command that does nothing but prevents the container from exiting.
    3.  **Check Docker Logs:** Open Docker Desktop or run `docker ps -a` to find the container ID, then check its logs with `docker logs <container_id>` to see if there are any error messages.

---

## 2. In-Container Errors

### ❌ Issue: `Permission denied` when accessing project files from the container's terminal

* **Meaning:** This is a classic UID/GID mismatch. The user inside the container does not have the same UID as your user on the host machine.
* **Solution:**
    * This has the same root cause as the `chown: invalid user` error. Rebuild the agent after carefully verifying that the `HOST_UID` and `HOST_GID` in `environment.json` match the output of `id -u && id -g` on your host.

### ❌ Issue: `command not found` in the agent's terminal

* **Meaning:** The command or program you are trying to run is not installed in the Docker image or is not in the system's `PATH`.
* **Solution:**
    * Add the necessary installation steps to your `Dockerfile`. For example, if `git` is missing, add `apt-get install -y git` to your package installation `RUN` command.
    * Rebuild the agent from Cursor (`Cmd/Ctrl + K` -> "Setup Background Agent").

---

## 3. Support Resources

If the issues persist after following this guide, consider the following resources:

* **Cursor Community Forum:** [https://forum.cursor.com/](https://forum.cursor.com/) - A great place to ask questions and search for solutions from other users.
* **Cursor GitHub Issues:** [https://github.com/cursor/cursor/issues](https://github.com/cursor/cursor/issues) - Check if your issue has already been reported or file a new one.
* **General Docker Documentation:** The official Docker documentation is an invaluable resource for understanding Docker concepts.
