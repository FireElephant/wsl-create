# Deploying WSL environments based on Docker containers

1. [Install Docker](https://www.docker.com/get-started/ "Get Started with Docker")  
    After successful installation, the command is correctly executed in the console: `docker --version`

2. [Install WSL and upgrade version from WSL 1 to WSL 2](https://docs.microsoft.com/en-us/windows/wsl/install "Install Linux on Windows with WSL")  
    After successful installation, the command is correctly executed in the console: `wsl --status`

3. [Install Visual Studio Code](https://code.visualstudio.com/download "Download Visual Studio Code")  
    After successful installation, the command is correctly executed in the console: `code --version`

4. Run the command `code --version` and remember the version hash.  
    Example:

    ```sh
    code --version

    1.68.0
    4af164ea3a06f701fe3e89a2bcbb421d2026b68f
    x64
    ```

    - 4af164ea3a06f701fe3e89a2bcbb421d2026b68f - it is version hash

5. Build docker image and save to `*.tar` file:  
    Example command in PowerShell:
    ```powershell
    docker build . `
      --build-arg USER=vsc `
      --build-arg PASSWORD=pass `
      --build-arg VSC_VERSION=4af164ea3a06f701fe3e89a2bcbb421d2026b68f `
      --build-arg GIT_NAME=example `
      --build-arg GIT_EMAIL=example@example.com `
      --tag wsl-perl-dev:vsc-1.68.0 `
      --progress=plain `
      --output type=tar,dest=data/tar-builds/wsl-perl-dev.tar
    ```

    - USER - username for "WSL"
    - PASSWORD - password for "WSL"
    - VSC_VERSION - version hash of VSC from step 4
    - GIT_NAME and GIT_EMAIL - to configure the `.gitconfig` file

6. Create wsl environments from `*.tar` file
    ```powershell
    wsl --import wsl-perl-dev .\data\wsl\wsl-perl-dev .\data\tar-builds\wsl-perl-dev.tar
    ```

    - wsl-perl-dev - The name of the new WSL environment
    - \data\wsl - Catalog with a file system for WSL
    - wsl-perl-dev.tar - File created in step 5

## Notes:
 - Check the list of WSL environment: `wsl --list`
 - Delete WSL environment: `wsl --unregister <Distro>`
   - example: `wsl --unregister wsl-perl-dev`
 - Open catalog from WSL in the editor: `code --folder-uri vscode-remote://wsl+wsl-perl-dev/home/vsc`
 - Quickly create WSL from `*.tar` and open the editor:
    ```powershell
    wsl --unregister wsl-perl-dev; `
    wsl --import wsl-perl-dev .\data\wsl\wsl-perl-dev .\data\tar-builds\wsl-perl-dev.tar; `
    code --folder-uri vscode-remote://wsl+wsl-perl-dev/home/vsc
    ```
