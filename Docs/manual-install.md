# Intro

To get started, I am using Podman to run an instance of Microsoft SQL Server 2022 in a container on Fedora 44 Linux.

If you do not have Podman installed:

```Shell
sudo dnf update -y
sudo dnf install -y podman
podman --version
```

Next, we need to get the latest container image from Microsoft's website:

```Shell
podman pull mcr.microsoft.com/mssql/server:2022-latest
```

Verify the image is installed:

```Shell
podman images
```

Expected:

```
REPOSITORY						TAG			IMAGE ID	CREATED		SIZE
...								...			...			...			...
mcr.microsoft.com/mssql/server	2022-latest	xxxxxxxx	n ... ago	~1.69 GB
...								...			...			...			...
```

Now we need to create the container with the image:

```Shell
podman run -d \
--name sql2022 \
-e ACCEPT_EULA=y \
-e MSSQL_SA_PASSWORD='PASSWORD' \
-p 1433:1433 \
mcr.microsoft.com/mssql/server:2022-latest
```

Verify container is running:

```Shell
podman ps
```

Expected:

```
CONTAINER ID IMAGE										COMMAND				 CREATED STATUS	PORTS				   NAMES
...			 ...										...					 ...	 ...	...					   ...
xxxxxxxxxxxx mcr.microsoft.com/mssql/server:2022-latest	/opt/mssql/bin/sq... ...	 ...	0.0.0.0:1433->1433/tcp sql2022
...			 ...										...					 ...	 ...	...					   ...
```
