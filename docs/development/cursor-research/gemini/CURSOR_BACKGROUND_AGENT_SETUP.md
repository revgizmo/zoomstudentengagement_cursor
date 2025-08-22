# Cursor Background Agent Docker Setup Guide

This guide provides step-by-step instructions for configuring a Docker-based background agent in Cursor. Following these steps will help you create a stable, secure, and permission-error-free development environment.

---

## 1. Prerequisites

* **Cursor IDE:** You must have a recent version of Cursor installed.
* **Docker:** Docker Desktop (or Docker Engine on Linux) must be installed and running on your local machine.

---

## 2. Setup Instructions

The setup process involves three main steps:
1.  Creating a `Dockerfile` that defines your environment.
2.  Creating a `.cursor/environment.json` file to tell Cursor how to use your `Dockerfile`.
3.  Launching the background agent from Cursor.

### Step 1: Create the Dockerfile

First, you need a `Dockerfile` that builds your development environment. To avoid the common `chown: invalid user` error, it is **critical** that your Dockerfile creates a non-root user whose UID (User ID) and GID (Group ID) match your user on your host machine.

1.  **Find Your Host UID/GID:**
    Open a terminal on your local machine (not in Cursor) and run the following command:
    ```bash
    id -u && id -g
    ```
    This will print two numbers. The first is your UID, and the second is your GID. For example, `1000` and `1000`. **Take note of these values.**

2.  **Create the Dockerfile:**
    In the root of your project, create a file named `Dockerfile.cursor`. You can use the provided `Dockerfile.cursor-template` as a starting point. Copy its contents into your new `Dockerfile.cursor` file.

    * **Customize the Base Image:** Change the `FROM ubuntu:22.04` line to whatever base image you need (e.g., `python:3.11-slim`).
    * **Add Your Dependencies:** Add `RUN` commands to install any system packages, programming languages, or libraries your project requires.

### Step 2: Configure `environment.json`

Cursor uses a special configuration file to manage the background agent.

1.  **Create the File:** In your project root, create a directory named `.cursor`, and inside it, create a file named `environment.json`.

2.  **Add Configuration:** Paste the following JSON into `.cursor/environment.json` and **replace the `1000` values with your actual UID and GID** from the previous step.

    ```json
    {
      "build": {
        "dockerfile": "Dockerfile.cursor",
        "args": {
          "HOST_UID": "1000",
          "HOST_GID": "1000"
        }
      },
      "install": "echo 'Dependencies can be installed here.'",
      "start": "tail -f /dev/null"
    }
    ```

    * `"dockerfile"`: Points to the `Dockerfile` you created.
    * `"args"`: This is the **most important** part. It passes your host UID and GID into the Docker build, ensuring the user created inside the container has the correct permissions.
    * `"install"`: A command to run *once* after the container is built. Useful for installing project dependencies.
    * `"start"`: The command to start the agent and keep it running. `tail -f /dev/null` is a reliable way to keep the container active.

### Step 3: Launch the Background Agent

1.  Open your project in Cursor.
2.  Open the Command Palette (`Cmd/Ctrl + K`).
3.  Type "Setup Background Agent" and select the option.
4.  Cursor will detect your `.cursor/environment.json` file and begin the Docker build process. You can monitor the progress in the terminal panel.

Once the build is complete, the agent will be running, and you can interact with it for code generation, terminal commands, and more, all within your custom containerized environment.

---

## 3. Troubleshooting

* **`chown: invalid user: ruser:ruser` Error:**
    * This means your UID/GID configuration is incorrect. Double-check that the `HOST_UID` and `HOST_GID` values in your `environment.json` exactly match the output of the `id -u && id -g` command on your host.
    * Ensure your `Dockerfile` contains the `ARG HOST_UID` and `ARG HOST_GID` lines.

* **Permission Denied Errors:**
    * If you see permission errors when the agent tries to access files, it's almost always a UID/GID mismatch. Re-run the setup steps carefully.

* **Build Fails on Package Installation:**
    * Ensure your base image is correct and that the package names are valid for that image's operating system (e.g., `apt-get` for Debian/Ubuntu, `apk` for Alpine).

---

## 4. FAQ

**Q: Why is matching UID/GID so important?** A: Docker mounts your local project directory into the container. Linux handles file permissions using numeric UIDs and GIDs, not usernames. If the user inside the container has a different UID than your user outside, it won't have permission to read or write your files, causing errors.

**Q: Can I use a username other than `cursor` in the Dockerfile?** A: Yes. The username is not as important as the UID/GID. However, for consistency, it's good practice to use a standard name like `cursor` or `dev`.

**Q: How do I add my project's dependencies?** A: Add `RUN` commands to your `Dockerfile` to install system-level dependencies. For project-level dependencies (like `pip` or `npm` packages), you can either add them to the Dockerfile or put the installation command in the `"install"` script in `environment.json`.