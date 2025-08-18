# Cursor Background Agent Configuration Guide

This document provides a detailed guide to configuring the `.cursor/environment.json` file and the associated `Dockerfile` for optimal performance, security, and functionality with Cursor's background agent.

---

## 1. The `.cursor/environment.json` File

This file is the control center for your background agent. It defines how to build, install, and run your custom environment.

### Top-Level Properties

* `"build"`: (Object) Defines how to build the Docker image.
* `"install"`: (String) A shell command to run once after the initial build.
* `"start"`: (String) A shell command that starts and maintains the agent's running state.

### The `"build"` Object

This is the most critical section for Docker-based agents.

```json
{
  "build": {
    "dockerfile": "Dockerfile.cursor",
    "context": ".",
    "args": {
      "HOST_UID": "1000",
      "HOST_GID": "1000"
    }
  }
}