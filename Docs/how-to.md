# How to Use

This is a guide on how to bootstrap and utilize this project.

To reiterate shortly, this project is intended to showcase the capabilies scripting provides in learning data transformation, administration, engineering, etc. This project showcases a containerized self serviced ETL ingestable database that can be used to learn off and is all owned by the user.

---

## Running the container

I use podman as my container/composer tool as I use a Fedora based system. I will add Docker commands in time when I get to learning that some more.

To start the container:

Navigate to the project directory (replace ../ with path you cloned project to):

```Shell
cd ../stream-write/
```

Now we can start the container using the `compose.yml` file in the project root directory:

```Shell
podman-compose up -d
```

---

## How to get data

As of now, the project supports CSV formats from Kaggle. In time, the project will expand in capabilites but one person can only learn so much at a time. Keeping in mind, I am just doing this for fun!

We need to run commands from the container we just started:

```Shell
podman exec -it stream-write pwsh
```

Now, we need to run the `GetData` script located in `/Scripts/Kaggle/`.

Prompt: `PS /stream-write>`

```Shell
 ./Scripts/Kaggle/GetData.ps1
```

Enter Kaggle dataset URL.

Results will begin to download to the containers `/tmp` directory and remove the temporary zip file. The data is mounted to the project's folder, but not commited into the project. So, the data is on your system and ready to be utilized in your data duties.
