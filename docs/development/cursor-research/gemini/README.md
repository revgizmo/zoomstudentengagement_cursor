# Cursor Background Agent Docker Setup for Issue #262

This collection of documents provides a complete solution and research findings for the persistent `'chown: invalid user: ruser:ruser'` error encountered when using custom Dockerfiles with the Cursor IDE's background agent.

The core issue is that Cursor's agent requires a specific non-root user inside the container to manage file permissions, and standard Docker images often lack this user. The solution provided here establishes a best-practice approach for creating this user and configuring Cursor to use it correctly.

---

## Files in this Package

* **`ISSUE_262_RESEARCH_FINDINGS.md`**: A comprehensive report detailing the root cause analysis of the error, the investigation process, and technical recommendations for both users and the Cursor team.
* **`Dockerfile.cursor-template`**: A minimal, ready-to-use Dockerfile template. It creates a non-root user with the correct permissions, serving as the foundation for your custom environment. ⚙️
* **`CURSOR_BACKGROUND_AGENT_SETUP.md`**: **(Start here!)** A step-by-step guide on how to implement the fix. It walks you through finding your user ID, configuring Cursor, and launching the agent. 🚀
* **`CURSOR_BACKGROUND_AGENT_CONFIG.md`**: A more detailed look into the `.cursor/environment.json` file, offering best practices for configuration, performance, and security.
* **`CURSOR_BACKGROUND_AGENT_TROUBLESHOOTING.md`**: A focused guide for resolving this error and other common issues you might encounter with the background agent. 🛠️

---

## How to Use

1.  **Start with the Setup Guide:** Begin by reading `CURSOR_BACKGROUND_AGENT_SETUP.md`.
2.  **Use the Template:** Copy the `Dockerfile.cursor-template` into your project.
3.  **Refer to Other Docs:** Use the configuration, research, and troubleshooting guides for deeper understanding and to solve any further issues.